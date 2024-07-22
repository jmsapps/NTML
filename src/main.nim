
import macros, strutils

import types

proc getNtmlElementKind(ntmlTagKind: NtmlTagKind): NtmlElementKind =
  case ntmlTagKind
  of
    `img`:
      result = `voidElement`
  of
    `h1`,
    `button`:
      result = `atomicElement`
  of
    `body`,
    `div`:
      result = `compositeElement`

template html*(name: untyped, children: untyped) =
  proc `name`*(): string =
    result = "<html>"
    children
    result.add("</html>")

template component*[T](name: untyped, children: untyped) =
  macro `name`*(props: T) =
    quote do:
      children

template styled*(name: untyped, ntmlTagKind: NtmlTagKind, style: string = "") =
  macro `name`*(args: varargs[untyped]): untyped =
    var children: NimNode
    var attributes = ""

    var styleAttr = ""
    if style != "":
      styleAttr = " style=\"" & style.replace("\n", "")

    for arg in args:
      case arg.kind
      of nnkStmtList:
        children = arg
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

    let ntmlElementKind = getNtmlElementKind(ntmlTagKind)
    let formattedTag = astToStr(ntmlTagKind).replace("`", "")
    var openTagStr: string
    var closeTagStr: string

    case ntmlElementKind
    of `compositeElement`:
      openTagStr = "<" & formattedTag & styleAttr & attributes & ">"
      closeTagStr = "</" & formattedTag & ">"

      result = newStmtList(
        newCall("add", ident("result"), newLit(openTagStr)),
        children,
        newCall("add", ident("result"), newLit(closeTagStr))
      )

    of `atomicElement`:
      openTagStr = "<" & formattedTag & styleAttr & attributes & ">"
      closeTagStr = "</" & formattedTag & ">"

      result = newStmtList(
        newCall("add", ident("result"), newLit(openTagStr)),
        newCall("add", ident("result"), newCall("$", children)),
        newCall("add", ident("result"), newLit(closeTagStr))
      )

    of `voidElement`:
      openTagStr = "<" & formattedTag & styleAttr & attributes & "/>"

      result = newStmtList(newCall("add", ident("result"), newLit(openTagStr)))

styled(StyledImg, `img`): """
  background-color: #000;
  width: 100px;
"""

styled(StyledH1, `h1`): """
  color: #f7d;
  font-size: 40px;
  font-weight: 600;
"""

styled(StyledButton, `button`): """
  background-color: #eee;
  width: 200px;
  height: 50px;
  border: 1px solid #000;
  border-radius: 8px;
  font-weight: 600;
"""

styled(body, `body`)
styled(button, `button`)
styled(dv, `div`)
styled(h1, `h1`)
styled(img, `img`)

styled(StyledDiv, `div`): """
  background-color: #eee;
  padding: 24px;
  border-radius: 20px;
"""

proc handleClick() =
  echo "I am a button click"

component[void](MyComponent):
  StyledDiv:
    h1: "hello world a third time"
    button(onclick=handleClick()):
      "Click me too!"

html app:
  body:
    MyComponent

echo app()
