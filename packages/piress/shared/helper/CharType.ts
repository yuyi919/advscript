import { CJK } from "./regexp";

export enum ElementType {
  INVALID,
  Char,
  Word,
  Space,
  EOL,
  COMMA,
  COLON,
  FULL_POINT,
  QUOTE_LEFT,
  QUOTE_RIGHT,
  QUOTE_COMMON,
  BRACKET_LEFT,
  BRACKET_RIGHT,
}

// const check = as<(code: number, ElementType: any) => number>(
//   new Function(
//     "code",
//     "ElementType",
//     `switch(code) {
//   ${unionBy(
//     Object.entries({
//       Space: Codes.SPACES,
//       EOL: Codes.EOL,
//       COMMA: Codes.COMMA,
//       COLON: Codes.COLON,
//       FULL_POINT: Codes.FULL_POINT,
//       QUOTE_LEFT: Codes.QUOTE_LEFT,
//       QUOTE_RIGHT: Codes.QUOTE_RIGHT,
//       QUOTE_COMMON: Codes.QUOTE_COMMON,
//       BRACKET_LEFT: Codes.BRACKET_LEFT,
//       BRACKET_RIGHT: Codes.BRACKET_RIGHT,
//     })
//       .reverse()
//       .flatMap(([key, CODES]) =>
//         CODES.map(
//           (code) => [code, `case ${code}:return ElementType.${key};`] as const,
//         ),
//       )
//       .sort(([a], [b]) => a - b),
//     (o) => o[0],
//   )
//     .map((o) => o[1])
//     .join("\r\n  ")}
//   default:
//     return ElementType.Char;
// }`,
//   ),
// );

export function checkElementType(token: string): number {
  const type = checkCode(token.charCodeAt(0));
  return type === ElementType.Char && (!CJK.test(token) || token.length > 1)
    ? ElementType.Word
    : type;
}

// export {
//   checkCode,
//   // isBRACKET,
//   // isQUOTE,
//   // isWS,
//   // checkInvalidEndChar,
//   // checkValidEndChar,
// } from "../wasm";
export function checkCode(code: i32): ElementType {
  switch (code) {
    case 9:
      return ElementType.Space;
    case 10:
      return ElementType.EOL;
    case 13:
      return ElementType.EOL;
    case 32:
      return ElementType.Space;
    case 33:
      return ElementType.FULL_POINT;
    case 34:
      return ElementType.QUOTE_COMMON;
    case 39:
      return ElementType.QUOTE_COMMON;
    case 44:
      return ElementType.COMMA;
    case 46:
      return ElementType.FULL_POINT;
    case 58:
      return ElementType.COLON;
    case 59:
      return ElementType.COLON;
    case 63:
      return ElementType.FULL_POINT;
    case 8212:
      return ElementType.FULL_POINT;
    case 8216:
      return ElementType.QUOTE_LEFT;
    case 8217:
      return ElementType.QUOTE_RIGHT;
    case 8220:
      return ElementType.QUOTE_LEFT;
    case 8221:
      return ElementType.QUOTE_RIGHT;
    case 8230:
      return ElementType.FULL_POINT;
    case 8252:
      return ElementType.FULL_POINT;
    case 8263:
      return ElementType.FULL_POINT;
    case 11834:
      return ElementType.FULL_POINT;
    case 12288:
      return ElementType.Space;
    case 12289:
      return ElementType.COMMA;
    case 12290:
      return ElementType.FULL_POINT;
    case 12296:
      return ElementType.BRACKET_LEFT;
    case 12297:
      return ElementType.BRACKET_RIGHT;
    case 12298:
      return ElementType.BRACKET_LEFT;
    case 12299:
      return ElementType.BRACKET_RIGHT;
    case 12300:
      return ElementType.QUOTE_LEFT;
    case 12301:
      return ElementType.QUOTE_RIGHT;
    case 12302:
      return ElementType.QUOTE_LEFT;
    case 12303:
      return ElementType.QUOTE_RIGHT;
    case 12304:
      return ElementType.BRACKET_LEFT;
    case 12305:
      return ElementType.BRACKET_RIGHT;
    case 12308:
      return ElementType.BRACKET_LEFT;
    case 12309:
      return ElementType.BRACKET_RIGHT;
    case 12310:
      return ElementType.BRACKET_LEFT;
    case 12311:
      return ElementType.BRACKET_RIGHT;
    case 65281:
      return ElementType.FULL_POINT;
    case 65288:
      return ElementType.BRACKET_LEFT;
    case 65289:
      return ElementType.BRACKET_RIGHT;
    case 65292:
      return ElementType.COMMA;
    case 65294:
      return ElementType.FULL_POINT;
    case 65306:
      return ElementType.COLON;
    case 65307:
      return ElementType.COLON;
    case 65311:
      return ElementType.FULL_POINT;
    case 65339:
      return ElementType.BRACKET_LEFT;
    case 65341:
      return ElementType.BRACKET_RIGHT;
    case 65371:
      return ElementType.BRACKET_LEFT;
    case 65373:
      return ElementType.BRACKET_RIGHT;
    case 65374:
      return ElementType.FULL_POINT;
    default:
      return ElementType.Char;
  }
}

export function isWS(type: ElementType): bool {
  return type === ElementType.Space || type === ElementType.EOL;
}

export function isQUOTE(type: ElementType): bool {
  return (
    type === ElementType.QUOTE_COMMON ||
    type === ElementType.QUOTE_LEFT ||
    type === ElementType.QUOTE_RIGHT
  );
}
export function isQUOTE_LEFT(type: ElementType): bool {
  return type === ElementType.QUOTE_LEFT;
}

export function isBRACKET(type: ElementType): bool {
  return (
    type === ElementType.BRACKET_LEFT || type === ElementType.BRACKET_RIGHT
  );
}

export function checkValidEndChar(type: ElementType): bool {
  return (
    type === ElementType.EOL ||
    type === ElementType.COMMA ||
    type === ElementType.COLON ||
    type === ElementType.FULL_POINT ||
    type === ElementType.QUOTE_COMMON ||
    type === ElementType.QUOTE_RIGHT ||
    type === ElementType.BRACKET_RIGHT
  );
}

export function checkInvalidEndChar(type: ElementType): bool {
  return (
    type === ElementType.QUOTE_LEFT ||
    type === ElementType.BRACKET_LEFT ||
    type === ElementType.Space
  );
}
