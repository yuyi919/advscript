import { createViewTable } from "@internal/test-utils";
import { checkElementType, ElementType } from "./CharType";
import { mockedTexts } from "./text";
import { lexer, tokenize } from "./tokenize";

describe.each(mockedTexts)("tokenize %s", (text) => {
  it("check", () => {
    const tokens = tokenize(text).map((image) => ({
      image,
      type: ElementType[checkElementType(image)],
      // typeCode: checkCharType(image),
    }));
    expect(tokens).toEqual(
      lexer.tokenize(text.trimEnd()).tokens.map((token) => ({
        image: token.image,
        type: token.tokenType.name,
        // typeCode: CharType[token.tokenType.name],
      })),
    );
    expect(createViewTable(tokens)).toMatchSnapshot();
  });
});
