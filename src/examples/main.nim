import times, strutils

import ../ntml

script:
  let isAddSection: bool = true
  let currentTime: int = epochTime().toInt()

  proc handleAlert() =
    alert(window, "You created a custom script tag")

component[void] HomePage:
  `div`:
    `div`:
      `div`:
        h1: "Title 1"
        ul:
          for item in @["Item 1", "Item 2", "Item 3"]:
            li: item
      if isAddSection:
        `div`:
          h1: "Title 2"
          ul:
            for item in @["Item 1", "Item 2", "Item 3"]:
              li: item
      `div`:
        h1: "About"
        p: "This is some placeholder text for the about section..."
        p: "More information goes here in a placeholder format..."
        p: "Even more placeholder details to fill out the page..."
        p: "Additional placeholder text to complete this section..."
        p: "Final placeholder statement about the section..."
      `div`:
        h1:
          "Contact us"
        button(onclick=handleAlert()):
          "Click me"
  `div`:
    ul:
      for i in @["this", "is", "a", "list"]:
        li: i
    `div`:
      if currentTime mod 2 == 0:
        "even seconds: " & currentTime.intToStr()
      else:
        "odd seconds: " & currentTime.intToStr()

ntml App:
  HomePage

render App()

when defined(js):
  echo "Compiling for JavaScript"

elif defined(c):
  echo "Compiling for C"
  writeFile("index.html", App())

else:
  echo "Compiling for another target"

echo App()
