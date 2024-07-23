type
  MyComponentProps* = object of RootObj
    key: string

  NtmlTagKind* = enum
    `img`,
    `h1`,
    `button`,
    `body`,
    `div`

  NtmlElementKind* = enum
    `voidElement`,
    `atomicElement`,
    `compositeElement`

  NtmlStyleArg* = object of RootObj
    ifCond*: string
    thenCond*: string
    elseCond*: string

  NtmlGlobalAttribute* = object of RootObj
    accesskey*: string
    class*: string
    contenteditable*: string
    `data-*`*: string
    dir*: string
    draggable*: string
    enterkeyhint*: string
    hidden*: bool
    id*: string
    inert*: bool
    inputmode*: string
    lang*: string
    popover*: string
    spellcheck*: string
    style*: string
    tabindex*: int
    title*: string
    translate*: string

  NtmlWindowEventAttribute* = object of RootObj
    onafterprint*: string
    onbeforeprint*: string
    onbeforeunload*: string
    onerror*: string
    onhashchange*: string
    onload*: string
    onmessage*: string
    onoffline*: string
    ononline*: string
    onpagehide*: string
    onpageshow*: string
    onpopstate*: string
    onresize*: string
    onstorage*: string
    onunload*: string

  NtmlFormEventAttribute* = object of RootObj
    onblur*: string
    onchange*: string
    oncontextmenu*: string
    onfocus*: string
    oninput*: string
    oninvalid*: string
    onreset*: string
    onsearch*: string
    onselect*: string
    onsubmit*: string

  NtmlKeyboardEventAttribute* = object of RootObj
    onkeydown*: string
    onkeypress*: string
    onkeyup*: string

  NtmlMouseEventAttribute* = object of RootObj
    onclick*: string
    ondblclick*: string
    onmousedown*: string
    onmousemove*: string
    onmouseout*: string
    onmouseover*: string
    onmouseup*: string
    onmousewheel*: string
    onwheel*: string

  NtmlDragEventAttribute* = object of RootObj
    ondrag*: string
    ondragend*: string
    ondragenter*: string
    ondragleave*: string
    ondragover*: string
    ondragstart*: string
    ondrop*: string

  NtmlClipboardEventAttribute* = object of RootObj
    oncopy*: string
    oncut*: string
    onpaste*: string

  NtmlMediaEventAttribute* = object of RootObj
    onabort*: string
    oncanplay*: string
    oncanplaythrough*: string
    ondurationchange*: string
    onemptied*: string
    onended*: string
    onerror*: string
    onloadeddata*: string
    onloadedmetadata*: string
    onloadstart*: string
    onpause*: string
    onplay*: string
    onplaying*: string
    onprogress*: string
    onratechange*: string
    onseeked*: string
    onseeking*: string
    onstalled*: string
    onsuspend*: string
    ontimeupdate*: string
    onvolumechange*: string
    onwaiting*: string

  NtmlBodyElement* = object of NtmlGlobalAttribute

  NtmlDivElement* = object of NtmlGlobalAttribute

  NtmlH1Element* = object of NtmlGlobalAttribute

  NtmlImgElement* = object of NtmlGlobalAttribute
    alt*: string
    crossorigin*: string
    height*: string
    ismap*: bool
    loading*: string
    longdesc*: string
    referrerpolicy*: string
    sizes*: string
    src*: string
    srcset*: string
    usemap*: string
    width*: string

  NtmlButtonElement* = object of NtmlGlobalAttribute
    autofocus*: bool
    disabled*: bool
    form*: string
    formaction*: string
    formenctype*: string
    formmethod*: string
    formnovalidate*: bool
    formtarget*: string
    popovertarget*: string
    popovertargetaction*: string
    name*: string
    `type`*: string
    value*: string
