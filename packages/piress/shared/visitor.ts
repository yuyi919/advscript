import { ElementIdentifier } from "./interface";

export function* visitCompressedIds(seqs: ElementIdentifier[]) {
  let lineNumber = 0,
    prev: ElementIdentifier = seqs[lineNumber++],
    char: ElementIdentifier;
  for (; lineNumber < seqs.length; lineNumber++) {
    for (char = prev; char < seqs[lineNumber] + 1; char++) {
      yield char;
    }
    prev = char;
  }
}
