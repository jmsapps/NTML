type
  NtmlTagKind* = enum
    `body`,
    `button`,
    `div`,
    `h1`,
    `img`,
    `li`,
    `p`,
    `ul`,

  NtmlElementKind* = enum
    `voidElement`,
    `atomicElement`,
    `compositeElement`

  NtmlStyleArg* = object of RootObj
    ifCond*: string
    thenCond*: string
    elseCond*: string
