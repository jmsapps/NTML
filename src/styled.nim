
import macros, strutils

import parse, get

import types

template styled*(name: untyped, ntmlTagKind: NtmlTagKind, style: string = "") =
  macro `name`*(args: varargs[untyped]): untyped =
    var children: NimNode
    var attributes = ""
    var includedStyleArgs: seq[(NtmlStyleArg, string)]
    var unincludedStyleArgs: seq[NtmlStyleArg]
    var inlineStyles = ""

    var styleAttr = " style=\""
    let (parsedCss, cssStyleArgs) = parseCss(style)
    if parsedCss != "":
      styleAttr = styleAttr & parsedCss

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
      of nnkIdent:
        var found = false

        for styleArg in cssStyleArgs:
          if styleArg.ifCond == $arg:
            includedStyleArgs.add((styleArg, ""))
            found = true
            break

        if not found:
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
      if arg.elseCond != "VOID":
        styleAttr.add(arg.elseCond)

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
