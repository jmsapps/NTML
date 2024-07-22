import macros, strutils

const ntmlVoidElements: array[1, string] = ["img"]
const ntmlAtomicElements: array[2, string] = ["h1", "button"]
const ntmlCompositeElements: array[2, string] = ["body", "div"]

proc getTagType(tag: string): string =
  result = "unknown"

  if tag in ntmlVoidElements:
    result = "void"
  if tag in ntmlAtomicElements:
    result = "atomic"
  if tag in ntmlCompositeElements:
    result = "composite"

template html*(name: untyped, matter: untyped) =
  proc `name`*(): string =
    result = "<html>"
    matter
    result.add("</html>")

template component*[T](name: untyped, matter: untyped) =
  macro `name`*(props: T) =
    quote do:
      matter

template styled*(name: untyped, tag: untyped, style: string = "") =
  macro `name`*(args: varargs[untyped]): untyped =
    var child: NimNode
    var attributes = ""

    var styleAttr = ""
    if style != "":
      styleAttr = " style=\"" & style.replace("\n", "")

    for arg in args:
      case arg.kind
      of nnkStmtList:
        child = arg
      of nnkExprEqExpr:
        if $arg[0] == "style":
          styleAttr = styleAttr & $arg[1]
        else:
          attributes.add(" " & $arg.repr)
      of nnkCall:
        attributes.add(" " & $arg.repr)
      else:
        discard

    if style != "":
      styleAttr.add("\"")

    let formattedTag = astToStr(tag).replace("`", "")
    let tagType = getTagType(formattedTag)
    var tagStr: string
    var closeTagStr: string

    if tagType == "composite":
      tagStr = "<" & formattedTag & styleAttr & attributes & ">"
      closeTagStr = "</" & formattedTag & ">"

      result = newStmtList(
        newCall("add", ident("result"), newLit(tagStr)),
        child,
        newCall("add", ident("result"), newLit(closeTagStr))
      )

    elif tagType == "atomic":
      tagStr = "<" & formattedTag & styleAttr & attributes & ">"
      closeTagStr = "</" & formattedTag & ">"

      result = newStmtList(
        newCall("add", ident("result"), newLit(tagStr)),
        newCall("add", ident("result"), newCall("$", child)),
        newCall("add", ident("result"), newLit(closeTagStr))
      )

    elif tagType == "void":
      tagStr = "<" & formattedTag & styleAttr & attributes & "/>"

      result = newStmtList(newCall("add", ident("result"), newLit(tagStr)))

    else:
      result = newStmtList(newCall("add", ident("result"), newLit(tagStr)))

styled(StyledImg, img): """
  background-color: #000;
  width: 100px;
"""

styled(StyledH1, h1): """
  color: #f7d;
  font-size: 40px;
  font-weight: 600;
"""

styled(StyledButton, button): """
  background-color: #eee;
  width: 200px;
  height: 50px;
  border: 1px solid #000;
  border-radius: 8px;
  font-weight: 600;
"""

styled(body, body)
styled(button, button)
styled(dv, `div`)
styled(h1, h1)
styled(img, img)

styled(StyledDiv, `div`): """
  background-color: #eee;
  padding: 24px;
  border-radius: 20px;
"""

proc handleClick() =
  echo "I am a button click"

type
  MyComponentProps = object of RootObj
    key: string

let props = MyComponentProps(key: "HELLO WORLD")

component[MyComponentProps](MyComponent):
  StyledH1(id = 1, style = "color: #000;"):
    props.key
  StyledButton(onclick=handleClick()):
    "Click me!"

component[void](MyOtherComponent):
  StyledDiv:
    MyComponent(props)
    StyledH1(id=2): "Hello another world"

    StyledImg(
      src="img_girl.jpg",
      alt="Girl in a jacket"
    )

    dv:
      h1: "hello world a third time"
      button(onclick=handleClick()):
        "Click me too!"

html app:
  body:
    MyOtherComponent

echo app()
