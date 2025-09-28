import macros, dom, strutils

# ------------------- Signals -------------------
type
  Unsub* = proc () {.gcsafe.}
  Subscriber*[T] = proc (v: T) {.gcsafe.}
  Signal*[T] = ref object
    v: T
    subs: seq[Subscriber[T]]

proc signal*[T](initial: T): Signal[T] =
  new(result); result.v = initial; result.subs = @[]

proc get*[T](s: Signal[T]): T = s.v

proc set*[T](s: Signal[T], nv: T) =
  if nv != s.v:
    s.v = nv
    for f in s.subs: f(nv)

proc sub*[T](s: Signal[T], f: Subscriber[T]): Unsub =
  s.subs.add f
  f(s.v)
  result = proc() =
    var i = -1
    for idx, g in s.subs:
      when compiles(g == f):
        if g == f: i = idx; break
    if i >= 0: s.subs.delete(i)

proc derived*[A, B](s: Signal[A], fn: proc(a: A): B {.gcsafe.}): Signal[B] =
  let sigOut = signal[B](fn(s.v))
  discard s.sub(proc(a: A) {.gcsafe.} = sigOut.set(fn(a)))
  sigOut

# ------------------- JS DOM shims (GC-safe) -------------------
proc jsCreateElement*(s: cstring): Node {.importjs: "document.createElement(#)", gcsafe.}
proc jsCreateTextNode*(s: cstring): Node {.importjs: "document.createTextNode(#)", gcsafe.}
proc jsAppendChild*(p: Node, c: Node): Node {.importjs: "#.appendChild(#)", gcsafe.}
proc jsRemoveChild*(p: Node, c: Node): Node {.importjs: "#.removeChild(#)", gcsafe.}
proc jsInsertBefore*(p: Node, newChild: Node, refChild: Node): Node {.importjs: "#.insertBefore(#,#)", gcsafe.}
proc jsSetAttribute*(el: Node, k: cstring, v: cstring) {.importjs: "#.setAttribute(#,#)", gcsafe.}
proc jsAddEventListener*(el: Node, t: cstring, cb: proc (e: Event)) {.importjs: "#.addEventListener(#,#)".}

# ------------------- DOM helpers -------------------
proc el*(tag: string, props: openArray[(string, string)] = [], children: varargs[Node]): Node {.gcsafe.} =
  let element = jsCreateElement(cstring(tag))
  for (k, v) in props:
    if v.len > 0: jsSetAttribute(element, cstring(k), cstring(v))
  for c in children: discard jsAppendChild(element, c)
  element

proc toNode*(n: Node): Node {.gcsafe.} = n
proc toNode*(s: string): Node {.gcsafe.} = jsCreateTextNode(cstring(s))
proc toNode*(s: cstring): Node {.gcsafe.} = jsCreateTextNode(s)
proc toNode*(x: int): Node {.gcsafe.} = jsCreateTextNode(cstring($x))
proc toNode*(x: float): Node {.gcsafe.} = jsCreateTextNode(cstring($x))
proc toNode*(x: bool): Node {.gcsafe.} = jsCreateTextNode(cstring($x))

proc removeBetween*(parent: Node, startN, endN: Node) {.gcsafe.} =
  var n = startN.nextSibling
  while n != endN and n != nil:
    let nxt = n.nextSibling
    discard jsRemoveChild(parent, n)
    n = nxt

proc mountChild*(parent: Node, child: Node) {.gcsafe.} =
  discard jsAppendChild(parent, child)
proc mountChild*(parent: Node, child: string) {.gcsafe.} =
  discard jsAppendChild(parent, jsCreateTextNode(cstring(child)))
proc mountChild*(parent: Node, child: cstring) {.gcsafe.} =
  discard jsAppendChild(parent, jsCreateTextNode(child))
proc mountChild*(parent: Node, child: int) {.gcsafe.} =
  discard jsAppendChild(parent, jsCreateTextNode(cstring($child)))
proc mountChild*(parent: Node, child: float) {.gcsafe.} =
  discard jsAppendChild(parent, jsCreateTextNode(cstring($child)))
proc mountChild*(parent: Node, child: bool) {.gcsafe.} =
  discard jsAppendChild(parent, jsCreateTextNode(cstring($child)))

proc mountChild*[T](parent: Node, s: Signal[T]) {.gcsafe.} =
  let startN = jsCreateTextNode(cstring(""))
  let endN   = jsCreateTextNode(cstring(""))
  discard jsAppendChild(parent, startN)
  discard jsAppendChild(parent, endN)

  proc render(v: T) {.gcsafe.} =
    removeBetween(parent, startN, endN)
    discard jsInsertBefore(parent, toNode(v), endN)

  render(s.get())
  discard s.sub(proc(v: T) {.gcsafe.} = render(v))

template makeTag(name: untyped) =
  macro `name`*(args: varargs[untyped]): untyped =
    var tagName = astToStr(name).replace("`","")
    if tagName == "d": tagName = "div"

    let kvs = newTree(nnkBracket)
    var kids: seq[NimNode] = @[]
    var evtNames: seq[string] = @[]
    var evtHandlers: seq[NimNode] = @[]

    proc pushChild(n: NimNode) {.compileTime.} = kids.add n
    proc handleAttr(kRaw: string, v: NimNode) {.compileTime.} =
      var k = kRaw
      if k == "className": k = "class"
      let kl = k.toLowerAscii()
      if kl.len >= 3 and kl[0..1] == "on":
        let evt = kl[2..^1]
        evtNames.add evt
        evtHandlers.add v
      else:
        let vv = (if v.kind in {nnkStrLit, nnkRStrLit}: v else: newCall(ident"$", v))
        kvs.add newTree(nnkPar, newLit(k), vv)

    # ----- NEW: lower control-flow to mountChild(parent, expr) -----
    proc lowerMount(parent, node: NimNode): NimNode {.compileTime.} =
      case node.kind
      of nnkStmtList, nnkStmtListExpr, nnkBlockStmt:
        result = newTree(nnkStmtList)
        for it in node: result.add lowerMount(parent, it)

      of nnkIfStmt:
        let sigOut = newTree(nnkIfStmt)
        for br in node:
          case br.kind
          of nnkElifBranch:
            sigOut.add newTree(nnkElifBranch, br[0], lowerMount(parent, br[1]))
          of nnkElse:
            sigOut.add newTree(nnkElse, lowerMount(parent, br[0]))
          else: discard
        result = sigOut

      of nnkForStmt, nnkWhileStmt:
        let loop = copy node
        loop[^1] = lowerMount(parent, node[^1])
        result = loop

      # allow variable defs/assignments inline without mounting
      of nnkLetSection, nnkVarSection, nnkConstSection, nnkAsgn, nnkDiscardStmt:
        result = node

      else:
        # Any expression -> mount it
        result = newCall(ident"mountChild", parent, node)
    # ----------------------------------------------------------------

    for a in args:
      case a.kind
      of nnkStmtList, nnkStmtListExpr:
        for it in a: pushChild(it)
      of nnkExprEqExpr: handleAttr($a[0], a[1])
      of nnkInfix:
        if a[0].kind == nnkIdent and $a[0] == "=": handleAttr($a[1], a[2]) else: pushChild(a)
      of nnkIdent: kvs.add newTree(nnkPar, newLit($a), newLit("true"))
      else: pushChild(a)

    let n = genSym(nskLet, "n")
    let stmts = newTree(nnkStmtListExpr)
    stmts.add newLetStmt(n, newCall(ident"el", newLit(tagName), newTree(nnkPrefix, ident"@", kvs)))

    # use lowerMount for everything
    for c in kids: stmts.add lowerMount(n, c)

    # events (hoisted)
    for i in 0 ..< evtNames.len:
      let cbSym = genSym(nskLet, "cb")
      stmts.add newLetStmt(cbSym, evtHandlers[i])
      stmts.add newCall(ident"jsAddEventListener", n, newCall(ident"cstring", newLit(evtNames[i])), cbSym)

    stmts.add n
    result = stmts



makeTag `d`
makeTag `h1`
makeTag `section`
makeTag `button`
makeTag `br`
makeTag `ul`
makeTag `li`
makeTag `style`


when isMainModule:
  var count: Signal[int] = signal(0)
  let doubled: Signal[system.string] = derived(count, proc (x: int): string = $(x*2))

  let isEven: Signal[system.bool] = derived(count, proc (x: int): bool =
    if x mod 2 == 0: true else: false
  )

  let styleTag =
    style:
      """
        ._div_container_87897126 {
          background-color: #eee;
          padding: 12px;
          border-radius: 8px;
        }
      """

  let component =
    d(id="hero", class="_div_container_87897126"):
      "Count: "; count; br(); "Doubled: "; doubled; br(); br();
      button(
        class="btn",
        onClick = proc (e: Event) = set(count, get(count) + 1)
      ): "Increment"

      ul:
        li: derived(count, proc (x: int): string = $(x*2 + 1))
        li: derived(count, proc (x: int): string = $(x*2 + 2))
        li: derived(count, proc (x: int): string = $(x*2 + 3))

      h1:
        derived(isEven, proc (b: bool): string =
          if b: "Even" else: "Odd"
        )

      ul:
        for i in 1..3:
          li: doubled

  discard jsAppendChild(document.head, styleTag)
  discard jsAppendChild(document.body, component)
