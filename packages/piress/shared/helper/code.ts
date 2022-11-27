export const SPACES = toCodes(" 　\t");
/**
 * 广义的逗号，包括中英文以及顿号
 */
export const COMMA = toCodes(",，、");
/**
 * 广义的冒号，包括中英文以及分号
 */
export const COLON = toCodes(";；:：");
/**
 * 广义的句号，包括中英文、感叹号、问号、省略号、破折号等等结束符号
 */
export const FULL_POINT = toCodes(`.．。!！?？⁇‼…—⸺～`);

export const QUOTE_COMMON = toCodes(`"'`);
export const QUOTE_LEFT = toCodes(`「『“‘"'`);
export const QUOTE_RIGHT = toCodes(`」』”’"'`);
export const QUOTE_ALL = toCodes(`「『“‘」』”’"'`);

export const BRACKET_LEFT = toCodes(`（【〖〔［｛《〈`);
export const BRACKET_RIGHT = toCodes(`）】〗〕］｝》〉`);

export const COMPRESSLEFT = toCodes("「『“‘（【〖〔［｛《〈");

export const EOL = toCodes("\r\n");
export const WS = [...SPACES, ...EOL];
export const CJK_LEFT_QUOTE = "“".charCodeAt(0);

export function toCodes(str: string): i32[] {
  let index = 0,
    result: i32[] = [];
  while (index < str.length) {
    result.push(str.charCodeAt(index++));
  }
  return result;
}
