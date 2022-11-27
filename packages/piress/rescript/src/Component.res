open Shared
open! IContext

let isProd: bool = %raw("import.meta.env.PROD")

module type ProcessConfig = {
  @inline
  let compressOptions: Env.iTypographyCompressionOptions
}
module type IProcess = {
  let calc: (. IEcs.elementIds, Env.iTypographyBaseOptions) => IContext.result
}

module Export: {
  module Process: IProcess
  let create: (
    . string,
    Font.fontStyle,
    Font.fontVariant,
    Font.fontWeight,
    Shared.f64,
    string,
    Shared.f64,
  ) => IEcs.identifier
  // module ECS: IEcs.Visitor
  module Ecs: IEcs.Adapter
} = {
  open Env
  open IEcs

  module BufferECS = StaticArrayEcs.Use()
  module ECS: IEcs.Visitor = IEcs.Make(BufferECS)

  module MakeProcess: ICompressOptions => IProcess = (CompressOptions: ICompressOptions) => {
    module Pipe = Pipe.Use(CompressOptions)
    module Env = Env.Initlize(CompressOptions)
    module Store = IContext.MakeStore()
    module Runtime = {
      include ECS
      module CompressOptions = CompressOptions
      module Store = Store
      let env = Env.env
    }
    module Context = IContext.MakeContext(Runtime)
    module CompactContext = CompactContext.MakeContext(Runtime)
    module ForceGridAlignment: Helper.IForceGridAlignment = Helper.MakeForceGridAlignment(Runtime)
    module Compress = Helper.MakeCompress(Runtime)

    let {env, compressOptions} = module(Env)

    @inline
    let pure = (): unit => {
      if !CompressOptions.debugger {
        %raw("/*@__PURE__*/0")
      }
    }

    module IProcessLogger = {
      let logger = Logger.logger
      let debugger = CompressOptions.debugger
    }
    module Logger = Logger.MakeLogger(IProcessLogger)

    module Process = {
      @inline
      let allowProcessCompactText = elementType => {
        switch elementType {
        | ElementType.Word | ElementType.FULL_POINT => true
        | _ => ElementType.isQUOTE(elementType) || ElementType.isBRACKET(elementType)
        }
      }

      @inline
      let closeCompactWindow = (context: context, ~currentIsPunctuation: bool, ~end: bool) => {
        %raw("/*closeCompactWindow*/0")->ignore
        if CompactContext.isProcessing() {
          if CompressOptions.forceSpaceBetweenCJKAndWestern {
            switch end {
            | false if !currentIsPunctuation && context->CompactContext.testPrevCharIsWestern =>
              context->CompactContext.closeWindow(~allowPangu=true)
            | _ => context->CompactContext.closeWindow(~allowPangu=false)
            }
          } else {
            context->CompactContext.closeWindow(~allowPangu=false)
          }
          Logger.groupEnd1("process compact")
        }
      }

      @inline
      let isInvalidEndColumn = (context, ~currentIsPunctuation, ~elementType) =>
        context->Context.getCurrentCol == env.maxCol -. 1.0 &&
        currentIsPunctuation &&
        ElementType.checkInvalidEndChar(elementType)

      @inline
      let recordLastElement = (context, ~char, ~charWidth, ~charFontSize, ~charCode) => {
        char
        ->ECS.action(char => {
          let x =
            context
            ->Context.getCurrentX
            ->Pipe.pipeIfConst(
              // 判断修复CJK左引号偏移
              CompressOptions.fixCJKLeftQuote,
              Compress.fixCjkLeftQuote(~context, ~charFontSize, ~charCode, ~charWidth),
            )
          let y = context->Context.getCurrentY -. (charFontSize -. env.gridSize) /. 2.0
          char->ECS.setPosition(x, y)->ignore
          char->ECS.setSize(charWidth, charFontSize)->ignore
        })
        ->ignore
        context->Context.recordLastElement(char)
      }

      @inline
      let processChar_ = (context, ~char, ~elementType, ~currentIsPunctuation, ~isValidEndChar) => {
        let isInvalidEndColumn = context->isInvalidEndColumn(~currentIsPunctuation, ~elementType)
        let overflowCol = context->Context.getCurrentCol >= env.maxCol
        let isEOL = overflowCol || isInvalidEndColumn
        let charWidth = char->ECS.out(ECS.getWidth)
        let charCode = char->ECS.out(ECS.getCharCode)
        let charFontSize = char->ECS.out(ECS.getFontSize)
        if isEOL {
          // 起始符号在行尾时强制折行
          // Logger.debug(
          //   "isEOL",
          //   JSON.stringify(character),
          //   context.currentColumn,
          //   column,
          // )
          if !isValidEndChar || isInvalidEndColumn || context.isNeedForceWrap {
            // 正常折行
            context->Context.lineWrap
          }
        }

        // 测量文字宽度
        // Logger.debug(`[calcWithChar] ${char}:${character} = ${width}`)
        // 在前后字号不一致的时候施行强制纵横对齐

        // 预先缓存偏移量，确定字符位置后再进行下个字符的前瞻
        // 确定字符位置并添加到返回数组中
        if CompressOptions.forceGridAlignment {
          context->ForceGridAlignment.buffOffsetX(
            ~fontSize=charFontSize,
            ~overflow=overflowCol && isValidEndChar,
          )
        }
        context->recordLastElement(~char, ~charWidth, ~charFontSize, ~charCode)
        if CompressOptions.forceGridAlignment {
          context->ForceGridAlignment.consumeOffsetX
        }
        context
        ->Compress.process(
          _,
          ~charCode,
          ~charFontSize,
          ~charWidth,
          ~currentIsPunctuation,
          ~isEOL,
          ~isValidEndChar,
        )
        ->Context.growRowHeight(charFontSize) // 更新行高
        // 杂七杂八的状态更新
        ->Context.setLastCharWidth(charWidth)
        ->return(
          // 超出高度，直接略去后面的字符，返回的数据中也不包含后面的字符。
          context->Context.getCurrentRow < env.maxRow ? Continue : Break,
        )
      }
      @inline
      let processChar = (
        context,
        ~char: identifier,
        ~elementType: ElementType.enums,
        ~currentIsPunctuation: bool,
        ~isValidEndChar: bool,
      ): loopStage => {
        if elementType === ElementType.EOL {
          // 强制折行
          context->Context.lineWrap
          Continue
        } else {
          context->processChar_(~char, ~elementType, ~currentIsPunctuation, ~isValidEndChar)
        }
      }

      @inline
      let allowContinueCompactProcess = (~elementType: ElementType.enums, ~isValidEndChar: bool) =>
        CompactContext.isProcessing() && (elementType === ElementType.Space || isValidEndChar)

      @inline
      let each = (
        context: context,
        ~char: identifier,
        ~elementType: ElementType.enums,
        ~currentIsPunctuation: bool,
        ~isValidEndChar: bool,
      ): loopStage => {
        Logger.debug2("%o: %o", char, char->ECS.out(ECS.getCharacter))
        if (
          allowContinueCompactProcess(~elementType, ~isValidEndChar) ||
          allowProcessCompactText(elementType)
        ) {
          if !CompactContext.isProcessing() {
            CompactContext.openWindow(~start_i=context.cursor)
            if CompressOptions.forceSpaceBetweenCJKAndWestern {
              if !currentIsPunctuation {
                context->CompactContext.processPanguBegin
              }
            }
            Logger.groupCollapsed("process compact")
          }
          context->CompactContext.processWindow(
            ~char,
            ~elementHeight=char->ECS.out(ECS.getFontSize),
          )
        } else {
          context->closeCompactWindow(~currentIsPunctuation, ~end=false)
          context->processChar(~char, ~elementType, ~currentIsPunctuation, ~isValidEndChar)
        }
      }
    }

    @inline
    let each = (context, ~char, ~prevChar) => {
      let elementType = char->ECS.out(ECS.getElementType)
      let currentIsPunctuation =
        elementType !== ElementType.Char && elementType !== ElementType.Word
      if CompressOptions.debugger && elementType == ElementType.INVALID {
        Js.Exn.raiseRangeError("Invalid Element: " ++ char->IEcs.id2String)
      }
      context.prevChar = prevChar
      context->Compress.processUncompress(~currentIsPunctuation)
      context->Process.each(
        ~char,
        ~elementType,
        ~currentIsPunctuation,
        ~isValidEndChar=currentIsPunctuation && ElementType.checkValidEndChar(elementType),
      )
    }

    @inline
    let output = context => {
      context->Compress.processUncompress(~currentIsPunctuation=false)
      context->Process.closeCompactWindow(~currentIsPunctuation=false, ~end=true)
      Logger.debug1("context", context)
      Logger.groupEnd()
      context->Context.flush
    }

    @genType
    let calc = (. source: elementIds, options) => {
      let context = Store.context
      Logger.groupCollapsed1("call proxyRun", source)
      let length = source->ElementIdentifiers.unbox->Array.length
      context->Context.prepare(~source, ~options)

      @inline
      let rec loop = (index, prevChar) => {
        if index >= length {
          output(context)
        } else {
          let char = source->ElementIdentifiers.get(index)
          if IEcs.isValid(char) {
            context.cursor = index
            context->each(~char, ~prevChar)
          } else {
            Continue
          }->Pipe.pipe(break => {
            switch break {
            | Break => loop(length, char)
            | Continue => loop(index + 1, char)
            }
          })
        }
      }
      loop(0, context._END)
    }
  }

  module Process = MakeProcess(DefaultCompressOptions)

  module Ecs = IEcs.ExportEcs(ECS)
  module Font = {
    include Font
  }
  @inline
  let measureTextWidth = (
    char,
    text,
    ~fontStyle,
    ~fontVariant,
    ~fontWeight,
    ~fontSize,
    ~fontFamily,
    ~letterSpacing,
  ) => {
    if !ElementType.isWS(char->ECS.getElementType) {
      // let font = Font.buildFontStr(~fontStyle, ~fontVariant, ~fontWeight, ~fontSize, ~fontFamily)
      // char->ECS.setW(Import.measureTextWidth(~text, ~font, ~letterSpacing))->ignore
      // char->ECS.setFont(font)->ignore
      let (width, font) = Font.measureTextWidth(
        text,
        ~fontStyle,
        ~fontVariant,
        ~fontWeight,
        ~fontSize,
        ~fontFamily,
        ~letterSpacing,
      )
      char->ECS.setFont(font)->ignore
      char->ECS.setW(width)->ignore
    }
    char
  }
  @genType
  let create = (.
    character: string,
    fontStyle,
    fontVariant,
    fontWeight,
    fontSize,
    fontFamily,
    letterSpacing: f64,
  ): IEcs.identifier => {
    ECS.create(~character, ~fontSize)->ECS.action(
      measureTextWidth(
        _,
        character,
        ~fontStyle,
        ~fontVariant,
        ~fontWeight,
        ~fontSize,
        ~fontFamily,
        ~letterSpacing,
      ),
    )
  }
}
open Export

@genType
let calc = Process.calc
@genType
let create = create

module type Adapter = {
  include IEcs.Adapter
}

@genType
let ecs: module(Adapter) = module(Ecs)

@genType
let getOffsetXFromFixCjkQuote = (
  . ~flag_STDWIDTH,
  ~fixCJKLeftQuote,
  ~lastIsPunctuation,
  ~charFontSize,
  ~charCode,
  ~charWidth,
) =>
  Helper.getOffsetXFromFixCjkQuote(
    ~flag_STDWIDTH,
    ~fixCJKLeftQuote,
    ~lastIsPunctuation,
    ~charFontSize,
    ~charCode,
    ~charWidth,
  )
