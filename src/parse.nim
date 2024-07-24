
import strutils

import types, errors

proc parseCss*(css: string): (string, seq[NtmlStyleArg]) =
  var styleArgs: seq[NtmlStyleArg]
  var nimBlock = ""
  var cssBlock = css

  if ":ncss" in cssBlock:
    try:
      let ifCount = cssBlock.count("IF ")
      let thenCount = cssBlock.count("THEN ")
      let elseCount = cssBlock.count("ELSE ")
      let endCount = cssBlock.count("END")

      if ifCount != thenCount or thenCount != elseCount or elseCount != endCount:
        raise newException(
          SyntaxError, "mismatch of count for 'IF', 'THEN', 'ELSE', 'END' statements in \'\n" &
          cssBlock & "\'"
        )

      if ifCount == 0 and thenCount == 0 and elseCount == 0 and endCount == 0:
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
        let ifStart = part.find("IF ") + 3
        let thenStart = part.find("THEN ") + 5
        let elseStart = part.find("ELSE ") + 5

        let ifPart = part[ifStart ..< part.find("THEN")].strip()
        let thenPart = part[thenStart ..< part.find("ELSE")].strip()
        let elsePart = part[elseStart .. ^1].strip()

        styleArgs.add(NtmlStyleArg(
          ifCond: ifPart,
          thenCond: thenPart,
          elseCond: elsePart
        ))

    except SyntaxError as e:
      cssBlock = "background-color: #E90909 !important; "
      echo "SyntaxError: ", e.msg

  result = (
    cssBlock.replace("\n", "").replace(" ", "").replace(":ncss", "").replace("${}$", ""),
    styleArgs
  )
