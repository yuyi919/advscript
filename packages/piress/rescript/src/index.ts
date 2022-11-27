/* TypeScript file generated from Component.res by genType. */
/* eslint-disable import/first */

// @ts-ignore: Implicit any on import
import * as ComponentBS from "./Component.bs";

import type { elementIds as IEcs_elementIds } from "./IEcs.gen";

import type { element as IEcs_element } from "./IEcs.gen";

import type { enums as ElementType_enums } from "./ElementType.gen";

import type { f64 as Shared_f64 } from "./Shared.gen";

import type { fontStyle as Font_fontStyle } from "./Font.gen";

import type { fontVariant as Font_fontVariant } from "./Font.gen";

import type { fontWeight as Font_fontWeight } from "./Font.gen";

import type { i32 as Shared_i32 } from "./Shared.gen";

import type { iTypographyBaseOptions as Env_iTypographyBaseOptions } from "./Env.gen";

import type { identifier as IEcs_identifier } from "./IEcs.gen";

import type { result as IContext_result } from "./IContext.gen";

export const calc: (
  _1: IEcs_elementIds,
  _2: Env_iTypographyBaseOptions,
) => IContext_result = ComponentBS.calc;

export const create: (
  character: string,
  fontStyle: Font_fontStyle,
  fontVariant: Font_fontVariant,
  fontWeight: Font_fontWeight,
  fontSize: Shared_f64,
  fontFamily: string,
  letterSpacing: Shared_f64,
) => IEcs_identifier = ComponentBS.create;

export const ecs: {
  readonly create: (_1: {
    readonly character: string;
    readonly fontSize: Shared_f64;
  }) => IEcs_identifier;
  readonly getCharacter: (_1: IEcs_identifier) => string;
  readonly getCharCode: (_1: IEcs_identifier) => Shared_i32;
  readonly getElementType: (_1: IEcs_identifier) => ElementType_enums;
  readonly getWidth: (_1: IEcs_identifier) => Shared_f64;
  readonly getHeight: (_1: IEcs_identifier) => Shared_f64;
  readonly getX: (_1: IEcs_identifier) => Shared_f64;
  readonly getY: (_1: IEcs_identifier) => Shared_f64;
  readonly getFontSize: (_1: IEcs_identifier) => Shared_f64;
  readonly setWidth: (_1: IEcs_identifier, _2: Shared_f64) => IEcs_identifier;
  readonly setHeight: (_1: IEcs_identifier, _2: Shared_f64) => IEcs_identifier;
  readonly setX: (_1: IEcs_identifier, _2: Shared_f64) => IEcs_identifier;
  readonly setY: (_1: IEcs_identifier, _2: Shared_f64) => IEcs_identifier;
  readonly addX: (_1: IEcs_identifier, _2: Shared_f64) => IEcs_identifier;
  readonly setFontSize: (
    _1: IEcs_identifier,
    _2: Shared_f64,
  ) => IEcs_identifier;
  readonly setPosition: (
    _1: IEcs_identifier,
    _2: Shared_f64,
    _3: Shared_f64,
  ) => IEcs_identifier;
  readonly setSize: (
    _1: IEcs_identifier,
    _2: Shared_f64,
    _3: Shared_f64,
  ) => IEcs_identifier;
  readonly input: (_1: IEcs_element) => IEcs_identifier;
  readonly cursor: (_1: IEcs_identifier) => IEcs_element;
  readonly output: (_1: IEcs_identifier) => IEcs_element;
  readonly grow: (_1: Shared_i32) => void;
  readonly initlize: (_1: Shared_i32) => void;
} = {
  create: function (Arg1: any) {
    const result = ComponentBS.ecs.create(Arg1.character, Arg1.fontSize);
    return result;
  },
  getCharacter: ComponentBS.ecs.getCharacter,
  getCharCode: ComponentBS.ecs.getCharCode,
  getElementType: ComponentBS.ecs.getElementType,
  getWidth: ComponentBS.ecs.getWidth,
  getHeight: ComponentBS.ecs.getHeight,
  getX: ComponentBS.ecs.getX,
  getY: ComponentBS.ecs.getY,
  getFontSize: ComponentBS.ecs.getFontSize,
  setWidth: ComponentBS.ecs.setWidth,
  setHeight: ComponentBS.ecs.setHeight,
  setX: ComponentBS.ecs.setX,
  setY: ComponentBS.ecs.setY,
  addX: ComponentBS.ecs.addX,
  setFontSize: ComponentBS.ecs.setFontSize,
  setPosition: ComponentBS.ecs.setPosition,
  setSize: ComponentBS.ecs.setSize,
  input: ComponentBS.ecs.input,
  cursor: ComponentBS.ecs.cursor,
  output: ComponentBS.ecs.output,
  grow: ComponentBS.ecs.grow,
  initlize: ComponentBS.ecs.initlize,
};

export const getOffsetXFromFixCjkQuote: (_1: {
  readonly flag_STDWIDTH: boolean;
  readonly fixCJKLeftQuote: boolean;
  readonly lastIsPunctuation: boolean;
  readonly charFontSize: number;
  readonly charCode: number;
  readonly charWidth: number;
}) => Shared_f64 = function (Arg1: any) {
  const result = ComponentBS.getOffsetXFromFixCjkQuote(
    Arg1.flag_STDWIDTH,
    Arg1.fixCJKLeftQuote,
    Arg1.lastIsPunctuation,
    Arg1.charFontSize,
    Arg1.charCode,
    Arg1.charWidth,
  );
  return result;
};

export * from "./IEcs.gen";
