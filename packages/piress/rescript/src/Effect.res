@inline
let tapIf = (v, fn) => {
  v ? fn()->Pipe.return(true) : false
}
@inline
let pipeIf = (v, fn) => {
  v ? fn() : v
}
@inline
let pipeIfFalse = (v, fn) => {
  !v ? fn() : v
}

// @inline
// let whenSome = (v, fn, b) => {
//   switch v {
//   | Continue((true, v)) => Continue((true, v->fn))
//   | Continue((false, v)) => Continue((false, b))
//   }
// }
// @inline
// let whenNone = (v, fn, b) => {
//   switch v {
//   | Continue((true, v)) => Continue((true, b))
//   | Continue((false, v)) => Continue((false, v->fn))
//   }
// }
