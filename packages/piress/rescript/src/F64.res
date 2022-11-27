open Shared
open Js

@inline
let div2 = v => v /. 2.0
@inline
let mul2 = v => v *. 2.0
@inline
let mul = (v, mul) => v *. mul
@inline
let div = (v, div) => v /. div
@inline
let div_ceil = (v, div) => Math.ceil_float(v /. div)
@inline
let minusminus = v => v -. 1.0
@inline
let plusplus = v => v +. 1.0
@inline
let diff = (v, v2) => v -. v2
@inline
let sub = (v, v2) => v -. v2
@inline
let rev_sub = (v2, v) => sub(v, v2)
@inline
let add = (v, v2) => v +. v2
@inline
let lessThan = (a: f64, b: f64) => a < b
@inline
let greaterThan = (a: f64, b: f64) => a > b
let ceil = Math.floor_float

@inline
let unsafe_toString: f64 => string = a => unsafe_cast(a)
@inline
let unsafe: 'a => f64 = a => unsafe_cast(a)
