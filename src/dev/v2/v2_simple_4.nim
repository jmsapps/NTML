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

# ------------------- DSL -------------------
template makeTag(name: untyped) =
  macro `name`*(args: varargs[untyped]): untyped =
    let tagName = astToStr(name).replace("`","")
    let kvs = newTree(nnkBracket)
    var kids: seq[NimNode] = @[]

    proc pushChild(n: NimNode) {.compileTime.} =
      kids.add n   # strings/signals handled by mountChild at runtime

    for a in args:
      case a.kind
      of nnkStmtList, nnkStmtListExpr:
        for it in a: pushChild(it)
      of nnkExprEqExpr:
        var k = $a[0]; if k == "className": k = "class"
        let v = (if a[1].kind in {nnkStrLit, nnkRStrLit}: a[1] else: newCall(ident"$", a[1]))
        kvs.add newTree(nnkPar, newLit(k), v)
      of nnkInfix:
        if a[0].kind == nnkIdent and $a[0] == "=":
          var k = $a[1]; if k == "className": k = "class"
          let v = (if a[2].kind in {nnkStrLit, nnkRStrLit}: a[2] else: newCall(ident"$", a[2]))
          kvs.add newTree(nnkPar, newLit(k), v)
        else:
          pushChild(a)
      of nnkIdent:
        kvs.add newTree(nnkPar, newLit($a), newLit("true"))  # boolean attr
      else:
        pushChild(a)

    # let n = el(...); mountChild(n, kid)...; n
    let n = genSym(nskLet, "n")
    let stmts = newTree(nnkStmtListExpr)
    stmts.add newLetStmt(n, newCall(ident"el", newLit(tagName), newTree(nnkPrefix, ident"@", kvs)))
    for c in kids:
      stmts.add newCall(ident"mountChild", n, c)
    stmts.add n
    result = stmts

makeTag `div`
makeTag `h1`
makeTag `section`

when isMainModule:
  let count = signal(0)
  let countStr = derived(count, proc (x: int): string = $x)

  let root = `section`(id="hero", className="wrap"):
    "Intro: "; countStr; " hello"
    `div`(className="content"):
      `h1`:
        "Hello, world!"
  discard jsAppendChild(document.body, root)

  proc tick() = set(count, get(count) + 1)
  tick(); tick(); tick(); tick(); tick(); tick();
