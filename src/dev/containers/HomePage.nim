import times, strutils

import ../../ntml

import ../types

var counter: int

component[HomePageProps] HomePage:
  script:
    let isAddSection: bool = true
    let currentTime: int = epochTime().toInt()

    proc getCounter(): int =
      counter

    proc setCounter(newCounter: int) =
      counter = newCounter

    proc handleAlert() =
      alert(window, "This is a custom alert")

    proc handleClick() =
      setCounter(counter + 1)
      let buttonElement = getElementById("rerender_button")
      buttonElement.innerHTML = cstring("Clicked button " & getCounter().intToStr() & " times")

    setCounter(props.counter)

  `div`:
    `div`:
      `div`(style="margin-top: 32px;"):
        h1: props.title
        button(id="rerender_button", onclick=handleClick()):
          "Clicked button " & getCounter().intToStr() & " times"
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
