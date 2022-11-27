open Shared

@genType.as("IContext")
type context = {
  mutable _END: IEcs.identifier,
  @as("_currentX")
  mutable currentX: f64,
  @as("_currentY")
  mutable currentY: f64,
  @as("_currentCol")
  mutable currentCol: f64,
  @as("_currentRow")
  mutable currentRow: i32,
  // 判断上一个是否为标点，以此判断标点挤压
  @as("_lastIsPunctuation")
  mutable lastIsPunctuation: bool,
  @as("_isNeedForceWrap")
  mutable isNeedForceWrap: bool,
  @as("_lastCharWidth")
  mutable lastCharWidth: f64,
  @as("_contentWidth")
  mutable contentWidth: f64,
  @as("_contentHeight")
  mutable contentHeight: f64,
  @as("_currentRowHeight")
  mutable currentRowHeight: f64,
  @as("_compactWindowStart")
  mutable compactWindowStart: i32,
  @as("_compactWindowEnd")
  mutable compactWindowEnd: i32,
  @as("_lastIsWesternChar")
  mutable lastIsWesternChar: bool,
  @as("_source")
  mutable source: IEcs.elementIds,
  //
  // @as("_compactCtx")
  // compactCtx: compactContext,
  // 缓存
  @as("_buf_offsetX")
  mutable buf_offsetX: f64,
  @as("_prevChar")
  mutable prevChar: IEcs.identifier,
  @as("_cursor")
  mutable cursor: i32,
  // output
  @as("rows")
  mutable rows: IEcs.compressedIdentifiers,
}

type property =
  // F64
  | CURRENT_X
  | CURRENT_Y
  | CURRENT_COL
  | CURRENT_ROW_HEIGHT
  | CONTENT_WIDTH
  // I32
  | CURRENT_ROW

@genType.as("IResult")
type result = {
  mutable seqs: IEcs.compressedIdentifiers,
  // elements: IOutputElement[];
  mutable areaWidth: f64,
  mutable areaHeight: f64,
  mutable width: f64,
  mutable height: f64,
  mutable lastLineIndex: i32,
}

let _f64_store = F64Array.fromLength(64)
let _i32_store = I32Array.fromLength(64)

module type IStore = {
  let _f64_store: F64Array.t
  let _i32_store: I32Array.t

  let context: context
}

@inline
let initlize = () => {
  let ctx = {
    _END: ElementIdentifier(0),
    currentX: 0.0,
    currentY: 0.0,
    currentCol: 0.0,
    currentRow: 1,
    lastIsPunctuation: false,
    isNeedForceWrap: false,
    lastCharWidth: 0.0,
    contentWidth: 0.0,
    contentHeight: 0.0,
    currentRowHeight: 0.0,
    rows: CompressedCharIdentifiers([ElementIdentifier(0), ElementIdentifier(0)]),
    compactWindowStart: 0,
    compactWindowEnd: 0,
    lastIsWesternChar: false,
    source: ElementIdentifiers([]),
    //
    // compactCtx: {
    //   buffer_width: 0.0,
    //   wordStartElementIndex: 0,
    //   processingElement: 0,
    //   buffer_row: 0,
    //   prevIsSpace: false,
    //   processing: false,
    // },
    //
    buf_offsetX: 0.0,
    prevChar: ElementIdentifier(0),
    cursor: 0
  }
  ctx
}
module MakeStore = (): IStore => {
  let _f64_store = F64Array.fromLength(64)
  let _i32_store = I32Array.fromLength(64)

  let context = initlize()
}

module type IRuntime = {
  include Env.IEnv
  include IEcs.Visitor
  module CompressOptions: ICompressOptions
  module Store: IStore
}

module MakeContext = (Runtime: IRuntime) => {
  module F64Array = F64Array.Make()
  module I32Array = I32Array.Make()
  type t = context

  module LoggerOption = {
    let logger = Logger.logger
    let debugger = Runtime.CompressOptions.debugger
  }

  module Logger = Logger.MakeLogger(LoggerOption)
  module IEnv = Env.Extend(Runtime)
  module ECS = Runtime

  module CompressOptions = Runtime.CompressOptions
  module Pipe = Pipe.Use(CompressOptions)

  let env = Runtime.env
  let {context, _i32_store, _f64_store} = module(Runtime.Store)
  let _buf = {
    seqs: CompressedCharIdentifiers([]),
    areaWidth: 0.0,
    areaHeight: 0.0,
    width: 0.0,
    height: 0.0,
    lastLineIndex: 0,
  }

  @inline
  let _prop_f64 = property => {
    switch property {
    | CURRENT_X => 0
    | CURRENT_Y => 1
    | CURRENT_COL => 2
    | CURRENT_ROW_HEIGHT => 3
    | CONTENT_WIDTH => 4
    | _ => Js.Exn.raiseError("mistake property")
    }
  }

  @inline
  let _prop_i32 = property => {
    switch property {
    | CURRENT_ROW => 0
    | _ => Js.Exn.raiseError("mistake property")
    }
  }

  @inline
  let get_i32 = (p: property, _: context) => p->_prop_i32->I32Array.get(_i32_store, _)
  @inline
  let get_f64 = (p: property, _: context) => p->_prop_f64->F64Array.get(_f64_store, _)
  @inline
  let set_i32 = (p: property, ctx: context, v) =>
    p->_prop_i32->I32Array.set(_i32_store, _, v)->return(ctx)
  @inline
  let set_f64 = (p: property, ctx: context, v) =>
    p->_prop_f64->F64Array.set(_f64_store, _, v)->return(ctx)
  @inline
  let plus_i32 = (p: property, ctx: context, v) =>
    p->_prop_i32->I32Array.plus(_i32_store, _, v)->return(ctx)
  @inline
  let plus_f64 = (p: property, ctx: context, v) =>
    p->_prop_f64->F64Array.plus(_f64_store, _, v)->return(ctx)
  @inline
  let minus_f64 = (p: property, ctx: context, v) =>
    p->_prop_f64->F64Array.minus(_f64_store, _, v)->return(ctx)
  @inline
  let grow_to_f64 = (p: property, ctx: context, v) =>
    p->_prop_f64->F64Array.grow_to(_f64_store, _, v)->return(ctx)

  @inline
  let setContentWidth = (context, width) => {
    context.contentWidth = width
    context
    // set_f64(CONTENT_WIDTH, context, width)
  }

  @inline
  let getContentWidth = context => {
    context.contentWidth
    // get_f64(CONTENT_WIDTH, context)
  }

  @inline
  let setCurrentX = (context, x) => {
    context.currentX = x
    context
    // set_f64(CURRENT_X, context, x)
  }

  @inline
  let getCurrentX = context => {
    // get_f64(CURRENT_X, context)
    context.currentX
  }

  @inline
  let setCurrentY = (context, y) => {
    context.currentY = y
    context
    // set_f64(CURRENT_Y, context, y)
  }

  @inline
  let getCurrentY = context => {
    // context.contentHeight = height
    context.currentY
    // get_f64(CURRENT_Y, context)
  }

  @inline
  let setRowHeight = (context, rowHeight) => {
    // context.contentHeight = height
    // context
    set_f64(CURRENT_ROW_HEIGHT, context, rowHeight)
  }

  @inline
  let getRowHeight = context => {
    get_f64(CURRENT_ROW_HEIGHT, context)
  }

  @inline
  let setCurrentCol = (context, col) => {
    // context.contentHeight = height
    // context
    set_f64(CURRENT_COL, context, col)
  }
  @inline
  let setCurrentColU = (context, col) => setCurrentCol(context, col)->ignore

  @inline
  let getCurrentCol = context => {
    get_f64(CURRENT_COL, context)
  }

  @inline
  let setCurrentRow = (context, row) => {
    // context.contentHeight = height
    // context
    set_i32(CURRENT_ROW, context, row)
  }

  @inline
  let getCurrentRow = context => {
    get_i32(CURRENT_ROW, context)
  }

  @inline
  let finish: t => unit = _ => ()

  @inline
  let syncContentWidth = context => {
    // %raw("/* syncContentWidth */0")->ignore
    // grow_to_f64(CONTENT_WIDTH, context, context->getCurrentX)
    if context->getCurrentX > context->getContentWidth {
      setContentWidth(context, context->getCurrentX)->ignore
    }
    context
  }

  // if context->getCurrentX > context->getContentWidth {
  //   setContentWidth(context, context->getCurrentX)
  // } else {
  //   context
  // }

  // 更新行高
  @inline
  let growRowHeight = (context: t, elementHeight) => {
    // %raw("/* growRowHeight */0")->ignore
    // grow_to_f64(CURRENT_ROW_HEIGHT, context, elementHeight)
    if elementHeight > context->getRowHeight {
      setRowHeight(context, elementHeight)->ignore
    }
    context
  }

  @inline
  let resetCurrent = context => {
    // %raw("/* resetCurrent */0")->ignore
    context->setCurrentX(0.0)->setCurrentY(0.0)->setCurrentCol(0.0)->setCurrentRow(1)
  }

  @inline
  let rollbackX = (context: t, x) => {
    // context->setCurrentX(context->getCurrentX -. x)
    // minus_f64(CURRENT_X, context, x)
    context.currentX = context.currentX -. x
    context
  }
  @inline
  let consumeX = (context: t, x) => {
    // %raw("/* consumeX */0")->ignore
    // context->setCurrentX(context->getCurrentX +. x)
    Logger.debug3("consumeX: %o + %o => %o", context->getCurrentX, x, context->getCurrentX +. x)

    // plus_f64(CURRENT_X, context, x)

    context.currentX = context.currentX +. x
    context
  }

  @inline
  let consumeXIn = (x, context) => consumeX(context, x)->return(x)

  @inline
  let growCurrentY = (context: t, y) => {
    // plus_f64(CURRENT_Y, context, y)
    context.currentY = context.currentY +. y
    context
    // context->setCurrentY(context->getCurrentY +. y)
  }

  @inline
  let rollbackCol = (context: t, col) => {
    minus_f64(CURRENT_COL, context, col)
    // context->setCurrentCol(context->getCurrentCol -. col)
  }

  @inline
  let consumeCol = (context: t, col) => {
    plus_f64(CURRENT_COL, context, col)
    // context->setCurrentCol(context->getCurrentCol +. col)
  }
  @inline
  let consumeColU = (context, col) => consumeCol(context, col)->ignore

  @inline
  let growCurrentRow = context => {
    // %raw("/* growCurrentRow */0")->ignore
    context->growCurrentY(context->getRowHeight +. env.yInterval)->plus_i32(CURRENT_ROW, _, 1)
    // context->setCurrentRow(context->getCurrentRow + 1)
  }

  @inline
  let setLastCharWidth = (context: t, charWidth) => {
    context.lastCharWidth = charWidth
    context
  }

  @inline
  let lastIsPunctuation = context => {
    context.lastIsPunctuation = true
    context
  }

  @inline
  let lastIsNotPunctuation = context => {
    context.lastIsPunctuation = false
    context
  }

  @inline
  let needForceWrap = context => {
    context.isNeedForceWrap = true
    context
  }

  @inline
  let resetNeedForceWrap = context => {
    context.isNeedForceWrap = false
    context
  }

  @inline
  let recordLastElement = (context: t, char) => {
    context.rows->IEcs.unboxCompressedIds->Js.Array.unsafe_set(context->getCurrentRow, char)
  }

  @inline
  let getRowSize = context => {
    context.rows->IEcs.unboxCompressedIds->Array.length
  }

  @inline
  let prepare = (context: t, ~source, ~options) => {
    // %raw("/* prepare */0")->ignore
    let firstChar = source->ElementIdentifiers.first
    let hasLeftQuote = firstChar->ECS.out(ECS.getElementType)->ElementType.isLEFTQUOTE
    let paddingLeft = hasLeftQuote ? firstChar->ECS.out(ECS.getWidth) : 0.0
    let env = env->IEnv.initlize(~options, ~firstChar, ~hasLeftQuote, ~paddingLeft)

    context
    ->resetCurrent
    ->lastIsNotPunctuation
    // 存储一行字中的最大字号，用以确定真实行高
    ->setRowHeight(env.gridSize)
    ->setLastCharWidth(0.0)
    ->resetNeedForceWrap
    ->setContentWidth(0.0)
    // ->setContentHeight(0.0)
    ->Pipe.action(@inline context => {
      context.cursor = 0
      context.lastIsWesternChar = CompressOptions.westernCharacterFirst

      context.source = source
      context.rows = CompressedCharIdentifiers([firstChar, firstChar])
    })
    ->finish
    // ->Pipe.tap(() => Logger.debug1("prepare", context))
    Logger.debug1("prepare", context)
  }

  @inline
  let lineWrap = context => {
    Logger.log("lineWrap")
    %raw("/* lineWrap */0")->ignore
    /* lineWrap */
    context
    ->syncContentWidth
    ->setCurrentCol(0.0)
    ->setCurrentX(env.paddingLeft)
    ->growCurrentRow
    ->setRowHeight(env.gridSize)
    ->lastIsNotPunctuation
    ->setLastCharWidth(0.0)
    ->resetNeedForceWrap
    ->finish
  }

  @inline
  let flush = (context: t): result => {
    context->syncContentWidth->ignore
    let _result = _buf
    let lastLineIndex = context->getCurrentRow
    let overflowY = lastLineIndex > getRowSize(context) - 1
    // 如果移除后空行则删掉最后一行
    let contentHeight = overflowY
      ? context->getCurrentY
      : context->getCurrentY +. context->getRowHeight

    _result.seqs = context.rows
    _result.areaWidth = context->getContentWidth
    _result.areaHeight = contentHeight
    _result.width = env.maxWidth
    _result.height = contentHeight
    _result.lastLineIndex = overflowY ? lastLineIndex - 1 : lastLineIndex

    Logger.debug1(`contentHeight: %o`, contentHeight)

    // {
    //   seqs: context.rows,
    //   areaWidth: context->getContentWidth,
    //   areaHeight: contentHeight,
    //   width: env.maxWidth,
    //   height: contentHeight,
    //   lastLineIndex: overflowY ? lastLineIndex - 1 : lastLineIndex,
    // }
    _result
  }

  @inline
  let output = _ => {..._buf, seqs: _buf.seqs}
}
