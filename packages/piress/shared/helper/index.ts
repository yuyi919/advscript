import { cleanMeasureCache } from "./cache";
import { ElementType } from "./CharType";
import { IArea, IFontStyle } from "./util";

export const USE_LOGGER = false;
export interface IElementMeta extends IFontStyle {
  character: string;
  fontSize: i32;
  letterSpacing?: i32;
  // width: number;
}

export interface IElement extends IElementMeta, IArea {}

export * from "./createDefine";
export * from "./measureText";
export * from "./regexp";
export * from "./text";
export * from "./util";
export { cleanMeasureCache };
export { ElementType };
export { Cache };

import * as Cache from "./cache";
