import times, strutils

import ../ntml

import types

component[HomePageProps] HomePage:
  script:
    let isAddSection: bool = true
    let currentTime: int = epochTime().toInt()

    proc handleAlert() =
      alert(window, "This is a custom alert")

    proc handleClick() =
      echo props.buttonText

  `div`:
    `div`:
      `div`(style="margin-top: 32px;"):
        h1: props.title
        button(onclick=handleClick()):
          "Click me to print text"
        ul:
          for item in props.listItems:
            li: item

      if isAddSection:
        `div`:
          h1: "Title 2"
          ul:
            for item in props.listItems:
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
          "Click me to handle an alert"
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
  HomePage(HomePageProps(
    title: "Page title",
    listItems: @["List item 1", "List item 2", "List item 3"],
    buttonText: "This is button text"
  ))

render App()

when defined(js):
  echo "Compiling for JavaScript"

elif defined(c):
  echo "Compiling for C"

else:
  echo "Compiling for another target"

echo App()
