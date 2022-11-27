/// <reference types="vitest" />
import { defineConfig } from "vite";

export default defineConfig(({ mode }) => ({
  resolve: {
    alias: [
      { find: /^lodash\//, replacement: "lodash-es/" },
      { find: /^lodash$/, replacement: "lodash-es" },
      {
        find: /^@rescript\/std\/lib\/es6(?=.+)/,
        replacement: "@rescript/std/lib/es6/",
      },
      // { find: /^overlayscrollbars$/, replacement: path.join(__dirname, "libs/OverlayScrollbars.js") },
    ],
  },
  define: {
    // "createPositionVisitor(COMPONENTS, 4, 0)": "() => 1",
    // "global(?=\.)": "globalThis",
    "process.env.DEBUGGER": "false",
    "process.env.NODE_ENV": '"production"',
  },
  plugins: [],
  server: {
    port: 3001,
    headers: {
      // 启用跨域隔离以使用SharedArrayBuffer
      "Cross-Origin-Opener-Policy": "same-origin",
      "Cross-Origin-Embedder-Policy": "require-corp",
    },
  },
  test: {
    globals: true,
    api: 9109,
    setupFiles: ["./test/setupFiles.ts"],
    // 由于node-canvas的issues(详见https://github.com/vitest-dev/vitest/issues/740),不设置maxThreads为1会报异常
    maxThreads: 1,
    minThreads: 1,
    isolate: false,
    maxConcurrency: 10,
    include: ["src/**/*.{test,spec}.{js,mjs,cjs,ts,mts,cts,jsx,tsx}"],
    benchmark: {
      include: ["src/**/*.{bench,bench}.{js,mjs,cjs,ts,mts,cts,jsx,tsx}"],
    },
    env: {
      DEBUGGER: "",
    },
  },
  esbuild: {
    ignoreAnnotations: false,
    minifyWhitespace: true,
    minifyIdentifiers: true,
    minifySyntax: true,
    mangleProps: /^_+/,
    treeShaking: true,
  },
  experimental: {},
  build: {
    terserOptions: {
      module: true,
      ecma: 2016,
      compress: {
        unsafe_methods: true,
      },
      mangle: {
        properties: {
          regex: /^_.+/,
        },
      },
      parse: {},
      format: {
        ecma: 2016,
        // beautify: true,
      },
    },
    minify: "terser",
    lib: {
      name: "piress",
      // entry: "src/test.ts",
      entry: "src/index.ts",
      fileName: (format) =>
        ["index", format, mode === "node" ? "node" : "", "js"]
          .filter(Boolean)
          .join("."),
      formats: ["cjs", "es"],
    },
    sourcemap: true,
    rollupOptions: {
      treeshake: "smallest",
      external: [
        "xregexp",
        "chevrotain",
        "@yuyi919/shared-logger",
        "@yuyi919/shared-types",
      ],
    },
    target: "es2020",
  },
}));
