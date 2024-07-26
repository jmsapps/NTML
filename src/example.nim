import macros

import ntml, htmlElements, styled

import types

styled(StyledDiv, `div`): """
  padding: 24px;

  :ncss ${
    IF isBorder THEN border: 1px solid #000; border-radius: 20px; ELSE VOID END
    IF bgColor THEN background-color: bgColor; ELSE background-color: #FFF; END

    IF isBigFont
    THEN
      font-size: 30px;
    ELSE VOID
    END
  }$
"""

type
  MyProp = object
    text: string
    items: seq[string]

component[MyProp] MyComponent:
  StyledDiv(
    bgColor="#eee",
    isBorder,
    isBigFont,
    style="margin-top: 100px;",
    class="myclass"
  ):
    h1(style="text-decoration: underline"):
      props.text
    ul:
      for i in props.items:
        li: i

component[void] MyOtherComponent:
  StyledDiv:
    MyComponent(MyProp(
      text:"HELLO WORLD",
      items: @["Nim", "is very", "GREAT!!!"]
    ))

html app:
  body:
    MyOtherComponent

writeFile("index.html", app())

echo app()
