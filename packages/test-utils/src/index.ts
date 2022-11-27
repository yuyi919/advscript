import { isPrimitive, isStr } from "@yuyi919/shared-types";
import { groupBy } from "lodash";
//@ts-ignore
import stringTable from "string-table";
import { inspect } from "util";

export function createViewTable<T>(
  target: T[],
  config: ViewTableOptions<T> = {},
) {
  const result = target;
  viewMap.set(result, config);
  return result;
}
// const view_table = Symbol("table-view");
const viewMap = new WeakMap<any[], ViewTableOptions<any>>();

type ViewTableOptions<T> = {
  label?: string;
  formatters?: {
    [K in keyof T]?: (value: T[K], header: string) => any;
  };
  headers?: string[];
  groupBy?: ((value: T) => string) | keyof T;
};

export function viewString(value: string) {
  return JSON.stringify(value);
}

expect.addSnapshotSerializer({
  serialize(value: any[], config, indentation, depth, refs, printer) {
    // `printer` is a function that serializes a value using existing plugins.
    const { label, groupBy: _groupBy, ...options } = viewMap.get(value)!;
    const tableOptions = {
      ...options,
      formatters: {
        ...Object.fromEntries(
          Object.keys(value[0]).map((key) => [
            key,
            (value: any) =>
              isStr(value)
                ? JSON.stringify(value)
                : isPrimitive(value)
                ? value
                : inspect(value, false, 1), //|| printer(value, config, "", 0, refs)
          ]),
        ),
        ...options.formatters,
      },
    };
    return (
      indentation +
      "\t * \r\n" +
      (_groupBy
        ? Object.entries(groupBy(value, _groupBy))
            .map(([group, value]) => {
              return formatTableString(
                stringTable.create(value, tableOptions),
                group,
              );
            })
            .join("\r\n")
        : formatTableString(stringTable.create(value, tableOptions)))
    );
    function formatTableString(str: string, group?: any) {
      return (
        `${label || "View Array"}${
          group ? `: Group ${group}` : ""
        }\r\n\r\n${str}`
          .split(/\r?\n/g)
          .map((str) => indentation + "\t * " + str)
          .join("\r\n") +
        "\r\n" +
        indentation +
        "\t *"
      );
    }
  },
  test(val: any) {
    return val instanceof Array && viewMap.has(val);
  },
});
