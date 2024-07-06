import
  macros

type
  NtmlNodeType = enum
    fragmentNode,
    h1Node,
    pNode,
    divNode

  NtmlElementType = enum
    elementNode,
    textNode

  NtmlProp = object of RootObj
    key: string
    value: string

  NtmlElement = object of RootObj
    nodeType: NtmlNodeType
    props: seq[NtmlProp]

    case kind: NtmlElementType
    of elementNode:
      children: seq[NtmlElement]
    of textNode:
      child: string

macro generateNtml(tree: untyped): untyped =
  proc processNtml(tree: NimNode): NimNode =
    case tree.kind:
    of nnkStmtList:
      var fragmentChildren = newSeq[NimNode]()

      for branch in tree:
        fragmentChildren.add(processNtml(branch))

      result = nnkObjConstr.newTree(
        newIdentNode("NtmlElement"),
        nnkExprColonExpr.newTree(
          newIdentNode("nodeType"),
          newIdentNode("fragmentNode")
        ),
        nnkExprColonExpr.newTree(
          newIdentNode("props"),
          nnkPrefix.newTree(
            newIdentNode("@"),
            nnkBracket.newTree()
          )
        ),
        nnkExprColonExpr.newTree(
          newIdentNode("kind"),
          newIdentNode("elementNode")
        ),
        nnkExprColonExpr.newTree(
          newIdentNode("children"),
          nnkPrefix.newTree(
            newIdentNode("@"),
            nnkBracket.newTree(fragmentChildren)
          )
        )
      )

    of nnkCall:
      var ntmlElement: NimNode
      var props = newSeq[NimNode]()
      var children = newSeq[NimNode]()
      var child = ""
      var nodeType: NtmlNodeType
      var elementType: NtmlElementType

      for branch in tree:
        if branch.kind == nnkIdent:
          case $branch
          of "dv":
            nodeType = divNode
            elementType = elementNode
          of "h1":
            nodeType = h1Node
            elementType = textNode
          of "p":
            nodeType = pNode
            elementType = textNode

        elif branch.kind == nnkExprEqExpr:
          props.add(
            nnkObjConstr.newTree(
              newIdentNode("NtmlProp"),
              nnkExprColonExpr.newTree(
                newIdentNode("key"),
                newLit($branch[0])
              ),
              nnkExprColonExpr.newTree(
                newIdentNode("value"),
                newLit($branch[1])
              )
            )
          )

        elif branch.kind == nnkStmtList and elementType == elementNode:
          children.add(processNtml(branch))

        elif branch.kind == nnkStmtList and elementType == textNode:
          for leaf in branch:
            child.add($leaf)

      return nnkObjConstr.newTree(
        newIdentNode("NtmlElement"),
        nnkExprColonExpr.newTree(
          newIdentNode("nodeType"),
          newIdentNode($nodeType)
        ),
        nnkExprColonExpr.newTree(
          newIdentNode("props"),
          nnkPrefix.newTree(
            newIdentNode("@"),
            nnkBracket.newTree(props)
          )
        ),
        nnkExprColonExpr.newTree(
          newIdentNode("kind"),
          newIdentNode($elementType)
        ),
        case elementType
        of elementNode:
          nnkExprColonExpr.newTree(
            newIdentNode("children"),
            nnkPrefix.newTree(
              newIdentNode("@"),
              nnkBracket.newTree(children)
            )
          )
        of textNode:
          nnkExprColonExpr.newTree(
            newIdentNode("child"),
            newLit(child)
          )
      )

    else:
      # empty fragment
      return nnkObjConstr.newTree(
        newIdentNode("NtmlElement"),
        nnkExprColonExpr.newTree(
          newIdentNode("nodeType"),
          newIdentNode("fragmentNode")
        ),
        nnkExprColonExpr.newTree(
          newIdentNode("props"),
          nnkPrefix.newTree(
            newIdentNode("@"),
            nnkBracket.newTree()
          )
        ),
        nnkExprColonExpr.newTree(
          newIdentNode("kind"),
          newIdentNode("elementNode")
        ),
        nnkExprColonExpr.newTree(
          newIdentNode("children"),
          nnkPrefix.newTree(
            newIdentNode("@"),
            nnkBracket.newTree()
          )
        )
      )

  return processNtml(tree)

let generatedNtml = generateNtml:
  dv(id = "1", style = "color: #000;"):
    h1(id = "2"): "hello"
    p: "world"

echo generatedNtml
