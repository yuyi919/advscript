// open Js
// open Shared
// open IEcs

// type char_obj = {
//   mutable fontSize: f64,
//   character: string,
//   elementType: ElementType.enums,
//   mutable width: f64,
//   mutable height: f64,
//   mutable x: f64,
//   mutable y: f64,
// }
// let stack: array<char_obj> = []
// @inline
// let v_get_obj = id => stack->Array2.unsafe_get(id->IEcs.unboxId)
// @inline
// let v_get = (prop, id) => {
//   let char = id->v_get_obj
//   switch prop {
//   | Width => char.width
//   | Height => char.height
//   | X => char.x
//   | Y => char.y
//   | FontSize => char.fontSize
//   }
// }
// @inline
// let v_set = (prop, id, value) => {
//   let char = v_get_obj(id)
//   switch prop {
//   | Width => char.width = value
//   | Height => char.height = value
//   | X => char.x = value
//   | Y => char.y = value
//   | FontSize => char.fontSize = value
//   }
//   id
// }
// @inline
// let getCharacter: identifier => string = id => (id->v_get_obj).character
// @inline
// let getElementType: identifier => ElementType.enums = id => (id->v_get_obj).elementType

// @inline
// let create = (~character, ~fontSize) => {
//   let id = ElementIdentifier(stack->Array2.length)
//   stack
//   ->Array2.push({
//     character,
//     fontSize,
//     elementType: ElementType.checkType(character),
//     width: 0.0,
//     height: 0.0,
//     x: 0.0,
//     y: 0.0,
//   })
//   ->ignore
//   id
// }
