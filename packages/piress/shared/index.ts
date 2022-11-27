export * from "./helper";
export * from "./interface";
export * from "./options";
export * from "./visitor";
import "./env.d";
import { ElementIdentifier, ElementIdentifierList } from "./interface";

export function createElements<T>(
  target: T[],
  expect: (target: T, i: number) => ElementIdentifier,
): ElementIdentifierList {
  let ints = new Int32Array(target.length),
    id: ElementIdentifier,
    index = 0x0 | 0,
    i = index,
    len = target.length; // 保证紧凑
  while (i < len) {
    if ((id = expect(target[i] as T, i)!)) {
      ints[index] = id;
      index++;
    }
    i++;
  }
  return ints as unknown as ElementIdentifierList;
}
