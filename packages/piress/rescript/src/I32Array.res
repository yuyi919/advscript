open Js.TypedArray2

module Make = () => {
  type t = Int32Array.t

  let fromLength = Int32Array.fromLength
  let fromBufferRange = Int32Array.fromBufferRange

  @inline
  let get = (array, index) => {
    array->Int32Array.unsafe_get(index)
  }
  @inline
  let set = (array, index, v) => {
    array->Int32Array.unsafe_set(index, v)
  }
  @inline
  let plusplus = (array, index) => {
    array->Int32Array.unsafe_set(index, array->Int32Array.unsafe_get(index) + 1)
  }
  @inline
  let minusminus = (array, index) => {
    array->Int32Array.unsafe_set(index, array->Int32Array.unsafe_get(index) - 1)
  }
  @inline
  let plus = (array, index, v) => {
    array->Int32Array.unsafe_set(index, array->Int32Array.unsafe_get(index) + v)
  }
  @inline
  let grow_to = (array, index, v: Shared.i32) => {
    if v > array->get(index) {
      array->Int32Array.unsafe_set(index, v)
    }
  }
  @inline
  let minus = (array, index, v) => {
    array->Int32Array.unsafe_set(index, array->Int32Array.unsafe_get(index) - v)
  }
}

include Make()
