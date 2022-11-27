include Js.Array2

@inline
let first = arr => arr->unsafe_get(0)
@inline
let last = arr => arr->unsafe_get(arr->length - 1)
@inline
let get = (arr, i) => arr->unsafe_get(i)
@inline
let set = (arr, i, v) => arr->unsafe_set(i, v)
