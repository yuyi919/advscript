open Shared
open IContext
open IEcs

@genType.as("ICompactContext")
type compact_context = {
  @as("_buffer_width")
  mutable buffer_width: f64,
  @as("_wordStartElementIndex")
  mutable wordStartElementIndex: i32,
  // word_end: i32,
  @as("_processingElement")
  mutable processingElement: i32,
  @as("_startElement")
  mutable startElement: i32,
  @as("_buffer_row")
  mutable buffer_row: i32,
  @as("_prevIsSpace")
  mutable prevIsSpace: bool,
  @as("_processing")
  mutable processing: bool,
  //
}

module MakeContext = (Runtime: IContext.IRuntime) => {
  module LoggerOption = {
    let logger = Logger.compactLogger
    let debugger = Runtime.CompressOptions.debugger
  }
  module Logger = Logger.MakeLogger(LoggerOption)
  module IEnv = Env.Extend(Runtime)
  module ECS = Runtime

  module CompressOptions = Runtime.CompressOptions

  module Context = IContext.MakeContext(Runtime)
  module ForceGridAlignment: Helper.IForceGridAlignment = Helper.MakeForceGridAlignment(Runtime)

  module Pipe = Pipe.Use(CompressOptions)

  let env = Runtime.env
  let ctx = {
    buffer_width: 0.0,
    wordStartElementIndex: 0,
    startElement: 0,
    processingElement: 0,
    buffer_row: 0,
    prevIsSpace: false,
    processing: false,
  }

  @inline
  let isProcessing = () => ctx.processing

  @inline
  let debug_get_characters = (context, start, end) =>
    if CompressOptions.debugger {
      context.source
      ->ElementIdentifiers.unbox
      ->ArrayUtil.slice(~start, ~end_=end)
      ->ArrayUtil.map(ECS.out(_, ECS.getCharacter))
    } else {
      []
    }

  @inline
  let buffWidth = (compactCtx, add) => {
    %raw("/* buffWidth */0")->ignore
    compactCtx.buffer_width = compactCtx.buffer_width +. add
    Logger.debug2("buffWidth += %o = %o", add, compactCtx.buffer_width)
    compactCtx
  }
  @inline
  let clearBuffWidth = compactCtx => {
    Logger.log("clear buffWidth")
    compactCtx.buffer_width = 0.0
    compactCtx
  }

  @inline
  let growRow = compactCtx => compactCtx.buffer_row = compactCtx.buffer_row + 1
  @inline
  let isMultipleRow = compactCtx => compactCtx.buffer_row !== 0

  @inline
  let endProcess = compactCtx => compactCtx.processing = false
  @inline
  let next = compactCtx => compactCtx.processingElement = compactCtx.processingElement + 1

  @inline
  let testPrevCharIsWestern = context =>
    context.prevChar->ECS.out(ECS.getCharacter)->ElementType.testPrevCharIsWestern

  @inline
  let processPanguBegin = context => {
    if context->Context.getCurrentX > 0.0 {
      context->Context.consumeX(env.forceSpace)->Context.finish
      // context->Context.consumeOffsetX( env.forceSpace)->ignore      }
    }
  }

  @inline
  let lineWrap = (compactCtx, ~context: context, ~buffer_width: f64) => {
    Logger.debug4(
      "lineWrap (buffer_width)%f + (currentX)%f = (overflowWidth)%f > (maxWidth)%f",
      buffer_width,
      context->Context.getCurrentX,
      buffer_width +. context->Context.getCurrentX,
      env.maxWidth,
    )
    // %raw("/* linewrap */0")->ignore
    context
    ->Context.rollbackX(env.spaceWidth)
    ->Context.syncContentWidth
    ->Context.setCurrentX(env.paddingLeft)
    ->Context.growCurrentRow
    ->ignore
    compactCtx->growRow

    if context->Context.getCurrentRow > env.maxRow {
      context.rows->ElementIdentifiers.unboxCompressed->ArrayUtil.pop->return(Break)
    } else {
      Continue
    }
  }

  @inline
  let loopPos = (context, wordEnd, i) => {
    for i in i to wordEnd {
      context.source
      ->ElementIdentifiers.get(i)
      ->ECS.action(target => {
        target
        ->ECS.setPosition(
          context->Context.getCurrentX,
          context->Context.getCurrentY -. ECS.getFontSize(target)->F64.diff(env.gridSize)->F64.div2,
        )
        ->Pipe.tapIfConst(ECS.getElementType(target) !== ElementType.Space, target => {
          Logger.log3(
            "add [%d] %o %o",
            context.source->ElementIdentifiers.get(i),
            ECS.getCharacter(target),
            ECS.getWidth(target),
          )
          context->Context.consumeX(ECS.getWidth(target) +. env.letterSpacing)
        })
      })
      ->ignore
    }
    context.source->ElementIdentifiers.get(wordEnd)
  }

  @inline
  let openWindow = (~start_i: i32) => {
    Logger.groupCollapsed1("initWindow start=%o", start_i)
    ctx.processing = true
    ctx->clearBuffWidth->ignore
    ctx.startElement = start_i
    ctx.processingElement = start_i
    ctx.wordStartElementIndex = start_i
    ctx.buffer_row = 0
    Logger.groupEnd()
  }

  @inline
  let _flush = (compactCtx, context, ~isEnd, ~end, ~start) => {
    let {buffer_width} = compactCtx

    @inline
    let _next = continue => {
      if isEnd {
        Logger.groupCollapsed3(
          "consume flush end char=%d...%d characters=%o...%o",
          start,
          end - 1,
          context->debug_get_characters(start, end),
        )
      } else {
        Logger.groupCollapsed4(
          "consume [%d] flush char=%d...%d => %o",
          end,
          start,
          end - 1,
          context->debug_get_characters(start, end),
        )
      }
      switch continue {
      | Break => ()
      | Continue => {
          // let {source} = context
          // 如果不需要中断
          // Logger.debug3("offset", source, source[i], source[word_end - 1])
          compactCtx.wordStartElementIndex = end + 1
          context
          ->Context.recordLastElement(context->loopPos(end - 1, start))
          ->Pipe.tapIfConst(!isEnd, () => {
            Logger.log1("add Space", env.spaceWidth)
            compactCtx.prevIsSpace = true
            context->Context.consumeX(env.spaceWidth)->Context.finish
          })
          ->switchTo(compactCtx)
          ->clearBuffWidth
          ->next
        }
      }
      Logger.groupEnd()
      continue
    }

    // 当超出最大宽度，进行折行
    if buffer_width +. context->Context.getCurrentX > env.maxWidth {
      compactCtx->lineWrap(~context, ~buffer_width)->Pipe.compute(_next)
    } else {
      _next(Continue)
    }
  }

  @inline
  let flush = (compactCtx, ~context, ~end, ~start) => {
    // %raw("/*flush*/0")->ignore
    _flush(compactCtx, context, ~isEnd=false, ~end, ~start)
  }

  @inline
  let end_flush = (compactCtx, ~context, ~end, ~start) => {
    // %raw("/*end_flush*/0")->ignore
    _flush(compactCtx, context, ~isEnd=true, ~end, ~start)
  }

  @inline
  let _processWindow = (
    context: context,
    ~char: identifier,
    ~elementHeight: f64,
    ~isEnd: bool,
  ): loopStage => {
    let start: i32 = ctx.wordStartElementIndex
    Logger.debug1("processWindow start=%o", start)
    // Logger.debug2("%o: %o", char, character)
    switch isEnd {
    // 处理结束字符
    | true => ctx->end_flush(~context, ~end=ctx.processingElement, ~start)
    // 处理空格字符
    | false if char->ECS.out(ECS.getElementType) === ElementType.Space =>
      ctx->flush(~context, ~end=ctx.processingElement, ~start)
    | false => {
        if ctx.prevIsSpace {
          ctx.prevIsSpace = false
        }

        Logger.groupCollapsed2(
          "consume [%d]:%o",
          ctx.processingElement,
          char->ECS.out(ECS.getCharacter),
        )

        context->Context.growRowHeight(elementHeight)->ignore

        char->ECS.out(char => {
          // 在这里先装入 width 和 height 信息
          char->ECS.setH(elementHeight)->ignore
          ctx->buffWidth(char->ECS.getWidth)->next
        })

        Logger.groupEnd()
        Continue
      }
    }->Pipe.debugTap(_ => Logger.banner1("next currentX=%o", context->Context.getCurrentX))
  }
  @inline
  let processWindow = (context: context, ~char: identifier, ~elementHeight: f64) => {
    context->_processWindow(~char, ~elementHeight, ~isEnd=false)
  }

  @inline
  let _closeWindow = (context: context) => {
    context->_processWindow(~char=context._END, ~elementHeight=0.0, ~isEnd=true)
  }

  @inline
  let closeWindow = (context: context, ~allowPangu: bool) => {
    // %raw("/*closeWindow*/0")->ignore
    let endElementIndex = context.cursor
    let startElementIndex = ctx.startElement
    Logger.debug1(
      "closeWindow: %o",
      {
        "startElementIndex": startElementIndex,
        "endElementIndex": endElementIndex,
        "allowPangu": allowPangu,
        "forceGridAlignment": CompressOptions.forceGridAlignment,
      },
    )

    context->_closeWindow->ignore
    ctx->endProcess
    let currentX_before = context->Context.getCurrentX

    // Logger.debug3("currentX: %o, gridSize: %o, xInterval: %o", currentX, gridSize, xInterval)
    // let offsetX: f64 = 0
    // 单行的情况下自动对齐两端空格
    Logger.debug1("buffer_row: %o", ctx.buffer_row)
    context
    ->Pipe.compute(_ => {
      if CompressOptions.forceGridAlignment {
        ForceGridAlignment.getOffsetX(
          context,
          ~currentX_before,
          ~startElementIndex=ctx.startElement,
          ~endElementIndex,
          ~allowPangu,
          ~isMultLine=ctx->isMultipleRow,
        )
      } else {
        context->Context.setCurrentColU(currentX_before /. env.gridWidth)
        if allowPangu {
          context->Context.consumeColU(0.25)
          currentX_before->F64.add(env.forceSpace +. env.xInterval)
        } else {
          currentX_before
        }
      }
    })
    ->Pipe.action(currentX => Logger.debug2("currentX %d => %d", currentX_before, currentX))
    ->Pipe.action(currentX => context->Context.setCurrentX(currentX))
    ->return()
  }
}
