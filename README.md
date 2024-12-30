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
type MyProps = object
  title: string
  listItems: seq[string]

script:
  let isRenderSection: bool = true
  let currentTime: int = epochTime().toInt()

  proc handleAlert() =
    alert(window, "You created a custom script tag")

component[MyProps](MyComponent):
  StyledDiv(bgColor="#eee", isBorder, isBigFont, style="margin-top: 100px;", class="myclass"):
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

render App()
