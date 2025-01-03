import macros

type H1Attr = object
  id: string
  style: string

proc constructH1Attr(args: seq[NimNode]): H1Attr =
  var idValue: NimNode
  var styleValue: NimNode

  for arg in args:
    if arg.kind == nnkExprEqExpr:
      let key = $arg[0]  # Key as a string
      let value = arg[1] # Value node
      case key:
      of "id":
        if value.kind == nnkStrLit:
          idValue = value
          echo "id: ", $value
        else:
          error("Invalid type for 'id', expected a string")
      of "style":
        if value.kind == nnkStrLit:
          styleValue = value
          echo "style: ", $value
        else:
          error("Invalid type for 'style', expected a string")
      else:
        error("Unknown attribute: " & key)
    else:
      error("Unknown attribute for h1 tag: " & arg.repr)
  # Return an AST representation of the H1Attr object

  result = H1Attr(id: $`idValue`, style: $`styleValue`)

proc validateAttr(attr: H1Attr) =
  echo attr.repr

macro h1*(args: varargs[untyped]) =
  var attrs: seq[NimNode]

  for arg in args:
    if arg.kind == nnkExprEqExpr:
      attrs.add(arg)

  validateAttr(constructH1Attr(attrs))

# Usage
h1(id = "1", style = "h"):
  "hello world"
