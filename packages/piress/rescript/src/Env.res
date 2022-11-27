open Shared
open IEcs

type env = {
  @as("_gridSize") mutable gridSize: f64,
  @as("_yInterval") mutable yInterval: f64,
  @as("_xInterval") mutable xInterval: f64,
  @as("_spaceWidth") mutable spaceWidth: f64,
  @as("_maxRow") mutable maxRow: i32,
  @as("_maxCol") mutable maxCol: f64,
  @as("_letterSpacing") mutable letterSpacing: f64,
  @as("_forceSpace") mutable forceSpace: f64,
  @as("_maxWidth") mutable maxWidth: f64,
  @as("_paddingLeft") mutable paddingLeft: f64,
  @as("_hasLeftQuote") mutable hasLeftQuote: bool,
  @as("_firstChar") mutable firstChar: identifier,
  // @as("__INCOMPRESSIBLE") mutable _INCOMPRESSIBLE: array<int>,
  @as("_flag_STDWIDTH") mutable flag_STDWIDTH: bool,
  @as("_gridWidth") mutable gridWidth: f64,
}

@genType
type iTypographyCompressionOptions = {
  inlineCompression: bool,
  forceGridAlignment: bool,
  westernCharacterFirst: bool,
  forceSpaceBetweenCJKAndWestern: bool,
  fixCJKLeftQuote: bool,
}

@genType
type iTypographyBaseOptions = {
  wrapWidth?: f64,
  column: f64,
  row: i32,
  gridSize: f64,
  xInterval: f64,
  yInterval: f64,
  letterSpacing: f64,

  // ruby?: { source: string, target: string }[],
}

exception RangeError(string)

@inline
let first = arr => arr->Belt.Array.getUnsafe(0)
@inline
let initlize = () => {
  {
    // flag_INLINE_COMPRESSION: false,
    // forceGridAlignment: false,
    // westernCharacterFirst: false,
    // forceSpaceBetweenCJKAndWestern: false,
    // fixCJKLeftQuote: false,
    gridSize: 0.0,
    yInterval: 0.0,
    xInterval: 0.0,
    spaceWidth: 0.0,
    maxRow: 0,
    maxCol: 0.0,
    letterSpacing: 0.0,
    forceSpace: 0.0,
    maxWidth: 0.0,
    paddingLeft: 0.0,
    hasLeftQuote: false,
    firstChar: ElementIdentifier(0),
    // _INCOMPRESSIBLE: [],
    flag_STDWIDTH: false,
    gridWidth: 0.0,
  }
}

@inline
let update = (
  env,
  ~options,
  ~forceSpaceBetweenCJKAndWestern,
  ~firstChar,
  ~hasLeftQuote,
  ~paddingLeft,
) => {
  
  env.firstChar = firstChar
  env.hasLeftQuote = hasLeftQuote

  // if (!ECS.getCharacter(firstChar)) {
  //   throw Error(textSequence[0] + "" + textSequence.slice(0, 10))
  // }
  env.paddingLeft = paddingLeft

  // env.flag_INLINE_COMPRESSION = compressOptions.inlineCompression
  // env.forceGridAlignment = compressOptions.forceGridAlignment
  // env.westernCharacterFirst = compressOptions.westernCharacterFirst
  // env.forceSpaceBetweenCJKAndWestern = compressOptions.forceSpaceBetweenCJKAndWestern
  // env.fixCJKLeftQuote = compressOptions.fixCJKLeftQuote

  env.gridSize = options.gridSize

  env.forceSpace = forceSpaceBetweenCJKAndWestern ? env.gridSize /. 4.0 : 0.0

  env.spaceWidth = env.gridSize *. 0.35
  env.xInterval = options.xInterval
  env.yInterval = options.yInterval
  env.maxCol = options.column
  env.maxRow = options.row

  env.maxWidth = switch options.wrapWidth {
  | Some(value) => value
  | None => env.maxCol *. env.gridSize
  }

  env.letterSpacing = options.letterSpacing

  env.gridWidth = env.gridSize +. env.xInterval
  env
}

module type IEnv = {
  let env: env
}

module type IExtendable = {
  include IEnv
  module CompressOptions: ICompressOptions
}

module Extend = (Runtime: IExtendable) => {
  module CompressOptions = Runtime.CompressOptions
  let env = Runtime.env
  let compressOptions: iTypographyCompressionOptions = {
    inlineCompression: CompressOptions.inlineCompression,
    forceGridAlignment: CompressOptions.forceGridAlignment,
    westernCharacterFirst: CompressOptions.westernCharacterFirst,
    forceSpaceBetweenCJKAndWestern: CompressOptions.forceSpaceBetweenCJKAndWestern,
    fixCJKLeftQuote: CompressOptions.fixCJKLeftQuote,
  }
  @inline
  let initlize = (env, ~options, ~firstChar, ~hasLeftQuote, ~paddingLeft) =>
    env->update(
      ~options,
      ~forceSpaceBetweenCJKAndWestern=CompressOptions.forceSpaceBetweenCJKAndWestern,
      ~firstChar,
      ~hasLeftQuote,
      ~paddingLeft,
    )
}

module Initlize = (CompressOptions: ICompressOptions) => {
  let env = initlize()
  let compressOptions: iTypographyCompressionOptions = {
    inlineCompression: CompressOptions.inlineCompression,
    forceGridAlignment: CompressOptions.forceGridAlignment,
    westernCharacterFirst: CompressOptions.westernCharacterFirst,
    forceSpaceBetweenCJKAndWestern: CompressOptions.forceSpaceBetweenCJKAndWestern,
    fixCJKLeftQuote: CompressOptions.fixCJKLeftQuote,
  }
  @inline
  let initlize = (env, ~options, ~firstChar, ~hasLeftQuote, ~paddingLeft) =>
    env->update(
      ~options,
      ~forceSpaceBetweenCJKAndWestern=CompressOptions.forceSpaceBetweenCJKAndWestern,
      ~firstChar,
      ~hasLeftQuote,
      ~paddingLeft,
    )
}
