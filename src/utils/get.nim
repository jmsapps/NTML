import ../types/index

proc getNtmlElementKind*(ntmlTagKind: NtmlTagKind): NtmlElementKind =
  case ntmlTagKind
  of
    `img`:
      result = `voidElement`
  of
    `button`,
    `h1`,
    `li`,
    `p`:
      result = `atomicElement`
  of
    `body`,
    `ul`,
    `div`:
      result = `compositeElement`
