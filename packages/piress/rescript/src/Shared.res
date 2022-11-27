@genType
type f64 = float
@genType
type i32 = int

external unwrap: option<'a> => 'a = "%identity"
external unsafe_cast: 'a => 'b = "%identity"

@inline
let return = (_, t) => t
@inline
let switchTo = (_, t) => t
@inline
let compute = (a, cb) => cb(a)
@inline
let switchWith = (_, cb) => cb()

@inline
let tap = (a, cb) => cb()->return(a)
@inline
let effect = (a, cb) => cb(a)->return(a)

type boolean = False | True

@unboxed
type scope<'a> = Pipe((boolean, 'a))

@inline
let charCodeAt = (str, int) => str->Js.String2.codePointAt(int)->unwrap
@inline
let charAt = (str, int) => str->charCodeAt(int)->Char.unsafe_chr

let test = Js.Re.test_

type compressType =
  | EOLCompression
  | InlineCompression
  | NoCompression

type loopStage =
  | Continue
  | Break

module type ICompressOptions = {
  let inlineCompression: bool
  let forceGridAlignment: bool
  let westernCharacterFirst: bool
  let forceSpaceBetweenCJKAndWestern: bool
  let fixCJKLeftQuote: bool

  let debugger: bool
}
