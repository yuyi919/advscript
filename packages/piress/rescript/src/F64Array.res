open Js.TypedArray2

module Make = () => {
  type t = Float64Array.t
  let fromLength = Float64Array.fromLength
  let fromBufferRange = Float64Array.fromBufferRange

  @inline
  let get = (array, index): Shared.f64 => {
    // if index > array->Float64Array.length {
    //   Js.Exn.raiseRangeError("")
    // }
    array->Float64Array.unsafe_get(index)
  }

  @inline
  let set = (array, index, v: Shared.f64) => {
    // if index > array->Float64Array.length {
    //   Js.Exn.raiseRangeError("")
    // }
    array->Float64Array.unsafe_set(index, v)
  }

  @inline
  let plusplus = (array, index) => {
    // if index > array->Float64Array.length {
    //   Js.Exn.raiseRangeError("")
    // }
    array->Float64Array.unsafe_set(index, array->Float64Array.unsafe_get(index) +. 1.)
  }

  @inline
  let minusminus = (array, index) => {
    // if index > array->Float64Array.length {
    //   Js.Exn.raiseRangeError("")
    // }
    array->Float64Array.unsafe_set(index, array->Float64Array.unsafe_get(index) -. 1.)
  }

  @inline
  let plus = (array, index, v: Shared.f64) => {
    // if index > array->Float64Array.length {
    //   Js.Exn.raiseRangeError("")
    // }
    array->Float64Array.unsafe_set(index, array->Float64Array.unsafe_get(index) +. v)
  }

  @inline
  let grow_to = (array, index, v: Shared.f64) => {
    // if index > array->Float64Array.length {
    //   Js.Exn.raiseRangeError("")
    // }
    if v > array->get(index) {
      array->Float64Array.unsafe_set(index, v)
    }
  }

  @inline
  let minus = (array, index, v: Shared.f64) => {
    // if index > array->Float64Array.length {
    //   Js.Exn.raiseRangeError("")
    // }
    array->Float64Array.unsafe_set(index, array->Float64Array.unsafe_get(index) -. v)
  }
}

include Make()
