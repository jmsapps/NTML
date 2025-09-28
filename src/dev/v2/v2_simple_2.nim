import macros, dom, strutils

proc el*(tag: string, props: openArray[(string, string)] = [], children: varargs[Node]): Node =
  let element = document.createElement(tag)
  for (k, v) in props:
    if v.len > 0: element.setAttribute(cstring(k), cstring(v))
  for c in children: element.appendChild(c)
  element

proc textNode(n: NimNode): NimNode {.compileTime.} =
  newCall(newDotExpr(ident"document", ident"createTextNode"),
          newCall(ident"cstring", n))

proc buildCall(tagName: string; argsNode: NimNode; body: NimNode): NimNode {.compileTime.} =
  let kvs = newTree(nnkBracket)
  var kids: seq[NimNode] = @[]

  proc pushChild(n: NimNode) {.compileTime.} =
    if n.kind in {nnkStrLit, nnkRStrLit, nnkCharLit, nnkIntLit, nnkFloatLit}:
      kids.add textNode(n)
    elif n.kind == nnkDiscardStmt:
      discard
    else:
      kids.add n

  # args -> props or children
  if argsNode.kind != nnkEmpty:
    for a in argsNode:
      case a.kind
      of nnkExprEqExpr:
        var k = $a[0]
        if k == "className": k = "class"
        let v = (if a[1].kind in {nnkStrLit, nnkRStrLit}: a[1] else: newCall(ident"$", a[1]))
        kvs.add newTree(nnkPar, newLit(k), v)
      of nnkInfix:
        if a[0].kind == nnkIdent and $a[0] == "=":
          var ks = $a[1]
          if ks == "className": ks = "class"
          let v = (if a[2].kind in {nnkStrLit, nnkRStrLit}: a[2] else: newCall(ident"$", a[2]))
          kvs.add newTree(nnkPar, newLit(ks), v)
        else:
          pushChild(a)
      of nnkIdent:
        # boolean attribute
        kvs.add newTree(nnkPar, newLit($a), newLit(""))
      else:
        pushChild(a)

  # body -> children
  case body.kind
  of nnkStmtList, nnkStmtListExpr:
    for it in body: pushChild(it)
  of nnkEmpty: discard
  else: pushChild(body)

  result = newCall(ident"el", newLit(tagName), newTree(nnkPrefix, ident"@", kvs))
  for c in kids: result.add c

template makeTag(name: untyped) =
  macro `name`*(args: varargs[untyped]; body: untyped): untyped =
    buildCall(astToStr(name).replace("`",""), args, body)
  macro `name`*(args: varargs[untyped]): untyped =
    buildCall(astToStr(name).replace("`",""), args, newStmtList())

makeTag `div`
makeTag `h1`
makeTag `section`
makeTag `button`


when isMainModule:
  let root: Node =
    `section`(
      id="hero",
      className="wrap",
    ):
      `div`(
        className="content",
        `h1`("Hello, world!")
      )

  document.body.appendChild(root)
