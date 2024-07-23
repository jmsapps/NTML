
import strutils

import types

proc parseCss*(css: string): (string, seq[NtmlStyleArg]) =
  var styleArgs: seq[NtmlStyleArg]
  var nimBlock = ""
  var cssBlock = css

  if ":nim" in cssBlock:
    try:
      var cssBlockStart = cssBlock.find(":nim")
      cssBlockStart = cssBlock.find("{", cssBlockStart)
      if cssBlockStart == -1:
        raise newException(ValueError, "Syntax error: '{' not found after ':nim'")

      let cssBlockEnd = cssBlock.find("}", cssBlockStart)
      if cssBlockEnd == -1:
        raise newException(ValueError, "Syntax error: '}' not found after '{'")

      if cssBlockStart != -1 and cssBlockEnd != -1:
        nimBlock = cssBlock[cssBlockStart+6..cssBlockEnd-2]
        cssBlock = cssBlock[0..cssBlockStart-1] & cssBlock[cssBlockEnd+1..^1]

      let singleLineNimBlock = nimBlock.replace("\n", "")

      for part in singleLineNimBlock.split("END"):
        if "IF " in part and "THEN " in part and "ELSE " in part:
          let ifStart = part.find("IF ") + 3
          let thenStart = part.find("THEN ") + 5
          let elseStart = part.find("ELSE ") + 5
          styleArgs.add(NtmlStyleArg(
            ifCond: part[ifStart ..< part.find("THEN")].strip(),
            thenCond: part[thenStart ..< part.find("ELSE")].strip(),
            elseCond: part[elseStart .. ^1].strip()
          ))
    except ValueError as e:
      cssBlock = ""
      echo "ValueError: ", e.msg
    except Exception as e:
      cssBlock = ""
      echo "General error: ", e.msg

  result = (cssBlock.replace("\n", "").replace(" ", "").replace(":nim", ""), styleArgs)
