import macros, strutils, dom

template newHtmlElement(name: untyped) =
  macro `name`*(nodes: varargs[untyped]): untyped =
    let tag = astToStr(name).replace("`","")
    let el  = genSym(nskLet, tag)
    let stmts = newStmtList()

    # let el = document.createElement(tag)
    stmts.add newLetStmt(
      el,
      newCall(newDotExpr(ident"document", ident"createElement"), newLit(tag))
    )

    proc addChildren(n: NimNode) =
      case n.kind
      of nnkTupleConstr, nnkPar:
        for it in n:
          addChildren(it)

      of nnkStmtList, nnkStmtListExpr, nnkBlockStmt:
        for it in n:
          addChildren(it)

      else:
        # el.appendChild(document.createTextNode($expr))
        stmts.add newCall(
          newDotExpr(el, ident"appendChild"),
          newCall(
            newDotExpr(ident"document", ident"createTextNode"),
            newCall(ident"cstring", newCall(ident"$", n))    # ensure non-strings stringify
          )
        )

    for n in nodes:
      addChildren(n)

    # document.body.appendChild(el)
    stmts.add newCall(
      newDotExpr(newDotExpr(ident"document", ident"body"), ident"appendChild"),
      el
    )

    result = stmts

newHtmlElement `div`
newHtmlElement `h1`
newHtmlElement `li`
newHtmlElement `p`

type
  Trait = object
    eye_color: string
  Person = object
    name: string
    age: int
    trait: Trait

let people: seq[Person] = @[
  Person(name: "Alice", age: 30, trait: Trait(eye_color: "blue")),
  Person(name: "Bob", age: 25, trait: Trait(eye_color: "brown")),
  Person(name: "Charlie", age: 40, trait: Trait(eye_color: "green"))
]

proc ntml() =
  p:
    "hello"
  `div`:
    ("Nim ", "is ", "really ", "great! ", people[0].name)

ntml()
