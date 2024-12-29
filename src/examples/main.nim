import ../ntml

component[void] Portal:
  `div`:
    ul:
      for i in @["1", "2"]:
        li: "hello world"
    `div`:
      if 1 == 2:
        "hello"
      else:
        "bye"

ntml App:
  Portal

writeFile("index.html", App())

echo App()
