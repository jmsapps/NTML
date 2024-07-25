type
  NtmlTagKind* = enum
    `img`,
    `h1`,
    `button`,
    `body`,
    `div`,
    `li`,
    `ul`

  NtmlElementKind* = enum
    `voidElement`,
    `atomicElement`,
    `compositeElement`

  NtmlStyleArg* = object of RootObj
    ifCond*: string
    thenCond*: string
    elseCond*: string
