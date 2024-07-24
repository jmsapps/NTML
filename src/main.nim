
import macros, strutils

import htmlElements, styled

import types

# MAIN
template html*(name: untyped, children: untyped) =
  proc `name`*(): string =
    result = "<html>"
    children
    result.add("</html>")

template component*[T](name: untyped, children: untyped) =
  macro `name`*(props: T) =
    # result = newTree(nnkStmtList, parseStmt(astToStr(children)))
    quote do:
      children

# EXAMPLE
styled(StyledDiv, `div`): """
  padding: 24px;

  :ncss  ${
    IF isBorder THEN border: 1px solid #000; border-radius: 20px; ELSE VOID END
    IF bgColor THEN background-color: bgColor; ELSE background-color: #FFF; END

    IF isHideOnHover
    THEN
      :hover {
        opacity: 0;
      }
    ELSE VOID
    END
  }$
"""

type
  MyProp = object
    text: string

component[MyProp](MyComponent):
  StyledDiv(
    bgColor="#eee",
    isBorder,
    isHideOnHover,
    style="margin-top: 100px;",
    class="myclass"
  ):
    h1: "HELLO WORLD"

html app:
  body:
    MyComponent(MyProp(text:"HELLO WORLD"))

echo app()
