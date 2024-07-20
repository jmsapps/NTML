import macros

template html(name: untyped, matter: untyped) =
  proc `name`(): string =
    result = "<html>"
    matter
    result.add("</html>")

template nestedTag(tag: untyped) =
  template `tag`(matter: untyped) =
    result.add("<" & astToStr(tag) & ">")
    matter
    result.add("</" & astToStr(tag) & ">")

template simpleTag(name: untyped, tag: untyped, style: string = "") =
  macro `name`(args: varargs[untyped]): untyped =
    echo args[0].kind
    var styleAttr = ""
    if style != "":
      styleAttr.add(" style=\"" & style & "\"")

    let tagStr = "<" & astToStr(tag) & styleAttr & ">"
    let closeTagStr = "</" & astToStr(tag) & ">"


    result = newStmtList(
      newCall("add", ident("result"), newLit(tagStr)),
      newCall("add", ident("result"), newCall("$", args[0])),
      newCall("add", ident("result"), newLit(closeTagStr))
    )


nestedTag body
simpleTag(StyledH1, h1,
  """
    color: #f7d;
    font-size: 40px;
    font-weight: 600;
  """
)

html mainPage:
  StyledH1:
    "hello world"

echo mainPage()
