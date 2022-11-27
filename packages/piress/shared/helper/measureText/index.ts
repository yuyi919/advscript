import * as cache from "../cache";
import { measureTextWidth } from "./core";
import "./env.d";

export function calcWidthWithCache(
  text: string,
  font: string,
  letterSpacing: number,
): f64 {
  const keyword = text + "|" + font + "|" + letterSpacing;
  let width: f64;
  if (cache.hasCache(keyword)) {
    // console.log("calcWithChar", cacheMap.get(key), key)
    return cache.getCache(keyword);
  }
  width = measureTextWidth(text, font, letterSpacing);
  // console.log("calcWidthWithCache", text, width);
  cache.setCache(keyword, width);
  return width;
}

export * from "./core";
