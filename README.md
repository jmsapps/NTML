# NTML

## Project Overview

NTML is a Nim-based framework for building HTML elements and styles using a custom DSL (Domain Specific Language). It allows you to define reusable components, conditionally apply styles, and dynamically generate content using embedded Nim code.

## Key Features

- **Component-Based Design**: Create reusable components with a straightforward `component` macro.
- **Dynamic Scripting**: Embed Nim scripting within HTML for dynamic behavior using the `script` keyword.
- **HTML DSL**: Define HTML structures directly in Nim with clean and intuitive syntax.

## Example Usage

Here is an example demonstrating how to create a reusable component with dynamic behavior and embedded scripting:

```nim
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

  `div`(
    class="__read-me-container"
  ):
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
```

Output:

```html
<style>
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
</style>
<div class="__read-me-container">
   <h1 style="text-decoration:underline">NTML Example</h1>
   <div>
      <button onclick=handleAlert()>Click me to display an alert</button>
      <ul>
         <li>NTML</li>
         <li>IS</li>
         <li>VERY</li>
         <li>GREAT!!!</li>
      </ul>
      <p style="color:rgb(0, 18, 221)">Even seconds: 2024-12-30 15:00:40</p>
   </div>
</div>
```
