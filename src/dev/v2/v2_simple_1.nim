
import dom

proc el*(tag: string, props: openArray[(string, string)] = [], children: varargs[Node]): Node =
  let element = document.createElement(tag)

  for (k, v) in props:
    if v.len > 0:
      element.setAttribute(cstring(k), cstring(v))

  for c in children:
    element.appendChild(c)

  return element


when isMainModule:
  let `div`: Node = el("div", [("id", "app"), ("class", "foo")],
      el("h1", [],
      [document.createTextNode("Hello, world!")]
    )
  )

  document.body.appendChild(`div`)
