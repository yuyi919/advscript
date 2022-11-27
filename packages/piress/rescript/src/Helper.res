open Shared

@inline
let getOffsetXFromFixCjkQuote = (
  ~flag_STDWIDTH,
  ~fixCJKLeftQuote,
  ~lastIsPunctuation,
  ~charFontSize,
  ~charCode,
  ~charWidth,
) => {
  // 这里假设引号永远是在 em 格左侧的。fix 指修复一些并非在左侧时的情况。
  let offset: f64 =
    !lastIsPunctuation && ElementType.isCjkLeftQuote(charCode) ? charFontSize->F64.div2 : 0.0
  switch fixCJKLeftQuote {
  | true
    if ElementType.isCjkLeftQuote(charCode) && (!flag_STDWIDTH || charWidth === charFontSize) =>
    offset->F64.diff(charFontSize->F64.div2)
  | _ => offset
  }
}

module type IForceGridAlignment = {
  @inline
  let getOffsetX: (
    IContext.context,
    ~currentX_before: Shared.f64,
    ~isMultLine: bool,
    ~startElementIndex: Shared.i32,
    ~endElementIndex: Shared.i32,
    ~allowPangu: bool,
  ) => Shared.f64

  @inline
  let consumeOffsetX: IContext.context => unit

  @inline
  let buffOffsetX: (IContext.context, ~fontSize: Shared.f64, ~overflow: bool) => unit
}

module MakeForceGridAlignment = (Runtime: IContext.IRuntime) => {
  module Context = IContext.MakeContext(Runtime)
  module LoggerOption = {
    let logger = Logger.compactLogger
    let debugger = Runtime.CompressOptions.debugger
  }
  module Logger = Logger.MakeLogger(LoggerOption)
  module ECS = Runtime
  module Pipe = Pipe.Use(Runtime.CompressOptions)

  let env = Runtime.env

  @inline
  let processOffset = (context: Context.t, ~start, ~end, ~offset, ~isMultLine) => {
    let {source} = context
    if !isMultLine && offset > 0.0 {
      Logger.debug1("currentX_offset", offset)
      for i in start to end {
        source->ElementIdentifiers.get(i)->ECS.action(ECS.addX(_, offset))->ignore
      }
    }
  }

  @inline
  let pipeOffset = (
    context: Context.t,
    ~isMultLine,
    ~start,
    ~end,
    ~currentX,
    ~currentX_before,
    ~forceSpace,
    allow,
  ) =>
    context->processOffset(
      ~start,
      ~end,
      ~offset=allow
        ? F64.diff(currentX, currentX_before)->F64.add(forceSpace)->F64.div2->F64.sub(forceSpace)
        : (currentX -. currentX_before) /. 2.,
      ~isMultLine,
    )

  @inline
  let getOffsetX = (
    context: Context.t,
    ~currentX_before,
    ~isMultLine,
    ~startElementIndex,
    ~endElementIndex,
    ~allowPangu,
  ) => {
    let {forceSpace} = env
    let gridWidth = env.gridWidth

    currentX_before
    ->F64.div(gridWidth)
    ->F64.ceil
    ->Pipe.action(x => Context.setCurrentX(context, x))
    ->compute(_ => context->Context.getCurrentCol *. gridWidth)
    ->Pipe.tap(() => Logger.debug("forceGridAlignment"))
    ->compute(currentX =>
      switch allowPangu {
      | true if currentX < currentX_before +. forceSpace =>
        context
        // 两端总余量不足 0.5em 时，增加 1em 宽度
        ->Context.consumeCol(1.0)
        ->return(currentX +. gridWidth)
        ->Pipe.action(
          pipeOffset(
            context,
            ~isMultLine,
            ~start=startElementIndex,
            ~end=endElementIndex,
            ~currentX=_,
            ~currentX_before,
            ~forceSpace,
            true,
          ),
        )
      | false if currentX < currentX_before =>
        context
        // 两端总余量不足 0.5em 时，增加 1em 宽度
        ->Context.consumeCol(1.0)
        ->return(currentX +. gridWidth)
        ->Pipe.action(
          pipeOffset(
            context,
            ~isMultLine,
            ~start=startElementIndex,
            ~end=endElementIndex,
            ~currentX=_,
            ~currentX_before,
            ~forceSpace,
            false,
          ),
        )
      | _ => currentX
      }
    )
  }

  @inline
  let consumeOffsetX = (context: Context.t) => {
    let offsetX = context.buf_offsetX
    if offsetX !== 0.0 {
      offsetX
      ->Pipe.action(Logger.debug1("consumeOffsetX", _))
      ->Pipe.pipeIfConst(offsetX > env.gridSize, offsetX => {
        // 当正好在行首时, 两边空格全部加到一边，可能使得总宽度大于1em，此时应该删去多出的1em宽度
        context->Context.rollbackCol(1.0)->ignore
        offsetX -. env.gridSize
      })
      ->Context.consumeXIn(context)
      ->ignore
    }
  }

  @inline
  let buffOffsetX = (context: Context.t, ~fontSize, ~overflow) => {
    let {gridWidth, gridSize} = env
    if fontSize !== gridSize {
      Logger.debug("gridAlignment")
      // 强制网格对齐
      let offset_x = (fontSize -. gridSize) /. 2.0 // 初始向右偏移
      context.buf_offsetX =
        context
        ->Context.consumeCol(offset_x > 0.0 ? F64.ceil(offset_x *. 2.0 /. gridWidth) : 0.0)
        ->Pipe.pipe(context => {
          let offset_x =
            offset_x
            ->F64.mul2
            ->F64.div(gridWidth)
            ->F64.ceil
            ->F64.plusplus
            ->F64.mul(gridWidth)
            ->F64.diff(fontSize)
            ->F64.div2
          context
          ->Context.consumeX(offset_x)
          ->return(overflow ? context->Context.lineWrap->return(offset_x)->F64.mul2 : offset_x)
        })
    }
  }
}
module type ICompress = {
  let process: (
    IContext.context,
    ~charCode: int,
    ~charFontSize: float,
    ~charWidth: float,
    ~currentIsPunctuation: bool,
    ~isEOL: bool,
    ~isValidEndChar: bool,
  ) => IContext.context
  let processUncompress: (IContext.context, ~currentIsPunctuation: bool) => unit
  let fixCjkLeftQuote: (
    float,
    ~context: IContext.context,
    ~charFontSize: float,
    ~charCode: int,
    ~charWidth: float,
  ) => float
}
module MakeCompress = (Runtime: IContext.IRuntime): ICompress => {
  module CompressOptions = Runtime.CompressOptions
  module Context = IContext.MakeContext(Runtime)
  module LoggerOption = {
    let logger = Logger.compactLogger
    let debugger = Runtime.CompressOptions.debugger
  }
  module Logger = Logger.MakeLogger(LoggerOption)
  module ECS = Runtime
  module Pipe = Pipe.Use(Runtime.CompressOptions)

  let env = Runtime.env

  // @inline
  let isCompressableChar = char => {
    switch char->Char.unsafe_chr {
    | '⁇'
    | '‼'
    | '…'
    | '—'
    | '⸺'
    | '～' => false
    | _ => true
    }
  }
  @inline
  let checkCompressable = (charCode, ~currentIsPunctuation, ~isEOL, ~isValidEndChar) => {
    switch isCompressableChar(charCode) {
    | true if isEOL && isValidEndChar => EOLCompression
    | true if CompressOptions.inlineCompression && currentIsPunctuation => InlineCompression
    | _ => NoCompression
    }
  }

  // @inline
  let process = (
    context,
    ~charCode,
    ~charFontSize,
    ~charWidth,
    ~currentIsPunctuation,
    ~isEOL,
    ~isValidEndChar,
  ) =>
    // 判断是否进行压缩，并更新位置
    switch charCode->checkCompressable(~currentIsPunctuation, ~isEOL, ~isValidEndChar) {
    | EOLCompression =>
      //! 行尾压缩
      context
      ->Context.consumeX(charFontSize /. 2.0)
      ->Context.consumeCol(0.5)
      ->Pipe.tapIf(
        @inline context => mod_float(context->Context.getCurrentCol, 1.0) !== 0.5,
        Context.needForceWrap,
      )
    | InlineCompression =>
      //! 行内压缩 暂不启用
      //   context->Context.getCurrentX +=
      //     charWidth - charFontSize / 2 + xInterval * +context.lastIsPunctuation
      //   context->Context.addCurrentCol( charWidth / charFontSize - 0.5)
      //   context.lastIsPunctuation = !context.lastIsPunctuation
      context
      ->Context.consumeX(charWidth +. env.xInterval)
      ->Context.consumeCol(charWidth /. charFontSize)
    | NoCompression =>
      //! 不压缩
      context
      ->Context.consumeX(charWidth +. env.xInterval)
      ->Context.consumeCol(charWidth /. charFontSize)
    }

  @inline
  let processUncompress = (context: Context.t, ~currentIsPunctuation) => {
    if CompressOptions.inlineCompression {
      if context.lastIsPunctuation && !currentIsPunctuation {
        context
        ->Context.consumeX(context.lastCharWidth /. 2.0 +. env.xInterval)
        ->Context.consumeCol(0.5)
        ->Context.lastIsNotPunctuation
        ->Context.finish
      }
    }
  }

  @inline
  let fixCjkLeftQuote = (currentX, ~context: Context.t, ~charFontSize, ~charCode, ~charWidth) =>
    currentX +.
    getOffsetXFromFixCjkQuote(
      ~flag_STDWIDTH=env.flag_STDWIDTH,
      ~fixCJKLeftQuote=CompressOptions.fixCJKLeftQuote,
      ~lastIsPunctuation=context.lastIsPunctuation,
      ~charFontSize,
      ~charCode,
      ~charWidth,
    )
}
