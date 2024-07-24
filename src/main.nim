
import macros

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
    quote do:
      children

# EXAMPLE
styled(StyledDiv, `div`): """
  padding: 24px;

  :nim  ${
    IF isBorder THEN border: 1px solid #000; border-radius: 20px; ELSE VOID END
    IF bgColor THEN background-color: bgColor; ELSE VOID END

    IF
      isHideOnHover
    THEN
      :hover {
        opacity: 0;
      }
    ELSE
      VOID
    END
  }$
"""

component[void](MyComponent):
  StyledDiv(bgColor="#eee", isBorder="", style="margin-top: 100px;", isHideOnHover=""):
    h1: "HELLO WORLD"

html app:
  body:
    MyComponent

echo app()
