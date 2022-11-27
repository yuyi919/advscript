open Shared

@genType.as("TextStyleFontStyle") @genType.import("piress-core-shared/helper")
type fontStyle = [#normal | #italic | #oblique]

@genType.as("TextStyleFontVariant") @genType.import("piress-core-shared/helper")
type fontVariant = [#normal | #"small-caps"]

@genType.as("TextStyleFontWeight") @genType.import("piress-core-shared/helper")
type fontWeight = [
  | #normal
  | #bold
  | #bolder
  | #lighter
]

type fontCache = {
  @as("_fontStyle")
  mutable fontStyle: i32,
  @as("_fontVariant")
  mutable fontVariant: i32,
  @as("_fontWeight")
  mutable fontWeight: i32,
  @as("_fontSize")
  mutable fontSize: f64,
  @as("_fontFamily")
  mutable fontFamily: i32,
  @as("_font")
  mutable font: string,
  @as("_fontHash")
  mutable fontHash: f64,
  @as("_option_id")
  mutable option_id: i32,
  // mutable buf: Js.TypedArray2.Uint8Array.t,
}

let cache = {
  fontStyle: 0,
  fontVariant: 0,
  fontWeight: 0,
  fontSize: 0.0,
  fontFamily: 0,
  font: "",
  fontHash: 0.0,
  option_id: 0,
  // buf: Js.TypedArray2.Uint8Array.from(Belt.Array.make(80, 32)->unsafe_cast),
}

// type textEncoder
// type textDecoder
// @new external createTextEncoder: unit => textEncoder = "TextEncoder"
// @send external encode: (textEncoder, string) => Js.Typed_array.Uint8Array.t = "encode"
// @new external createTextDecoder: unit => textDecoder = "TextDecoder"
// @send external decode: (textDecoder, Js.Typed_array.Uint8Array.t) => string = "decode"
// let textEncoder = createTextEncoder()
// let textDecoder = createTextDecoder()

// let uint_store: Js.Dict.t<array<int>> = Js.Dict.fromArray([
//   ("normal", textEncoder->encode("normal")->unsafe_cast),
// ])

module Exports: {
  let measureTextWidth: (
    string,
    ~fontStyle: fontStyle,
    ~fontVariant: fontVariant,
    ~fontWeight: fontWeight,
    ~fontSize: Shared.f64,
    ~fontFamily: string,
    ~letterSpacing: float,
  ) => (float, string)
} = {
  let const_number = "number"
  let const_normal = #normal

  let cache_options = Js.Dict.fromArray([(const_normal->unsafe_cast, 0)])
  let cache_measure = Js.Dict.fromArray([("", 0.0)])
  let cache_fontStr = Js.Dict.fromArray([("", "")])

  Js.log3(cache_options, cache_measure, cache_fontStr)

  @inline
  let unsafe_get = (store, key: 'key) => store->Js.Dict.unsafeGet(key->unsafe_cast)
  @inline
  let unsafe_set = (store, key, v) => store->Js.Dict.set(key->unsafe_cast, v)->return(v)
  @inline
  let us_get = (key: 'a) => cache_options->unsafe_get(key)

  let get = (key: 'a) => {
    if us_get(key)->Js.typeof == const_number {
      us_get(key)
    } else {
      let r = cache.option_id + 1
      cache_options->Js.Dict.set(key->unsafe_cast, r)
      cache.option_id = r
      r
    }
  }

  @inline
  let withEnum = (get, key: 'a) =>
    if key == const_normal || key->unsafe_cast == "" {
      0
    } else {
      get(key)
    }
  let getEnum = withEnum(get, _)
  let us_getEnum = withEnum(us_get, _)

  @inline
  let isUpdated = (
    ~fontStyle: fontStyle,
    ~fontVariant: fontVariant,
    ~fontWeight: fontWeight,
    ~fontSize: f64,
    ~fontFamily: string,
  ) =>
    !(
      fontStyle->us_getEnum == cache.fontStyle &&
      fontVariant->us_getEnum == cache.fontVariant &&
      fontWeight->us_getEnum == cache.fontWeight &&
      fontSize == cache.fontSize &&
      fontFamily->us_get == cache.fontFamily
    )

  // let result = (0.0, "")

  // // 复用元组结构
  // @inline
  // let unsafe_tuple = (a: float, b: string) => {
  //   result->unsafe_cast->ArrayUtil.set(0, a)
  //   result->unsafe_cast->ArrayUtil.set(1, b)
  //   result
  // }

  @inline
  let buildFontStr = (
    ~fontStyle: fontStyle,
    ~fontVariant: fontVariant,
    ~fontWeight: fontWeight,
    ~fontSize: f64,
    ~fontFamily: string,
  ) => {
    cache.font = if fontStyle == const_normal && fontVariant == const_normal {
      if fontWeight == const_normal {
        fontSize->unsafe_cast
      } else {
        fontWeight->unsafe_cast ++ " " ++ fontSize->unsafe_cast
      } ++ j`px $fontFamily`
    } else {
      fontStyle->unsafe_cast ++ j` $fontVariant $fontWeight ${fontSize->unsafe_cast}px $fontFamily`
    }
    // Js.log("build font")
    cache.font
  }

  @inline
  let getFontStr = (key: 'a, ~fontStyle, ~fontVariant, ~fontWeight, ~fontSize, ~fontFamily) => {
    if cache_fontStr->unsafe_get(key)->Js.typeof == const_number {
      cache_fontStr->unsafe_get(key)
    } else {
      cache_fontStr->unsafe_set(
        key,
        buildFontStr(~fontStyle, ~fontVariant, ~fontWeight, ~fontSize, ~fontFamily),
      )
    }
  }

  @inline
  let measureTextWidth = (
    text,
    ~fontStyle: fontStyle,
    ~fontVariant: fontVariant,
    ~fontWeight: fontWeight,
    ~fontSize: f64,
    ~fontFamily: string,
    ~letterSpacing,
  ) => {
    // 缓存的fontStr是否有变化
    let updated = isUpdated(~fontStyle, ~fontVariant, ~fontWeight, ~fontSize, ~fontFamily)
    let hash =
      text ++
      (if updated {
        cache.fontStyle = fontStyle->getEnum
        cache.fontVariant = fontVariant->getEnum
        cache.fontWeight = fontWeight->getEnum
        cache.fontSize = fontSize
        cache.fontFamily = fontFamily->get
        cache.fontHash =
          (cache.fontStyle->F64.unsafe *. 1000.0 +.
          cache.fontVariant->F64.unsafe *. 100.0 +.
          cache.fontWeight->F64.unsafe *. 10.0 +.
          cache.fontFamily->F64.unsafe) *. cache.fontSize
        cache.fontHash
      } else {
        cache.fontHash
      }->F64.unsafe *. (letterSpacing +. 1.0))->F64.unsafe_toString

    let _try = cache_measure->unsafe_get(hash)
    if _try->Js.typeof === const_number {
      (_try, cache_fontStr->unsafe_get(cache.fontHash))
    } else {
      let font = updated
        ? getFontStr(cache.fontHash, ~fontStyle, ~fontVariant, ~fontWeight, ~fontSize, ~fontFamily)
        : cache.font
      (cache_measure->unsafe_set(hash, Import.measureTextWidth(~text, ~font, ~letterSpacing)), font)
    }
  }
}
include Exports

@genType
let measureTextWidthU = (.
  text,
  fontStyle,
  fontVariant,
  fontWeight,
  fontSize,
  fontFamily,
  letterSpacing,
) =>
  Exports.measureTextWidth(
    text,
    ~fontStyle,
    ~fontVariant,
    ~fontWeight,
    ~fontSize,
    ~fontFamily,
    ~letterSpacing,
  )
