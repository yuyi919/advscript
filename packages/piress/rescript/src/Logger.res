type logger // abstract type for a logger object

@module("piress-core-shared/logger") external logger: logger = "logger"
@module("piress-core-shared/logger") external compactLogger: logger = "compactLogger"

@send external debug: (logger, 'a) => unit = "debug"
@send external debug1: (logger, 'a, 'a1) => unit = "debug"
@send external debug2: (logger, 'a, 'a1, 'a2) => unit = "debug"
@send external debug3: (logger, 'a, 'a1, 'a2, 'a3) => unit = "debug"
@send external debug4: (logger, 'a, 'a1, 'a2, 'a3, 'a4) => unit = "debug"
@send external debug5: (logger, 'a, 'a1, 'a2, 'a3, 'a4, 'a5) => unit = "debug"

@send external banner: (logger, 'a) => unit = "banner"
@send external banner1: (logger, 'a, 'a1) => unit = "banner"
@send external banner2: (logger, 'a, 'a1, 'a2) => unit = "banner"
@send external banner3: (logger, 'a, 'a1, 'a2, 'a3) => unit = "banner"
@send external banner4: (logger, 'a, 'a1, 'a2, 'a3, 'a4) => unit = "banner"
@send external banner5: (logger, 'a, 'a1, 'a2, 'a3, 'a4, 'a5) => unit = "banner"

@send external log: (logger, 'a) => unit = "log"
@send external log1: (logger, 'a, 'a1) => unit = "log"
@send external log2: (logger, 'a, 'a1, 'a2) => unit = "log"
@send external log3: (logger, 'a, 'a1, 'a2, 'a3) => unit = "log"
@send external log4: (logger, 'a, 'a1, 'a2, 'a3, 'a4) => unit = "log"
@send external log5: (logger, 'a, 'a1, 'a2, 'a3, 'a4, 'a5) => unit = "log"

@send external groupCollapsed: (logger, 'a) => unit = "groupCollapsed"
@send external groupCollapsed1: (logger, 'a, 'a1) => unit = "groupCollapsed"
@send external groupCollapsed2: (logger, 'a, 'a1, 'a2) => unit = "groupCollapsed"
@send external groupCollapsed3: (logger, 'a, 'a1, 'a2, 'a3) => unit = "groupCollapsed"
@send external groupCollapsed4: (logger, 'a, 'a1, 'a2, 'a3, 'a4) => unit = "groupCollapsed"
@send external groupCollapsed5: (logger, 'a, 'a1, 'a2, 'a3, 'a4, 'a5) => unit = "groupCollapsed"
@send
external groupCollapsed6: (logger, 'a, 'a1, 'a2, 'a3, 'a4, 'a5, 'a6) => unit = "groupCollapsed"
@send
external groupCollapsed7: (logger, 'a, 'a1, 'a2, 'a3, 'a4, 'a5, 'a6, 'a7) => unit = "groupCollapsed"

@send external groupEnd: logger => unit = "groupEnd"
@send external groupEnd1: (logger, . 'a) => unit = "groupEnd"
@send external groupEnd2: (logger, . 'a, 'a1) => unit = "groupEnd"
@send external groupEnd3: (logger, . 'a, 'a1, 'a2) => unit = "groupEnd"
@send external groupEnd4: (logger, . 'a, 'a1, 'a2, 'a3) => unit = "groupEnd"

module type ILoggerOption = {
  let debugger: bool
}
module type IFullLoggerOption = {
  include ILoggerOption
  let logger: logger
}

module type ILogger = {
  include IFullLoggerOption

  let debuggers: unit => unit
  let makeDebugger5: (('a, 'a1, 'a2, 'a3, 'a4) => unit, 'a, 'a1, 'a2, 'a3, 'a4) => unit
  let makeDebugger6: (('a, 'a1, 'a2, 'a3, 'a4, 'a5) => unit, 'a, 'a1, 'a2, 'a3, 'a4, 'a5) => unit
  let debug: 'a => unit
  let debug1: ('a, 'a1) => unit
  let debug2: ('a, 'a1, 'a2) => unit
  let debug3: ('a, 'a1, 'a2, 'a3) => unit
  let debug4: ('a, 'b, 'c, 'd, 'e) => unit
  let debug5: ('a, 'a1, 'a2, 'a3, 'a4, 'a5) => unit
  let banner: 'a => unit
  let banner1: ('a, 'a1) => unit
  let banner2: ('a, 'a1, 'a2) => unit
  let banner3: ('a, 'a1, 'a2, 'a3) => unit
  let banner4: ('a, 'a1, 'a2, 'a3, 'a4) => unit
  let banner5: ('a, 'a1, 'a2, 'a3, 'a4, 'a5) => unit
  let log: 'a => unit
  let log1: ('a, 'a1) => unit
  let log2: ('a, 'a1, 'a2) => unit
  let log3: ('a, 'a1, 'a2, 'a3) => unit
  let log4: ('a, 'a1, 'a2, 'a3, 'a4) => unit
  let log5: ('a, 'a1, 'a2, 'a3, 'a4, 'a5) => unit
  let groupCollapsed: 'a => unit
  let groupCollapsed1: ('a, 'b) => unit
  let groupCollapsed2: ('a, 'b, 'c) => unit
  let groupCollapsed3: ('a, 'b, 'c, 'd) => unit
  let groupCollapsed4: ('a, 'b, 'c, 'd, 'e) => unit
  let groupCollapsed5: ('a, 'b, 'c, 'd, 'e, 'f) => unit
  let groupCollapsed6: ('a, 'b, 'c, 'd, 'e, 'f, 'g) => unit
  let groupCollapsed7: ('a, 'b, 'c, 'd, 'e, 'f, 'g, 'h) => unit
  let groupEnd: unit => unit
  let groupEnd1: 'a => unit
  let groupEnd2: ('a, 'b) => unit
  let groupEnd3: ('a, 'b, 'c) => unit
}

module MakeLogger = (ILogger: IFullLoggerOption): ILogger => {
  let logger = ILogger.logger
  let debugger = ILogger.debugger

  @inline
  let debuggers = (): unit => {
    if !debugger {
      %raw("/*@__PURE__*/0")
    }
  }
  @inline
  let makeDebugger5 = (fn: ('a, 'a1, 'a2, 'a3, 'a4) => unit, a, a1, a2, a3, a4) => {
    debuggers()
    fn(a, a1, a2, a3, a4)
  }
  let makeDebugger6 = (fn: ('a, 'a1, 'a2, 'a3, 'a4, 'a5) => unit) => {
    (a, a1, a2, a3, a4, a5) => {
      debuggers()
      fn(a, a1, a2, a3, a4, a5)
    }
  }
  @inline
  let debug: 'a => unit = a =>
    if debugger {
      logger->debug(a)
    }
  @inline
  let debug1: ('a, 'a1) => unit = (a, a2) =>
    if debugger {
      logger->debug1(a, a2)
    }
  @inline
  let debug2: ('a, 'a1, 'a2) => unit = (a, a2, a3) =>
    if debugger {
      logger->debug2(a, a2, a3)
    }
  @inline
  let debug3: ('a, 'a1, 'a2, 'a3) => unit = (a, a2, a3, a4) =>
    if debugger {
      logger->debug3(a, a2, a3, a4)
    }
  @inline
  let debug4 = (a, a2, a3, a4, a5) =>
    if debugger {
      logger->debug4(a, a2, a3, a4, a5)
    }
  @inline
  let debug5: ('a, 'a1, 'a2, 'a3, 'a4, 'a5) => unit = (a, a2, a3, a4, a5, a6) =>
    if debugger {
      logger->debug5(a, a2, a3, a4, a5, a6)
    }

  @inline
  let banner: 'a => unit = a =>
    if debugger {
      logger->banner(a)
    }
  @inline
  let banner1: ('a, 'a1) => unit = (a, a2) =>
    if debugger {
      logger->banner1(a, a2)
    }
  @inline
  let banner2: ('a, 'a1, 'a2) => unit = (a, a2, a3) =>
    if debugger {
      logger->banner2(a, a2, a3)
    }
  @inline
  let banner3: ('a, 'a1, 'a2, 'a3) => unit = (a, a2, a3, a4) =>
    if debugger {
      logger->banner3(a, a2, a3, a4)
    }
  @inline
  let banner4: ('a, 'a1, 'a2, 'a3, 'a4) => unit = (a, a2, a3, a4, a5) =>
    if debugger {
      logger->banner4(a, a2, a3, a4, a5)
    }
  @inline
  let banner5: ('a, 'a1, 'a2, 'a3, 'a4, 'a5) => unit = (a, a2, a3, a4, a5, a6) =>
    if debugger {
      logger->banner5(a, a2, a3, a4, a5, a6)
    }

  @inline
  let log: 'a => unit = a =>
    if debugger {
      logger->log(a)
    }
  @inline
  let log1: ('a, 'a1) => unit = (a, a2) =>
    if debugger {
      logger->log1(a, a2)
    }
  @inline
  let log2: ('a, 'a1, 'a2) => unit = (a, a2, a3) =>
    if debugger {
      logger->log2(a, a2, a3)
    }
  @inline
  let log3: ('a, 'a1, 'a2, 'a3) => unit = (a, a2, a3, a4) =>
    if debugger {
      logger->log3(a, a2, a3, a4)
    }
  @inline
  let log4: ('a, 'a1, 'a2, 'a3, 'a4) => unit = (a, a2, a3, a4, a5) =>
    if debugger {
      logger->log4(a, a2, a3, a4, a5)
    }
  @inline
  let log5: ('a, 'a1, 'a2, 'a3, 'a4, 'a5) => unit = (a, a2, a3, a4, a5, a6) =>
    if debugger {
      logger->log5(a, a2, a3, a4, a5, a6)
    }

  @inline
  let groupCollapsed = a =>
    if debugger {
      logger->groupCollapsed(a)
    }

  @inline
  let groupCollapsed1 = (a, a1) =>
    if debugger {
      logger->groupCollapsed1(a, a1)
    }

  @inline
  let groupCollapsed2 = (a, a1, a2) =>
    if debugger {
      logger->groupCollapsed2(a, a1, a2)
    }

  @inline
  let groupCollapsed3 = (a, a1, a2, a3) =>
    if debugger {
      logger->groupCollapsed3(a, a1, a2, a3)
    }

  @inline
  let groupCollapsed4 = (a, a1, a2, a3, a4) =>
    if debugger {
      logger->groupCollapsed4(a, a1, a2, a3, a4)
    }

  @inline
  let groupCollapsed5 = (a, a1, a2, a3, a4, a5) =>
    if debugger {
      logger->groupCollapsed5(a, a1, a2, a3, a4, a5)
    }
  @inline
  let groupCollapsed6 = (a, a1, a2, a3, a4, a5, a6) =>
    if debugger {
      logger->groupCollapsed6(a, a1, a2, a3, a4, a5, a6)
    }
  @inline
  let groupCollapsed7 = (a, a1, a2, a3, a4, a5, a6, a7) =>
    if debugger {
      logger->groupCollapsed7(a, a1, a2, a3, a4, a5, a6, a7)
    }

  @inline
  let groupEnd = () =>
    if debugger {
      logger->groupEnd
    }
  @inline
  let groupEnd1 = a =>
    if debugger {
      logger->groupEnd1->Shared.compute(c => c(. a))
    }
  @inline
  let groupEnd2 = (a, a1) =>
    if debugger {
      logger->groupEnd2->Shared.compute(c => c(. a, a1))
    }
  @inline
  let groupEnd3 = (a, a1, a2) =>
    if debugger {
      logger->groupEnd3->Shared.compute(c => c(. a, a1, a2))
    }
}
