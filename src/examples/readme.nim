import times, strutils

import ../ntml

type MyProps = object
  title: string
  listItems: seq[string]

let isRenderSection: bool = true
let currentTime: int = epochTime().toInt()

script:
  proc handleAlert() =
    alert(window, "You created a custom script tag")

component[MyProps](MyComponent):
  `div`(style="margin-top: 100px;"):
    h1(style="text-decoration: underline"): props.title
    `div`:
      ul:
        for item in props.listItems:
          li: item
      if isRenderSection:
        p:
          if currentTime mod 2 == 0:
            "even seconds: " & currentTime.intToStr()
          else:
            "odd seconds: " & currentTime.intToStr()

# Render the app
ntml App:
  MyComponent(MyProps(
    title: "Dynamic Component",
    listItems: @["Item 1", "Item 2", "Item 3"]
  ))

echo App()
