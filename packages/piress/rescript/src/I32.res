open Shared

@inline
let div2 = (v: int) => v->unsafe_cast / 2
@inline
let mul2 = v => v * 2
@inline
let mul = (v, mul) => v * mul
@inline
let div = (v, div) => v / div
@inline
let minusminus = v => v - 1
@inline
let plusplus = v => v + 1
@inline
let diff = (v, v2) => v - v2
@inline
let sub = (v, v2) => v - v2
@inline
let rev_sub = (v2, v) => sub(v, v2)
@inline
let add = (v, v2) => v +. v2

let ceil = Js.Math.floor_int
