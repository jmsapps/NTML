import macros, strutils

import get

import types

template newHtmlElement(name: untyped) =
  macro `name`*(args: varargs[untyped]): untyped =
    var children: NimNode
    var attributes: string = ""

    for arg in args:
      case arg.kind
      of nnkStmtList:
        children = arg
      of nnkExprEqExpr:
        attributes.add(" " & $arg.repr.replace(" ", ""))
      else:
        children = newCall("add", ident("result"), newCall("$", arg))

    let ntmlElementKind: NtmlElementKind = getNtmlElementKind(name)
    let formattedTag: string = astToStr(name).replace("`", "")
    var openTagStr: string
    var closeTagStr: string

    case ntmlElementKind
    of `compositeElement`:
      openTagStr = "<" & formattedTag & attributes & ">"
      closeTagStr = "</" & formattedTag & ">"

      result = newStmtList(
        newCall("add", ident("result"), newLit(openTagStr)),
        children,
        newCall("add", ident("result"), newLit(closeTagStr))
      )

    of `atomicElement`:
      openTagStr = "<" & formattedTag & attributes & ">"
      closeTagStr = "</" & formattedTag & ">"

      result = newStmtList(
        newCall("add", ident("result"), newLit(openTagStr)),
        newCall("add", ident("result"), newCall("$", children)),
        newCall("add", ident("result"), newLit(closeTagStr))
      )

    of `voidElement`:
      openTagStr = "<" & formattedTag & attributes & "/>"

      result = newStmtList(newCall("add", ident("result"), newLit(openTagStr)))


newHtmlElement `img`
newHtmlElement `h1`
newHtmlElement `button`
newHtmlElement `body`
newHtmlElement `div`
newHtmlElement `ul`
newHtmlElement `li`
