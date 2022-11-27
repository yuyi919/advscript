const Canvas: typeof OffscreenCanvas =
  import.meta.env.MODE === "node" ? require("canvas").Canvas : OffscreenCanvas;
const canvas = new Canvas(0, 0);
const context = canvas.getContext("2d")!;
/**
 * !浏览器OffscrennCanvas原生不支持letterSpacing
 */
export const POLYFILL_LETTER_SPACEING =
  typeof context.letterSpacing !== "string";
let FLAG_STDWIDTH = false,
  DETECTED_FLAG_STDWIDTH = false;

export function IS_FLAG_STDWIDTH() {
  return FLAG_STDWIDTH;
}

export function detectEnv() {
  if (!DETECTED_FLAG_STDWIDTH) {
    // 检测中文字符宽度是否等于字号
    context.font = "18px sans-serif";
    FLAG_STDWIDTH = context.measureText("中").width === 18;
    DETECTED_FLAG_STDWIDTH = true;
  }
}

let _font: string = "",
  _letterSpacing = 0;
export function measureTextWidth(
  text: string,
  font: string,
  letterSpacing: number,
): f64 {
  if (font !== "" && font !== _font) {
    context.font = _font = font;
  }
  if (!POLYFILL_LETTER_SPACEING) {
    if (letterSpacing !== _letterSpacing) {
      context.letterSpacing = letterSpacing + "px";
      _letterSpacing = letterSpacing;
    }
  }
  // console.debug("font: %s", text, font, +context.measureText(text).width);
  // `normal normal ${charFontWeight} ${charFontSize}px ${charFontFamily}`;
  return +context.measureText(text).width;
}

export function pure_measureTextWidth(
  text: string,
  font: string,
  letterSpacing: number,
): f64 {
  if (font !== "") {
    context.font = font;
  }
  if (!POLYFILL_LETTER_SPACEING) {
    if (letterSpacing !== _letterSpacing) {
      context.letterSpacing = letterSpacing + "px";
      _letterSpacing = letterSpacing;
    }
  }
  return +context.measureText(text).width;
}
