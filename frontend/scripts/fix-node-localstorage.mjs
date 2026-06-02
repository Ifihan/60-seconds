if (
  typeof globalThis.localStorage !== "undefined" &&
  typeof globalThis.localStorage?.getItem !== "function"
) {
  Object.defineProperty(globalThis, "localStorage", {
    value: undefined,
    writable: true,
    configurable: true,
  });
}

if (
  typeof globalThis.sessionStorage !== "undefined" &&
  typeof globalThis.sessionStorage?.getItem !== "function"
) {
  Object.defineProperty(globalThis, "sessionStorage", {
    value: undefined,
    writable: true,
    configurable: true,
  });
}
