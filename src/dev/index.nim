import ../ntml

import ./containers/HomePage

import ./types

ntml App:
  HomePage(HomePageProps(
    title: "Page title",
    listItems: @["List item 1", "List item 2", "List item 3"],
    buttonText: "This is button text",
    counter: 0
  ))

render App()

when defined(js):
  echo "Compiling for JavaScript"

elif defined(c):
  echo "Compiling for C"

else:
  echo "Compiling for another target"

echo App()
