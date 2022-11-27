import { createMatchAll } from "piress-core-shared";

export function tokenize(text: string) {
  // console.time("matchAll");
  const input = text.trimEnd().matchAll(matchAllRegexp),
    texts = [] as string[];
  let i = -1;
  for (const [match] of input) {
    texts[++i] = match;
  }
  // console.timeEnd("matchAll");
  return texts;
  // return text.replace(/\r\n/g, "\n").split(/(\w+|\s|侦探杀人游戏|\W)/)
}

export function* generateTokens(text: string) {
  const input = text.trimEnd().matchAll(matchAllRegexp);
  for (const [match] of input) {
    yield match;
  }
  // return text.replace(/\r\n/g, "\n").split(/(\w+|\s|侦探杀人游戏|\W)/)
}

let matchAllRegexp = createMatchAll(["侦探杀人游戏"]);
