import macros

template newHtmlElement(name: untyped) =
  macro `name`*(args: varargs[untyped]) =
    proc parseNodes(args: NimNode)
    proc parseNode(arg: NimNode)

    proc parseNodes(args: NimNode) =
      for arg in args:
        parseNode(arg)

    proc parseNode(arg: NimNode) =
      case arg.kind
      of nnkDotExpr:
        echo arg[1].kind, " ", arg[1].repr

      of nnkIdent, nnkStrLit, nnkIntLit, nnkSym:
        echo arg.kind, " ", arg.repr

      of nnkForStmt:
        parseNodes(arg[^1])

      of nnkCall:
        parseNode(arg[1])

      of nnkTupleConstr:
        parseNodes(arg)

      of nnkStmtList, nnkStmtListExpr:
        parseNodes(arg)

      of nnkEmpty:
        discard
      else:
        echo "ERROR ", arg.repr, " ", arg.kind

    parseNodes(args)

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
  `div`:
    p: "hello"
    for person in people:
      p: (person.name, " is ", person.age, "eye color ", person.trait.eye_color)
    for i in ["1", "2", "3"]:
      p:
        ("hello", i); p: 1; ("hello", i)
      for i, idx in [2, 4, 6]:
        p:
          idx
    for i in [1, 2, 3]:
      h1: i
ntml()
