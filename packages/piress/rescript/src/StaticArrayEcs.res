module Use = () => {
  open! IEcs
  open! Shared
  module F64 = F64Array.Make()
  module I32 = I32Array.Make()

  type t = i32
  type setting = {
    mutable _max: i32,
    mutable _max_id: i32,
    mutable _buff: Js.TypedArray2.ArrayBuffer.t,
    mutable _position: F64.t,
    mutable _font: F64.t,
    mutable _meta: I32.t,
    mutable _characters: array<string>,
    mutable _fontstr: array<string>,
  }

  let setting = {
    let _max = 1000
    let _buff = Js.TypedArray2.ArrayBuffer.make(_max * 4 * 8 + _max * 4 * 8 + _max * 2 * 4)
    {
      _max,
      _max_id: 1,
      _buff,
      _meta: I32.fromBufferRange(_buff, ~offset=0, ~length=_max * 2),
      _position: F64.fromBufferRange(_buff, ~offset=_max * 2 * 4, ~length=_max * 4),
      _font: F64.fromBufferRange(_buff, ~offset=_max * 2 * 4 + _max * 4 * 8, ~length=_max * 4),
      _characters: Belt.Array.make(_max, ""),
      _fontstr: Belt.Array.make(_max, ""),
    }
  }

  @inline
  let initlize = max => {
    let _max = max
    let _buff = Js.TypedArray2.ArrayBuffer.make(_max * 4 * 8 + _max * 4 * 8 + _max * 2 * 4)
    setting._max = max
    setting._buff = _buff
    setting._meta = I32.fromBufferRange(_buff, ~offset=0, ~length=_max * 2)
    setting._position = F64.fromBufferRange(_buff, ~offset=_max * 2 * 4, ~length=_max * 4)
    setting._font = F64.fromBufferRange(
      _buff,
      ~offset=_max * 2 * 4 + _max * 4 * 8,
      ~length=_max * 4,
    )
    setting._characters = Belt.Array.make(max, "")
    setting._fontstr = Belt.Array.make(max, "")
    // Js.log(setting)
  }

  @inline
  let grow = max => {
    if max > setting._max {
      initlize(max)
    }
    setting._max_id = 1
  }

  @inline @uncurry
  let unwrap = (id: IEcs.identifier): t => id->IEcs.unboxId

  @inline
  let _v_get = (char: t, prop: IEcs.element_key): f64 =>
    switch prop {
    | X => setting._position->F64.get(char * 4)
    | Y => setting._position->F64.get(char * 4 + 1)
    | Width => setting._position->F64.get(char * 4 + 2)
    | Height => setting._position->F64.get(char * 4 + 3)
    | FontSize => setting._font->F64.get(char * 4 + 4)
    }

  @inline
  let _v_set = (char: t, prop: IEcs.element_key, value: f64) =>
    switch prop {
    | X => setting._position->F64.set(char * 4, value)
    | Y => setting._position->F64.set(char * 4 + 1, value)
    | Width => setting._position->F64.set(char * 4 + 2, value)
    | Height => setting._position->F64.set(char * 4 + 3, value)
    | FontSize => setting._font->F64.set(char * 4 + 4, value)
    }

  @inline
  let v_get = (prop, char: t) => char->_v_get(prop)
  @inline
  let v_set = (prop, char: t, value) => {
    _v_set(char, prop, value)
    char
  }

  @inline
  let getCharacter: t => string = char => setting._characters->ArrayUtil.get(char)
  @inline
  let setCharacter = (char: t, str: string) => {
    setting._characters->ArrayUtil.set(char, str)
    char
  }
  @inline
  let setFont = (char, str) => {
    setting._fontstr->ArrayUtil.set(char, str)
    char
  }
  @inline
  let getFont: t => string = char => setting._fontstr->ArrayUtil.get(char)

  @inline
  let getCharCode: t => i32 = char => setting._characters->ArrayUtil.get(char)->charCodeAt(0)

  @inline
  let getElementType: t => ElementType.enums = char =>
    setting._meta->I32.get(char * 2 + 1)->Shared.unsafe_cast

  @inline
  let setElementType = (char: t, elementType: ElementType.enums) => {
    setting._meta->I32.set(char * 2 + 1, elementType->Shared.unsafe_cast)->ignore
    char
  }

  @inline
  let create = (~character, ~fontSize) => {
    let id = ElementIdentifier(setting._max_id)
    setting._max_id = setting._max_id + 1
    id
    ->unwrap
    ->v_set(X, _, 0.0)
    ->v_set(Y, _, 0.0)
    ->v_set(Width, _, 0.0)
    ->v_set(Height, _, 0.0)
    ->v_set(FontSize, _, fontSize)
    ->setCharacter(character)
    ->setElementType(ElementType.checkType(character))
    ->return(id)
  }


  @inline
  let input = ({character, fontSize}) => {
    create(~character, ~fontSize)
  }

  let _cursor = {
    x: 0.0,
    y: 0.0,
    width: 0.0,
    height: 0.0,
    fontSize: 0.0,
    character: "",
    elementType: ElementType.INVALID,
    font: ""
  }
  @inline
  let cursor = char => {
    let id = char->unwrap
    _cursor.x = v_get(X, id)
    _cursor.y = v_get(Y, id)
    _cursor.width = v_get(Width, id)
    _cursor.height = v_get(Height, id)
    _cursor.fontSize = v_get(FontSize, id)
    _cursor.character = getCharacter(id)
    _cursor.font = getFont(id)
    _cursor.elementType = getElementType(id)
    _cursor
  }

  @inline
  let output = char => {
    let id = char->unwrap
    {
      x: v_get(X, id),
      y: v_get(Y, id),
      width: v_get(Width, id),
      height: v_get(Height, id),
      fontSize: v_get(FontSize, id),
      character: getCharacter(id),
      font: getFont(id),
      elementType: getElementType(id),
    }
  }
}
