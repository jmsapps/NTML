import times, strutils

import ../ntml

type MyProps = object
  title: string
  listItems: seq[string]

component[MyProps](MyComponent):
  style: """
    .__read-me-container {
      position: absolute;
      top: 0;
      bottom: 0;
      left: 0;
      right: 0;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
    }
  """

  script:
    proc handleAlert() =
      alert(window, "This is an NTML-generated alert!")

    let currentTime: int = epochTime().toInt()
    let formattedTime = format(now(), "yyyy-MM-dd HH:mm:ss")
    let isEvenSeconds: bool = formattedTime.split(":")[2].parseInt() mod 2 == 0

  `div`(class="__read-me-container"):
    h1(style="text-decoration: underline"): props.title
    `div`:
      button(onclick=handleAlert()):
        "Click me to display an alert"
      ul:
        for item in props.listItems:
          li: item
      if isEvenSeconds:
        p(style="color: rgb(0, 18, 221)"):
          "Even seconds: " & formattedTime
      else:
        p(style="color:rgb(221, 0, 0)"):
          "Odd seconds: " & formattedTime

ntml App:
  MyComponent(MyProps(
    title: "NTML Example",
    listItems: @["NTML", "IS", "VERY", "GREAT!!!"]
  ))

render App()
