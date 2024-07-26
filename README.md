# NTML

## Project Overview

NTML is a work-in-progress Nim-based framework for building HTML elements and styling them using a custom DSL (Domain Specific Language). It includes the ability to define components with styled elements and conditional styling rules.

## Key Features

- **Component-Based Architecture**: Define reusable components using a custom `component` macro.
- **Styled Components**: Apply styles conditionally using a custom syntax with `styled`.
- **HTML DSL**: Create HTML elements with embedded Nim code for dynamic content generation.

## Example Usage

Below is an example demonstrating the creation of a styled component with conditional styles:

```nim
styled(StyledDiv, `div`): """
  padding: 24px;

  :ncss ${
    IF isBorder THEN border: 1px solid #000; border-radius: 20px; ELSE VOID END
    IF bgColor THEN background-color: bgColor; ELSE background-color: #FFF; END
    IF isBigFont THEN font-size: 30px; ELSE VOID END
  }$
"""

type MyProp = object
  text: string
  items: seq[string]

component[MyProp](MyComponent):
  StyledDiv(bgColor="#eee", isBorder, isBigFont, style="margin-top: 100px;", class="myclass"):
    h1(style="text-decoration: underline"): props.text
    ul:
      for i in props.items:
        li: i

html app:
  body:
    MyComponent(MyProp(
      text:"HELLO WORLD",
      items: @["Nim", "is very", "GREAT!!!"]
    ))
```

## License

This project is currently private and in development. For inquiries, please contact the project author.
