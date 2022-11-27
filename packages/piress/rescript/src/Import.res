@module("piress-core-shared/helper/regexp") external cjk: Js.Re.t = "CJK"
@module("piress-core-shared/helper/regexp") external _WESTERN_END: Js.Re.t = "WESTERN_END"

@module("piress-core-shared/helper")
external measureTextWidth: (~text: string, ~font: string, ~letterSpacing: float) => float =
  "measureTextWidth"
