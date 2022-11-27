import xregexp from "xregexp";

xregexp.addUnicodeData(
  ["Emoji", "EMod"].map((name) => ({
    name,
    bmp: "\\p{" + name + "}",
  })),
);

/**
 * 汉字 平假名 片假名 韩文
 */
export const CJK: RegExp =
  /[\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Hangul}]/u; //getCJKRegexp()

/**
 * Lu	Uppercase_Letter	an uppercase letter
 * Ll	Lowercase_Letter	a lowercase letter
 * Lt	Titlecase_Letter	a digraphic character, with first part uppercase
 */
export const WESTERN_END: RegExp =
  /[\p{General_Category=Lu}\p{General_Category=Ll}\p{General_Category=Lt}]$/u; //getCJKRegexp()

/**
 * Lu	Uppercase_Letter	an uppercase letter
 * Ll	Lowercase_Letter	a lowercase letter
 * Lt	Titlecase_Letter	a digraphic character, with first part uppercase
 */
export const WESTERN_START: RegExp =
  /^[\p{General_Category=Lu}\p{General_Category=Ll}\p{General_Category=Lt}]/u; //getCJKRegexp()

/**
 * Symbol_Other Number_Letter Number_Other
 */
export const Other =
  /[\p{General_Category=So}\p{General_Category=Nl}\p{General_Category=No}]/;

export const REGEXP_EMOJI =
  /(?:(?!\d)\p{Emoji}(?:\p{EMod}|\uFE0F\u20E3?|[\uE0020-\uE007E]+\uE007F)?(?:\u200D\p{Emoji}(?:\p{EMod}|\uFE0F\u20E3?|[\uE0020-\uE007E]+\uE007F)?)*)/gu;

/**
 * 广义的逗号，包括中英文以及顿号
 */
export const COMMA = /[,，、]/;

/**
 * 广义的冒号，包括中英文以及分号
 */
export const COLON = /[;；:：]/;

/**
 * 广义的句号，包括中英文、感叹号、问号、省略号、破折号等等结束符号
 */
export const FULL_POINT = /[.．。!！?？⁇‼…—～]+/;

export const QUOTE_COMMON = /["']/;
export const QUOTE_LEFT = /[「『“‘"']/;
export const QUOTE_RIGHT = /[」』”’"']/;
export const QUOTE_ALL = /[「『“‘」』”’"']/;

export const BRACKET_LEFT = /[（【〖〔［｛《〈]/;
export const BRACKET_RIGHT = /[）】〗〕］｝》〉]/;

export const TOKENIZE = /*@__PURE__*/ xregexp.union(
  [
    REGEXP_EMOJI,
    /\r?\n/,
    FULL_POINT,
    /\w+/,
    /\r?\n/,
    /\s/,
    "侦探杀人游戏",
    /\W/,
  ],
  "guy",
);

export function createMatchAll(keywords: string[]) {
  return xregexp.union(
    [
      REGEXP_EMOJI,
      /\r?\n/,
      FULL_POINT,
      /\w+/,
      /\r?\n/,
      /^\s+/,
      /\s+$/,
      /\s/,
      ...keywords,
      /\W/,
    ],
    "guy",
  );
}
