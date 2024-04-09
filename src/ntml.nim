import macros, htmlgen, strutils, ntmlTags

macro ph(e: varargs[untyped]): untyped =
  ## Generates a placeholder `ph` element.
  result = xmlCheckedTag(e, "ph", commonAttr)

macro ntml(body: untyped): untyped =
  proc processNode(node: NimNode): NimNode =
    case node.kind
      of nnkStmtList, nnkStmtListExpr:
        var processedChildren = newSeq[NimNode]()
        for child in node:
          processedChildren.add(processNode(child))
        if processedChildren.len == 1:
          return processedChildren[0]
        else:
          return newCall("ph", processedChildren)

      of nnkCall:
        let callee = node[0]
        if $callee in ntmlTags.ntmlTags:
          var tagArgs: seq[NimNode] = @[]
          for arg in node[1..^1]:
            tagArgs.add(processNode(arg))

          var tag = case $callee
            of "dv": "div"
            else: $callee

          return newCall(tag, tagArgs)
        else:
          return node

      of nnkForStmt:
        var processedForBody = newSeq[NimNode]()
        let iterable = node[1]
        var tagArgs: seq[NimNode] = @[]
        var tag: string

        for arg in node[2]:
          if arg.kind == nnkCall:
            tag = $arg[0]
            for i in 1..<arg.len:
              if arg[i].kind == nnkExprEqExpr:
                tagArgs.add(arg[i])

        for elem in iterable:
          processedForBody.add(newCall(tag, tagArgs & newStrLitNode($elem)))

        return newCall("ph", processedForBody)

      else:
        return node

  proc sanitizeHTML(html: string): string =
    return html.replace("<ph>", "").replace("</ph>", "")

  let processedBody = processNode(body)

  result = quote do:
    sanitizeHTML(`processedBody`)

when isMainModule:
  let html1 = ntml:
    body:
      script:"""
        function myFunc() {
          alert('Button was clicked!');
        }
      """

      dv(id = "main-container"):
        h1(style = "color: #333; font-size: 24px;"): "Nim HTML Generator"
        p: "This is an example of generating HTML with sugary DSL syntax."

        dv(style = "border-radius: 20px; padding: 20px; background-color: #f0f0f0;"):
          p: "Nested div with background."
          ul(style = "padding: 0;"):
            for i in ["List Item 1", "List Item 2", "List Item 3"]:
              li(style = "margin: 0 0 10px 30px;"): i

        dv(style = "margin-top: 30px"):
          p: "Another paragraph in a separate div."
          a(href = "https://nim-lang.org", target = "_blank"): "Visit Nim's official website"

        button(style = "margin-top: 24px;", onclick="myFunc()"): "Click me!"

  let html2 =
    body(
      script("""
        function myFunc() {
          alert('Button was clicked!');
        }
      """),
      `div`(id="main-container",
        h1(style="color: #333; font-size: 24px;", "Nim HTML Generator"),
        p("This is an example of generating HTML with sugary DSL syntax."),
        `div`(style="border-radius: 20px; padding: 20px; background-color: #f0f0f0;",
          p("Nested div with background."),
          ul(style="padding: 0;",
            li(style="margin: 0 0 10px 30px;", "List Item 1"),
            li(style="margin: 0 0 10px 30px;", "List Item 2"),
            li(style="margin: 0 0 10px 30px;", "List Item 3")
          )
        ),
        `div`(style="margin-top: 30px",
          p("Another paragraph in a separate div."),
          a(href="https://nim-lang.org", target="_blank", "Visit Nim's official website")
        ),
        button(style = "margin-top: 24px;", onclick="myFunc()", "Click me!")
      )
    )

  assert html1 == html2
