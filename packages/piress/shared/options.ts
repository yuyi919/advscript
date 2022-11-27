import {
  ITypographyBaseOptions,
  ITypographyCompressionOptions,
  ITypographyOptions,
} from "./interface";

export const optionCache = new WeakMap<
  ITypographyOptions,
  {
    options: ITypographyBaseOptions;
    compressionOptions: ITypographyCompressionOptions;
  }
>();
export function getOptions(config: ITypographyOptions) {
  const gridSize = config.gridSize ?? config.fontSize;
  const column =
    config.wrapWidth! > 0 ? Math.floor(config.wrapWidth! / gridSize) : Infinity;
  const options: ITypographyBaseOptions = {
    wrapWidth: config.wrapWidth,
    // 排版网格宽度（即一个em多宽，与 textSequence 中的 fontSize 不同）
    gridSize: gridSize,
    // 行数上限
    row: 1e3,
    // 每行字数
    column,
    // 字距（仅 CJK 文字）
    xInterval: config.xInterval ?? 0,
    // 行距
    yInterval: config.yInterval ?? 6,
    // 字符间距（仅西文文字）
    letterSpacing: config.letterSpacing ?? 0,
  };

  const compressionOptions: ITypographyCompressionOptions = {
    // 开启行内标点压缩
    inlineCompression: false,
    // 强制纵横对齐
    forceGridAlignment: false,
    // 西文优先
    westernCharacterFirst: true,
    // 若纵横对齐导致无空格间隔，则强制在两边加入至少 1/4em 宽空格
    forceSpaceBetweenCJKAndWestern: true,
    // 是否进行左全角引号的位置修正
    fixCJKLeftQuote: true,
  };
  const result = { options, compressionOptions };
  optionCache.set(config, result);
  // ECS.encodeFont(config);
  return result;
}
