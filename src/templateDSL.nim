import macros

template html(name: untyped, children: untyped) =
  proc `name`(): string =
    result = "<html>"
    children
    result.add("</html>")

template component(name: untyped, children: untyped) =
  template `name`() =
    children

template nonTerminalTag(tag: untyped) =
  template `tag`(children: untyped) =
    result.add("<" & astToStr(tag) & ">")
    children
    result.add("</" & astToStr(tag) & ">")

template terminalTag(tag: untyped) =
  template `tag`(children: string) =
    result.add("<" & astToStr(tag) & ">" & children & "</" & astToStr(tag) & ">")

nonTerminalTag body
nonTerminalTag head
nonTerminalTag dv
nonTerminalTag ul
terminalTag h1
terminalTag li

type
  SomeObject = object of RootObj
    key: string

let object1 = SomeObject(key: "string1")
let object2 = SomeObject(key: "string2")
let object3 = SomeObject(key: "string3")

let objects = [object1, object2, object3]

let number = 3

template StyledHead(children: untyped) =
  head:
    children

template MyComponent() =
  StyledHead:
    h1 "now look at this"
  body:
    case number
    of 1:
      dv:
        h1: "hello"
    of 2:
      ul:
        for obj in objects:
          li "Nim is quite " & obj.key & " capable"
    else:
      discard

html mainPage:
  MyComponent

echo mainPage()
