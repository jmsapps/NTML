
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
  template `name`*(props {.inject.}: T) =
    `children`
