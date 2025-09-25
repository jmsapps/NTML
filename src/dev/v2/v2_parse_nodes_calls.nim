import macros

template newHtmlElement(name: untyped) =
  macro `name`*(nodes: varargs[untyped]) =
    for node in nodes:
      case node.kind
      of nnkTupleConstr:
        for n in node:
          echo "HERE"
          # echo newCall(n).kind, " ", n.repr
          echo " "
      of nnkCall:
        echo "CALL callee=", node[0].repr
        for i in 1 ..< node.len:
          echo newCall(node[i]).repr
      else:
        echo newCall(node).kind, " ", node.repr
        echo " "


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
    # p: "hello"
    for person in people:
      p: (person.name, " is ", person.age, "eye color ", person.trait.eye_color)
    # for i in ["1", "2", "3"]:
    #   p:
    #     ("hello", i); p: 1; ("hello", i)
    #   for i, idx in [2, 4, 6]:
    #     p:
    #       idx
    # for i in [1, 2, 3]:
    #   h1: i
ntml()
