open! Js
open Shared

@genType.opaque
type enums =
  | INVALID
  | Char
  | Word
  | Space
  | EOL
  | COMMA
  | COLON
  | FULL_POINT
  | QUOTE_LEFT
  | QUOTE_RIGHT
  | QUOTE_COMMON
  | BRACKET_LEFT
  | BRACKET_RIGHT

// @inline
let checkCharCode = code => {
  switch code->Char.code {
  | 9 => Space
  | 10 => EOL
  | 13 => EOL
  | 32 => Space
  | 33 => FULL_POINT
  | 34 => QUOTE_COMMON
  | 39 => QUOTE_COMMON
  | 44 => COMMA
  | 46 => FULL_POINT
  | 58 => COLON
  | 59 => COLON
  | 63 => FULL_POINT
  | 8212 => FULL_POINT
  | 8216 => QUOTE_LEFT
  | 8217 => QUOTE_RIGHT
  | 8220 => QUOTE_LEFT
  | 8221 => QUOTE_RIGHT
  | 8230 => FULL_POINT
  | 8252 => FULL_POINT
  | 8263 => FULL_POINT
  | 11834 => FULL_POINT
  | 12288 => Space
  | 12289 => COMMA
  | 12290 => FULL_POINT
  | 12296 => BRACKET_LEFT
  | 12297 => BRACKET_RIGHT
  | 12298 => BRACKET_LEFT
  | 12299 => BRACKET_RIGHT
  | 12300 => QUOTE_LEFT
  | 12301 => QUOTE_RIGHT
  | 12302 => QUOTE_LEFT
  | 12303 => QUOTE_RIGHT
  | 12304 => BRACKET_LEFT
  | 12305 => BRACKET_RIGHT
  | 12308 => BRACKET_LEFT
  | 12309 => BRACKET_RIGHT
  | 12310 => BRACKET_LEFT
  | 12311 => BRACKET_RIGHT
  | 65281 => FULL_POINT
  | 65288 => BRACKET_LEFT
  | 65289 => BRACKET_RIGHT
  | 65292 => COMMA
  | 65294 => FULL_POINT
  | 65306 => COLON
  | 65307 => COLON
  | 65311 => FULL_POINT
  | 65339 => BRACKET_LEFT
  | 65341 => BRACKET_RIGHT
  | 65371 => BRACKET_LEFT
  | 65373 => BRACKET_RIGHT
  | 65374 => FULL_POINT
  | _ => Char
  }
}

@inline @genType
let checkType = (char: string) => {
  let type_ = char->charAt(0)->checkCharCode
  type_ === Char && (String.length(char) > 1 || !test(Import.cjk, char)) ? Word : type_
}

@inline
let testPrevCharIsWestern = char => Import._WESTERN_END->test(char)

@inline
let isWS = (_type: enums): bool => {
  switch _type {
  | Space => true
  | EOL => true
  | _ => false
  }
}

@inline
let isQUOTE = (_type: enums): bool => {
  switch _type {
  | QUOTE_COMMON => true
  | QUOTE_LEFT => true
  | QUOTE_RIGHT => true
  | _ => false
  }
}
@inline
let isLEFTQUOTE = (_type: enums): bool => {
  _type === QUOTE_LEFT
}

@inline
let isBRACKET = (_type: enums): bool => {
  switch _type {
  | BRACKET_LEFT => true
  | BRACKET_RIGHT => true
  | _ => false
  }
}

@inline
let checkValidEndChar = (_type: enums): bool => {
  switch _type {
  | EOL => true
  | COMMA => true
  | COLON => true
  | FULL_POINT => true
  | QUOTE_COMMON => true
  | QUOTE_RIGHT => true
  | BRACKET_RIGHT => true
  | _ => false
  }
}

@inline
let checkInvalidEndChar = (_type: enums): bool => {
  _type === QUOTE_LEFT || _type === BRACKET_LEFT || _type === Space
}

@inline
let isCjkLeftQuote = char => '“'->Char.code === char
