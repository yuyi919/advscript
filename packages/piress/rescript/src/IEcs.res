open Shared

@genType.as("ElementIdentifier") @genType.import("piress-core-shared/interface") @unboxed
type identifier = ElementIdentifier(i32)

@genType.as("ElementIdentifierList") @genType.import("piress-core-shared/interface") @unboxed
type elementIds = ElementIdentifiers(array<identifier>)

@genType.as("CompressedElementIdentifiers") @genType.import("piress-core-shared/interface") @unboxed
type compressedIdentifiers = CompressedCharIdentifiers(array<identifier>)

// @genType
// let outputIdentifiers = (ids: identifiers): array<i32> => {
//   unsafe_cast(ids)
// }

// @genType
// @inline
// let unboxId = id =>
//   switch id {
//   | ElementIdentifier(id) => id
//   }

// @genType
// @inline
// let getCompressedIdentifiers = ids =>
//   switch ids {
//   | CompressedCharIdentifiers(ids) => ids
//   }

@genType.as("ElementObject")
type element = {
  mutable fontSize: f64,
  mutable character: string,
  mutable elementType: ElementType.enums,
  mutable width: f64,
  mutable height: f64,
  mutable x: f64,
  mutable y: f64,
  mutable font: string,
}

@genType.opaque
type element_key =
  | Width
  | Height
  | X
  | Y
  | FontSize

@inline
let unboxId = id =>
  switch id {
  | ElementIdentifier(id) => id
  }
@inline
let isValid = id => id->unboxId > 0
@inline
let id2String = id =>
  switch id {
  | ElementIdentifier(id) => id->Js.Int.toString
  }

@inline
let unboxCompressedIds = ids =>
  switch ids {
  | CompressedCharIdentifiers(ids) => ids
  }
@genType
let outputIdentifiers = (ids: elementIds): array<i32> => {
  Shared.unsafe_cast(ids)
}
@genType @inline
let getCompressedIdentifiers = ids =>
  switch ids {
  | CompressedCharIdentifiers(ids) => ids
  }

module type Visitor = {
  type t
  // let v_get: (element_key, identifier) => f64
  // let v_set: (element_key, identifier, f64) => identifier
  let create: (~character: string, ~fontSize: f64) => identifier
  let getCharacter: t => string
  let setCharacter: (t, string) => t
  let getFont: t => string
  let setFont: (t, string) => t
  let getCharCode: t => i32
  let getElementType: t => ElementType.enums
  let getWidth: t => f64
  let getHeight: t => f64
  let getX: t => f64
  let getY: t => f64
  let getFontSize: t => f64
  let setW: (t, f64) => t
  let setH: (t, f64) => t
  let setX: (t, f64) => t
  let setY: (t, f64) => t
  let setFontSize: (t, f64) => t
  let addX: (t, f64) => t
  let setPosition: (t, f64, f64) => t
  let setSize: (t, f64, f64) => t

  let unwrap: identifier => t
  @uncurry @inline let action: (identifier, t => 'a) => identifier
  @uncurry @inline let out: (identifier, t => 'a) => 'a

  let input: element => identifier
  let cursor: identifier => element
  let output: identifier => element

  let grow: i32 => unit
  let initlize: i32 => unit
}

module type ModuleFunctor = {
  type t
  let unwrap: identifier => t
  let v_get: (element_key, t) => f64
  let v_set: (element_key, t, f64) => t
  // let v_get: (element_key, identifier) => f64
  // let v_set: (element_key, identifier, f64) => identifier
  let create: (~character: string, ~fontSize: f64) => identifier

  let getCharacter: t => string
  let setCharacter: (t, string) => t
  let getFont: t => string
  let setFont: (t, string) => t
  let getCharCode: t => i32
  let getElementType: t => ElementType.enums

  let input: element => identifier
  let cursor: identifier => element
  let output: identifier => element

  let grow: i32 => unit
  let initlize: i32 => unit
}

module Make = (ECS: ModuleFunctor): Visitor => {
  include ECS
  let getWidth: ECS.t => f64 = ECS.v_get(Width)
  let getHeight: ECS.t => f64 = ECS.v_get(Height)
  let getX: ECS.t => f64 = ECS.v_get(X)
  let getY: ECS.t => f64 = ECS.v_get(Y)
  let getFontSize: ECS.t => f64 = ECS.v_get(FontSize)

  let getCharacter = ECS.getCharacter(_)
  let getCharCode = ECS.getCharCode(_)
  let getElementType = ECS.getElementType(_)

  let setW: (ECS.t, f64) => ECS.t = ECS.v_set(Width)
  let setH: (ECS.t, f64) => ECS.t = ECS.v_set(Height)
  let setX: (ECS.t, f64) => ECS.t = ECS.v_set(X)
  let setY: (ECS.t, f64) => ECS.t = ECS.v_set(Y)
  let setFontSize: (ECS.t, f64) => ECS.t = ECS.v_set(FontSize)

  // F64.add(getX(_), _)=>
  @inline
  let addX = (id, x) => setX(id, getX(id)->F64.add(x))

  @inline
  let setPosition = (id, x, y) => {
    id->setX(x)->ignore
    id->setY(y)
  }

  @uncurry @inline
  let setSize = (id, w, h) => {
    id->setW(w)->ignore
    id->setH(h)
  }

  @uncurry @inline
  let action = (id, fn) => {
    id->ECS.unwrap->fn->ignore
    id
  }
  @uncurry @inline
  let out = (id, fn) => id->ECS.unwrap->fn
}

module type Adapter = {
  let create: (. ~character: string, ~fontSize: Shared.f64) => identifier
  let getCharacter: (. identifier) => string
  let getCharCode: (. identifier) => Shared.i32
  let getElementType: (. identifier) => ElementType.enums
  let getWidth: (. identifier) => Shared.f64
  let getHeight: (. identifier) => Shared.f64
  let getX: (. identifier) => Shared.f64
  let getY: (. identifier) => Shared.f64
  let getFontSize: (. identifier) => Shared.f64
  let setWidth: (. identifier, Shared.f64) => identifier
  let setHeight: (. identifier, Shared.f64) => identifier
  let setX: (. identifier, Shared.f64) => identifier
  let setY: (. identifier, Shared.f64) => identifier
  let addX: (. identifier, Shared.f64) => identifier
  let setFontSize: (. identifier, Shared.f64) => identifier
  let setPosition: (. identifier, Shared.f64, Shared.f64) => identifier
  let setSize: (. identifier, Shared.f64, Shared.f64) => identifier
  let input: (. element) => identifier
  let cursor: (. identifier) => element
  let output: (. identifier) => element

  let grow: (. i32) => unit
  let initlize: (. i32) => unit
}

module ExportEcs = (ECS: Visitor): Adapter => {
  open! ECS

  let create = (. ~character: string, ~fontSize: f64) => create(~character, ~fontSize)

  let getCharacter = (. id) => getCharacter(unwrap(id))
  let getCharCode = (. id) => getCharCode(unwrap(id))
  let getElementType = (. id) => getElementType(unwrap(id))
  let getWidth = (. id) => getWidth(unwrap(id))
  let getHeight = (. id) => getHeight(unwrap(id))
  let getX = (. id) => getX(unwrap(id))
  let getY = (. id) => getY(unwrap(id))
  let getFontSize = (. id) => getFontSize(unwrap(id))

  let setWidth = (. id, value) => setW(unwrap(id), value)->return(id)
  let setHeight = (. id, value) => setH(unwrap(id), value)->return(id)
  let setX = (. id, value) => setX(unwrap(id), value)->return(id)
  let setY = (. id, value) => setY(unwrap(id), value)->return(id)
  let addX = (. id, value) => addX(unwrap(id), value)->return(id)
  let setFontSize = (. id, value) => setFontSize(unwrap(id), value)->return(id)
  let setPosition = (. id, x, y) => setPosition(unwrap(id), x, y)->return(id)
  let setSize = (. id, width, height) => setSize(unwrap(id), width, height)->return(id)

  let input = (. t) => input(t)
  let cursor = (. t) => cursor(t)
  let output = (. t) => output(t)

  let initlize = (. t) => initlize(t)
  let grow = (. t) => grow(t)
}
