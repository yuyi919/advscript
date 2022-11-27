let cache = {} as Record<string, number>; // make(undefined);
export function getMeasureCache() {
  return cache;
}
export function setMeasureCache(record: Record<string, number>) {
  cache = { ...record };
}
export function getCache(key: string) {
  // return get(cache, key);
  return cache[key];
}
export function setCache(key: string, value: number) {
  cache[key] = value;
}
export function hasCache(key: string) {
  return typeof cache[key] === "number";
}

export function cleanMeasureCache() {
  cache = {};
}

export function flush() {
  cache = { ...cache };
}
