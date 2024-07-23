
import macros, strutils

import parse, get

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

template styled*(name: untyped, ntmlTagKind: NtmlTagKind, style: string = "") =
  macro `name`*(args: varargs[untyped]): untyped =
    var children: NimNode
    var attributes = ""
    var includedStyleArgs: seq[(NtmlStyleArg, string)]
    var unincludedStyleArgs: seq[NtmlStyleArg]
    var inlineStyles = ""

    var styleAttr = ""
    let (parsedCss, cssStyleArgs) = parseCss(style)
    if parsedCss != "":
      styleAttr = " style=\"" & parsedCss

    for arg in args:
      case arg.kind
      # call and stmt list accounts for inline or new line children
      of nnkStmtList:
        children = arg
      of nnkCall:
        attributes.add(" " & $arg.repr)
      # attributes and style arguments
      of nnkExprEqExpr:
        let (key, value) = ($arg[0], $arg[1])
        var found = false

        for styleArg in cssStyleArgs:
          if styleArg.ifCond == key:
            includedStyleArgs.add((styleArg, value))
            found = true
            break

        if not found:
          if key == "style":
            inlineStyles.add(" " & value)
          else:
            attributes.add(" " & $arg.repr)
      else:
        discard

    for styleArg in cssStyleArgs:
      var isIncluded = false
      for included in includedStyleArgs:
        if styleArg == included[0]:
          isIncluded = true
          break

      if not isIncluded:
        unincludedStyleArgs.add(styleArg)

    for arg in includedStyleArgs:
      styleAttr.add(arg[0].thenCond.replace(arg[0].ifCond, arg[1]))

    for arg in unincludedStyleArgs:
      if arg.elseCond != "\'\'" and arg.elseCond != "void":
        styleAttr.add(arg.elseCond)

    if style != "":
      styleAttr.add(inlineStyles & "\"")

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

# EXAMPLE
styled(body, `body`)
styled(h1, `h1`)

styled(StyledDiv, `div`): """
  background-color: #eee; padding: 24px;
  :nim  {
    IF isBorder THEN border: 1px solid #000; border-radius: 20px; ELSE void END
    IF bgColor THEN background-color: bgColor; ELSE void END
  }
"""

component[void](MyComponent):
  StyledDiv(bgColor="#000", isBorder="", style="margin-top: 100px;"):
    h1: "hello world a third time"

html app:
  body:
    MyComponent

echo app()
