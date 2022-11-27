open Shared

module type PipeConfig = {
  let debugger: bool
}

module Use = (Config: PipeConfig) => {
  @inline
  let return = (_, t) => t

  @inline
  let switchTo = (_, t) => t

  @inline
  let tapIf = (context, @uncurry exp, @uncurry fn) => {
    switch exp(context) {
    | true => fn(context)->return(context)
    | false => context
    }
  }

  @inline
  let tapIfConst = (context, exp, @uncurry fn) => {
    switch exp {
    | true => fn(context)->return(context)
    | false => context
    }
  }

  @inline
  let boolean = (context, @uncurry exp) => {
    Pipe((exp(context) ? True : False, context))
  }

  @inline
  let onTrue = (context, @uncurry fn) => {
    switch context {
    | Pipe((True, context)) => Pipe((True, @uncurry fn(context)))
    | Pipe((False, _)) => context
    }
  }

  @inline
  let onFalse = (context, @uncurry fn) => {
    switch context {
    | Pipe((True, _)) => context
    | Pipe((False, context)) => Pipe((False, @uncurry fn(context)))
    }
  }

  @inline
  let unwrap = context => {
    switch context {
    | Pipe((_, context)) => context
    }
  }

  @inline
  let compute = (context, @uncurry fn) => {
    fn(context)
  }
  @inline
  let computeIfConst = (context, exp, @uncurry fn) => {
    exp ? fn(context) : context
  }

  @inline
  let pipeIf = (context: 'a, @uncurry exp: 'a => bool, @uncurry fn: 'a => 'a) => {
    switch exp(context) {
    | true => context->fn
    | false => context
    }
  }

  @inline
  let pipeIfElse = (
    context: 'a,
    @uncurry exp: 'a => bool,
    @uncurry fn: 'a => 'b,
    @uncurry else': 'a => 'b,
  ) => {
    switch exp(context) {
    | true => context->fn
    | false => context->else'
    }
  }

  @inline
  let pipeIfConst = (context, exp, @uncurry fn) => {
    exp ? fn(context) : context
  }

  @inline
  let switchIf = (context, exp, ~else', @uncurry fn) => {
    exp ? fn(context) : else'
  }

  @inline
  let check = (context, ~if', ~else', @uncurry fn) => {
    if'(context) ? fn(context) : else'
  }

  @inline
  let pipe = (context, @uncurry fn) => {
    fn(context)
  }

  @inline
  let computeIfElse = (context, exp, @uncurry fn, @uncurry fn2) => {
    exp ? fn(context) : fn2(context)
  }

  @inline
  let action = (context, @uncurry fn) => {
    fn(context)->ignore
    context
  }

  @inline
  let actionU = (context: 'a, fn: (. 'a) => 'b) => {
    fn(. context)->ignore
    context
  }

  @inline
  let actionWith = (context, withCtx, @uncurry fn) => {
    fn(withCtx)->ignore
    context
  }

  @inline
  let tap = (context, @uncurry fn) => {
    fn()->ignore
    context
  }

  @inline
  let debugTap = (context, @uncurry fn) => {
    if Config.debugger {
      fn()->return(context)
    } else {
      context
    }
  }
  @inline
  let debug = (context, @uncurry fn) => {
    if Config.debugger {
      context->fn->return(context)
    } else {
      context
    }
  }

  @inline
  let ignore = (context, withCtx) => {
    withCtx->return(context)
  }

  @inline
  let call = (@uncurry context, arg) => {
    arg->context
  }

  @inline
  let rev = (b, @uncurry fn, a) => fn(a, b)
}

@inline
let return = (_, t) => t

@inline
let switchTo = (_, t) => t

@inline
let tapIf = (context, @uncurry exp, @uncurry fn) => {
  switch exp(context) {
  | true => fn(context)->return(context)
  | false => context
  }
}

@inline
let tapIfConst = (context, exp, @uncurry fn) => {
  switch exp {
  | true => fn(context)->return(context)
  | false => context
  }
}

@inline
let boolean = (context, @uncurry exp) => {
  Pipe((exp(context) ? True : False, context))
}

@inline
let onTrue = (context, @uncurry fn) => {
  switch context {
  | Pipe((True, context)) => Pipe((True, @uncurry fn(context)))
  | Pipe((False, _)) => context
  }
}

@inline
let onFalse = (context, @uncurry fn) => {
  switch context {
  | Pipe((True, _)) => context
  | Pipe((False, context)) => Pipe((False, @uncurry fn(context)))
  }
}

@inline
let unwrap = context => {
  switch context {
  | Pipe((_, context)) => context
  }
}

@inline
let pipeIf = (context: 'a, @uncurry exp: 'a => bool, @uncurry fn: 'a => 'a) => {
  switch exp(context) {
  | true => context->fn
  | false => context
  }
}

@inline
let pipeIfElse = (
  context: 'a,
  @uncurry exp: 'a => bool,
  @uncurry fn: 'a => 'b,
  @uncurry else': 'a => 'b,
) => {
  switch exp(context) {
  | true => context->fn
  | false => context->else'
  }
}

@inline
let pipeIfConst = (context, exp, @uncurry fn) => {
  exp ? fn(context) : context
}

@inline
let switchIf = (context, exp, ~else', @uncurry fn) => {
  exp ? fn(context) : else'
}

@inline
let check = (context, ~if', ~else', @uncurry fn) => {
  if'(context) ? fn(context) : else'
}

@inline
let pipe = (context, @uncurry fn) => {
  fn(context)
}

@inline
let compute = (context, @uncurry fn) => {
  fn(context)
}

@inline
let action = (context, @uncurry fn) => {
  fn(context)->ignore
  context
}

@inline
let actionU = (context: 'a, fn: (. 'a) => 'b) => {
  fn(. context)->ignore
  context
}

@inline
let actionWith = (context, withCtx, @uncurry fn) => {
  fn(withCtx)->ignore
  context
}

@inline
let tap = (context, @uncurry fn) => {
  fn()->ignore
  context
}

@inline
let ignore = (context, withCtx) => {
  withCtx->return(context)
}

@inline
let call = (@uncurry context, arg) => {
  arg->context
}

@inline
let rev = (b, @uncurry fn, a) => fn(a, b)
