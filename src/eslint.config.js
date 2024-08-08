import { Linter } from "eslint";

/** @type {Linter.Config} */
const config = {
  env: {
    browser: true,
    es2021: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:prettier/recommended"
  ],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    ecmaVersion: 12,
    sourceType: "module",
  },
  plugins: [
    "@typescript-eslint",
    "prettier"
  ],
  rules: {
    "prettier/prettier": "error",
    "no-console": "warn",
    "no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
  },
};

export default config;

