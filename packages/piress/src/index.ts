import { calc, create, ecs, element } from "piress-core-rescript";
import {
  Cache,
  createElements,
  getOptions,
  ITextSequenceBase,
  ITypographyOptions,
  optionCache,
  visitCompressedIds,
} from "piress-core-shared";
import { tokenize } from "./tokenize";

export function createTextTypography(
  input: string,
  config: ITypographyOptions,
  outputEcs: true,
): ITextSequenceBase & { elements: element[] };
export function createTextTypography(
  input: string,
  config: ITypographyOptions,
  outputEcs?: false,
): ITextSequenceBase;
export function createTextTypography(
  text: string,
  config: ITypographyOptions,
  outputEcs?: true | false,
): ITextSequenceBase & { elements?: element[] } {
  const len = text.length;
  ecs.grow((len > 100 ? len * 1.2 : len + 20) | 0);
  // console.time("calcTextTypography2");
  const input: string[] = tokenize(text);
  const { options, compressionOptions } =
    optionCache.get(config) || getOptions(config);
  const textSequence = createElements(input, (char) => {
    return create(
      char,
      // config.fontSize as i32,
      // `${config.fontSize}px ${config.fontFamily}`,
      config.fontStyle || "normal",
      config.fontVariant || "normal",
      config.fontWeight || "normal",
      config.fontSize,
      config.fontFamily,
      // config.fontSize + "px " + config.fontFamily,
      // "25px 微软雅黑",
      config.letterSpacing || 0,
    );
  });
  const ctx = calc(textSequence, options);
  // console.timeEnd("calcTextTypography2");
  if (outputEcs) {
    const elements = [] as element[];
    for (const el of visitCompressedIds(ctx.seqs)) {
      if (ecs.getWidth(el) > 0) {
        // const cursor = ecs.cursor(el);
        elements.push(ecs.output(el));
      }
    }
    // console.log(elements);
    return {
      ...ctx,
      elements: elements,
    };
  }
  return ctx;
}

export { Cache };
