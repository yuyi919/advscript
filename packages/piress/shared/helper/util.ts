export interface IArea {
  x: number;
  y: number;
  width: number;
  height: number;
}

export type TextStyleFontStyle = "normal" | "italic" | "oblique";

export type TextStyleFontVariant = "normal" | "small-caps";

export type TextStyleFontWeight =
  | "normal"
  | "bold"
  | "bolder"
  | "lighter"
  | "100"
  | "200"
  | "300"
  | "400"
  | "500"
  | "600"
  | "700"
  | "800"
  | "900";

export interface IFontStyle {
  /**
   * 字体
   */
  fontFamily: string;
  /**
   * 字号
   */
  fontSize: number; // | string;
  /**
   * 同浏览器
   */
  fontStyle?: TextStyleFontStyle;
  /**
   * 同浏览器
   */
  fontVariant?: TextStyleFontVariant;
  /**
   * 同浏览器
   */
  fontWeight?: TextStyleFontWeight;
  /**
   * 行高
   */
  lineHeight?: number;
}

const fontVariant = ["normal", "small-caps"];
const fontStyle = ["normal", "italic", "oblique"];
const fontWeight = [
  "normal",
  "bold",
  "bolder",
  "lighter",
  "100",
  "200",
  "300",
  "400",
  "500",
  "600",
  "700",
  "800",
  "900",
];

export function toFontString(target: IFontStyle): string;
export function toFontString(
  target: Partial<IFontStyle>,
  defaultStyle: IFontStyle,
): string;
export function toFontString(target: any, defaultStyle: IFontStyle): string;
export function toFontString(
  target: any,
  defaultStyle: any,
  strict?: false,
): string;
export function toFontString(
  target: Partial<IFontStyle>,
  defaultStyle?: IFontStyle,
) {
  return `${toExpectValue(
    target.fontStyle,
    fontStyle,
    defaultStyle?.fontStyle || "normal",
  )} ${toExpectValue(
    target.fontVariant,
    fontVariant,
    defaultStyle?.fontVariant || "normal",
  )} ${toExpectValue(
    target.fontWeight,
    fontWeight,
    defaultStyle?.fontWeight || "normal",
  )} ${toFontSizeString(
    target.fontSize || defaultStyle?.fontSize!,
    target.lineHeight || defaultStyle?.lineHeight!,
  )} ${toFontFamilyString(target.fontFamily || defaultStyle?.fontFamily!)}`;
}

export function toExpectValue(
  value: string | undefined,
  target: string[],
  defaultValue: string,
) {
  return target.includes(value!) ? value : defaultValue || "normal";
}
export function toFontFamilyString(fontFamily: string | string[]) {
  return fontFamily instanceof Array
    ? `"${fontFamily.join('","')}"`
    : fontFamily;
}

export function toFontSizeString(
  fontSize: number | string,
  lineHeight?: number,
  strict = false,
) {
  let value = "";
  if (strict && typeof fontSize === "string" && /\d$/.test(fontSize)) {
    value = fontSize;
  } else {
    value = `${fontSize}px`;
  }
  return lineHeight ? `${value}/${lineHeight}px` : value;
}

export function getLast<T>(target: T[]) {
  return target[target.length - 1];
}

export function mergeArea<T extends IArea & { character: string }>(seqs: T[]) {
  let prev: T = seqs[0];
  const char = { ...prev };
  const last = getLast(seqs);
  char.width = last.x - prev.x + last.width;
  for (let i = 1; i < seqs.length; i++) {
    const curr = seqs[i];
    char.character += curr.character;
    prev = seqs[i];
  }
  return char;
}
