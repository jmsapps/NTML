import times, strutils

import ../ntml

let isAddClientReviews: bool = false
let currentTime: int = epochTime().toInt()

component[void] HomePage:
  `div`:
    `div`:
      `div`:
        h1: "Featured properties"
        ul:
          li: "Property 1"
          li: "Property 2"
      if isAddClientReviews:
        `div`:
          h1: "Client reviews"
          ul:
            li: "Review 1"
            li: "Review 2"
      `div`:
        h1: "A little about me..."
        p: "With nearly two decades of experience as both a business owner and investor..."
        p: "Throughout the years, I’ve strategically invested in and managed a portfolio of rental properties..."
        p: "Beyond my professional pursuits, I am a devoted father to two beautiful daughters..."
        p: "Combining my personal experiences as a parent with my expertise as a business owner..."
        p: "Passion is the driving force behind all that I do..."
      `div`:
        h1:
          "Contact"
        button(onclick="handleAlert"):
          "Submit"
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


when defined(js):
  echo "Compiling for JavaScript"

  import dom

  proc handleAlert() =
    alert(window, cstring("Hello, this is a custom alert!"))

  {.emit: """function handleAlert() { window.alert('Hello, this is a custom alert!');}"""}

  proc renderApp() =
    let rootElement = document.createElement("div") # Create a container
    rootElement.innerHTML = App()                  # Insert the generated HTML
    document.body.appendChild(rootElement)         # Attach to the body

  # Run the rendering logic after DOMContentLoaded
  proc onDOMContentLoaded(e: Event) =
    renderApp()

  document.addEventListener("DOMContentLoaded", onDOMContentLoaded)


elif defined(c):
  echo "Compiling for C"
  writeFile("index.html", App())
else:
  echo "Compiling for another target"

echo App()
