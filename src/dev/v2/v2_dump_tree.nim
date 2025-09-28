import macros

type
  OrganHealth = object
    liver: bool

  Trait = object
    eye_color: string
    organ_health: OrganHealth

  Person = object
    name: string
    age: int
    trait: Trait

let people: seq[Person] = @[
  Person(name: "Alice", age: 30, trait: Trait(eye_color: "blue", organ_health: OrganHealth(liver: true))),
  Person(name: "Bob", age: 25, trait: Trait(eye_color: "brown", organ_health: OrganHealth(liver: true))),
  Person(name: "Charlie", age: 40, trait: Trait(eye_color: "green", organ_health: OrganHealth(liver: true)))
]

let person: Person = Person(name: "Charlie", age: 40, trait: Trait(eye_color: "green", organ_health: OrganHealth(liver: true)))

let count: int = 0

# dumpTree:
#   `div`:
#     ("Nim ", "is ", "really ", "great!")

dumpTree:
  h1:
    h1:
      "hello" ; " " ; "world"
    for p in people:
      p.name ; " is " ; p.age ; "eye color " ; p.trait.eye_color

    for p, idx in people:
      p.name ; " is " ; p.age ; "eye color " ; p.trait.eye_color ; $p.trait.organ_health.liver

    for i in [1, 2, 3]:
      i

    for i, idx in [1, 2, 3]:
      (i, idx)

    for i, idx in [1, 2, 3]:
      (i, " ", $idx) ; idx ; %%count.kind ; $"HELLO" ; $person.name
