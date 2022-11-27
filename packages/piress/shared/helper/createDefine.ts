export function createDefine<T>() {
  return staticI as <R extends T>(target: R) => R;
}
const staticI = (target: any) => target;
