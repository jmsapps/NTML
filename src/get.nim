import types

proc getNtmlElementKind*(ntmlTagKind: NtmlTagKind): NtmlElementKind =
  case ntmlTagKind
  of
    `img`:
      result = `voidElement`
  of
    `h1`,
    `button`:
      result = `atomicElement`
  of
    `body`,
    `div`:
      result = `compositeElement`
