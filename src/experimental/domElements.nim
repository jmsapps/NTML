import macros, strutils, dom

template newHtmlElement(name: untyped) =
  macro `name`*(args: varargs[untyped]): untyped =
    # Create `let el = document.createElement("h1")`
    let el = genSym(nskLet, astToStr(name).replace("`", ""))
    let create = newLetStmt(
      el,
      newCall(
        newDotExpr(ident"document", ident"createElement"),
        newLit(astToStr(name).replace("`", ""))
      )
    )

    # Collect statements
    var stmts = newStmtList(create)

    for arg in args:
      case arg.kind
      of nnkExprEqExpr:
        stmts.add(
          newCall(
            newDotExpr(el, ident"setAttribute"),
            newLit($arg[0]), arg[1]
          )
        )
      of nnkStmtList:
        for child in arg:
          if child.kind in {nnkStrLit, nnkRStrLit}:
            # Generate: el.appendChild(document.createTextNode("..."))
            stmts.add newCall(
              newDotExpr(el, ident"appendChild"),
              newCall(
                newDotExpr(ident"document", ident"createTextNode"),
                child
              )
            )
          else:
            # Assume it's another DOM element
            stmts.add newCall(
              newDotExpr(el, ident"appendChild"),
              child
            )
      else:
        for child in arg:
          if child.kind in {nnkStrLit, nnkRStrLit}:
            # Generate: el.appendChild(document.createTextNode("..."))
            stmts.add newCall(
              newDotExpr(el, ident"appendChild"),
              newCall(
                newDotExpr(ident"document", ident"createTextNode"),
                child
              )
            )
          else:
            # Assume it's another DOM element
            stmts.add newCall(
              newDotExpr(el, ident"appendChild"),
              child
            )

    stmts.add(el)
    result = newTree(nnkStmtListExpr, stmts)

newHtmlElement `div`
newHtmlElement `h1`
newHtmlElement `li`

let html: Element = `div`:
  h1:
    "hello"

document.body.appendChild(html)
