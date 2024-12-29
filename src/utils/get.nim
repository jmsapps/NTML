import ../types/index

proc getNtmlElementKind*(ntmlTagKind: NtmlTagKind): NtmlElementKind =
  case ntmlTagKind
  of
    `img`:
      result = `voidElement`
  of
    `h1`,
    `li`,
    `button`:
      result = `atomicElement`
  of
    `body`,
    `ul`,
    `div`:
      result = `compositeElement`
