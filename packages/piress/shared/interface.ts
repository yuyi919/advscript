import { IFontStyle } from "./helper/index";

export type ElementIdentifier = number & {
  charIdentifier: true;
};

export type ElementIdentifierList = ElementIdentifier[] &
  Int32Array & { charIdentifier: true };

/**
 * 压缩的文本序列
 * 0位是起始字符id，之后分别是每行末尾的字符id
 */
export type CompressedElementIdentifiers = [
  ElementIdentifier,
  ElementIdentifier,
  ...ElementIdentifier[],
];

export interface Result {
  seqs: CompressedElementIdentifiers;
  areaWidth: f64;
  areaHeight: f64;
  // textLines,
  lastLineIndex: i32;
}

export interface ITypographyCompressionOptions {
  /**
   * 开启行内标点压缩
   * @defaultValue `true`
   */
  inlineCompression: boolean;
  /**
   * 强制纵横对齐
   * @defaultValue `true`
   */
  forceGridAlignment: boolean;
  /**
   * 西文优先
   * @defaultValue `false`
   */
  westernCharacterFirst: boolean;
  /**
   * 若纵横对齐导致无空格间隔，则强制在两边加入至少 1/4em 宽空格
   * @defaultValue `false`
   */
  forceSpaceBetweenCJKAndWestern: boolean;
  /**
   * 是否进行左全角引号的位置修正
   * @defaultValue `true`
   */
  fixCJKLeftQuote: boolean;
}
export interface ITypographyBaseOptions {
  /**
   * 折行宽度
   */
  wrapWidth?: f64;
  /**
   * 每行字数
   * @defaultValue `25`
   */
  column: number;
  /**
   * 行数
   * @defaultValue `Infinity`
   */
  row: number;
  /**
   * 排版网格宽度（即一个em多宽，与 textSequence 中的 fontSize 不同）
   * @defaultValue `26`
   */
  gridSize: number;
  /**
   * 字距（仅 CJK 文字）
   * @defaultValue `0`
   */
  xInterval: number;
  /**
   * 行距
   * @defaultValue `6`
   */
  yInterval: number;

  /**
   * 字符间距（仅西文文字）
   * @defaultValue `0`
   */
  letterSpacing: number;

  ruby?: { source: string; target: string }[];
}

export interface ITypographyOptions
  extends IFontStyle,
    Partial<ITypographyBaseOptions> {
  /**
   * 展示区域宽度
   */
  wrapWidth?: number;
  fontSize: number;
}

export interface ITextSequenceBase {
  seqs: CompressedElementIdentifiers;
  areaWidth: number;
  areaHeight: number;
  width: number;
  height: number;
  lastLineIndex: number;
}
