open IEcs

@inline
let unbox = ids =>
  switch ids {
  | ElementIdentifiers(ids) => ids
  }

@inline
let first = ids => ids->unbox->ArrayUtil.first
@inline
let get = (ids, i) => ids->unbox->ArrayUtil.get(i)

@inline
let unboxCompressed = ids =>
  switch ids {
  | CompressedCharIdentifiers(ids) => ids
  }
