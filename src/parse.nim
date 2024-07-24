
import strutils

import types, errors

proc parseNcss*(css: string): (string, seq[NtmlStyleArg]) =
  var styleArgs: seq[NtmlStyleArg]
  var nimBlock = ""
  var cssBlock = css

  if ":ncss" in cssBlock:
    try:
      let singleLineCssBlock = cssBlock.replace("\n", "")
      let ifCount = singleLineCssBlock.count("IF ")
      let thenCount = singleLineCssBlock.count("THEN ")
      let elseCount = singleLineCssBlock.count("ELSE ")
      let endCount = singleLineCssBlock.count("END")

      if ifCount != thenCount or thenCount != elseCount or elseCount != endCount:
        raise newException(
          SyntaxError, "mismatch of count for 'IF', 'THEN', 'ELSE', 'END' statements in \'\n" &
          cssBlock & "\'"
        )

      if ifCount == 0 or thenCount == 0 or elseCount == 0 or endCount == 0:
        raise newException(
          SyntaxError, "at least one of 'IF', 'THEN', 'ELSE', 'END' statements required in \'\n" &
          cssBlock & "\'"
        )

      var cssBlockStart = cssBlock.find(":ncss")
      cssBlockStart = cssBlock.find("${", cssBlockStart)
      if cssBlockStart == -1:
        raise newException(SyntaxError, "Syntax error: '${' not found after ':ncss'")

      let cssBlockEnd = cssBlock.find("}$", cssBlockStart)
      if cssBlockEnd == -1:
        raise newException(SyntaxError, "Syntax error: '}$' not found after '${'")

      if cssBlockStart != -1 and cssBlockEnd != -1:
        nimBlock = cssBlock[cssBlockStart+6..cssBlockEnd-2]
        cssBlock = cssBlock[0..cssBlockStart+1] & cssBlock[cssBlockEnd..^1]

      let singleLineNimBlock = nimBlock.replace("\n", "").strip()

      for part in singleLineNimBlock.split("END"):
        let strippedPart = "\'" & part.replace("  ", " ").strip() & "\'"

        if "IF " in part and "THEN " in part and "ELSE " in part:
          let ifStart = part.find("IF ") + 3
          let thenStart = part.find("THEN ") + 5
          let elseStart = part.find("ELSE ") + 5

          let ifPart = part[ifStart ..< part.find("THEN")].strip()
          let thenPart = part[thenStart ..< part.find("ELSE")].strip()
          let elsePart = part[elseStart .. ^1].strip()

          if ifPart == "":
            raise newException(SyntaxError, "missing 'IF' condition in " & strippedPart)
          if thenPart == "":
            raise newException(SyntaxError, "missing 'THEN' condition in " & strippedPart)
          if elsePart == "":
            raise newException(SyntaxError, "missing 'ELSE' condition in " & strippedPart)

          styleArgs.add(NtmlStyleArg(
            ifCond: ifPart,
            thenCond: thenPart,
            elseCond: elsePart
          ))
        elif part.strip() != "":
          raise newException(SyntaxError, "'IF', 'THEN', and/or 'ELSE' missing in" & strippedPart)

    except SyntaxError as e:
      cssBlock = "background-color: #E90909 !important; "
      echo "SyntaxError: ", e.msg

  result = (
    cssBlock.replace("\n", "").replace(" ", "").replace(":ncss", "").replace("${}$", ""),
    styleArgs
  )
