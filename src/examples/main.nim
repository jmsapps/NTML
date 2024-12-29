import ../ntml

html app:
  `div`:
    "hello world"

writeFile("index.html", app())

echo app()
