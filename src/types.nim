type
  NtmlKind* = enum
    `img`,
    `h1`,
    `button`,
    `body`,
    `div`

  NtmlElementKind* = enum
    `voidElement`,
    `atomicElement`,
    `compositeElement`

  MyComponentProps* = object of RootObj
    key: string
