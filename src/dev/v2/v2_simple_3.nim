import macros, dom, strutils

proc el*(tag: string, props: openArray[(string, string)] = [], children: varargs[Node]): Node =
  let element = document.createElement(tag)
  for (k, v) in props:
    if v.len > 0: element.setAttribute(cstring(k), cstring(v))
  for c in children: element.appendChild(c)
  element

proc textNode(n: NimNode): NimNode {.compileTime.} =
  newCall(ident"createTextNode", ident"document", newCall(ident"cstring", n))

template makeTag(name: untyped) =
  macro `name`*(args: varargs[untyped]): untyped =
    let tagName = astToStr(name).replace("`","")
    let kvs = newTree(nnkBracket)
    var kids: seq[NimNode] = @[]

    proc pushChild(n: NimNode) {.compileTime.} =
      case n.kind
      of nnkStrLit, nnkRStrLit, nnkCharLit, nnkIntLit, nnkFloatLit:
        kids.add textNode(n)
      of nnkDiscardStmt:
        discard
      else:
        kids.add n

    # parse args: props, positional kids, trailing StmtList body
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
        # boolean attr -> present with value "true"
        kvs.add newTree(nnkPar, newLit($a), newLit("true"))

      else:
        pushChild(a)

    # emit: el(tag, @props, kids...)
    result = newCall(ident"el", newLit(tagName), newTree(nnkPrefix, ident"@", kvs))
    for c in kids: result.add c

makeTag `div`
makeTag `h1`
makeTag `section`

when isMainModule:
  let root = `section`(id="hero", className="wrap"):
    "Intro text"
    `div`(className="content"):
      `h1`:
        "Hello, world!"

  document.body.appendChild(root)
