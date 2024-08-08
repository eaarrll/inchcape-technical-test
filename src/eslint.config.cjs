import { Linter } from "eslint";
import { js } from "@eslint/js";

const config = new Linter.Config({
  files: ["**/*.js"],
  languageOptions: {
    ecmaVersion: "latest",
    sourceType: "module",
    globals: {
      process: "readonly",
      __dirname: "readonly",
    },
  },
  rules: {
    "no-unused-vars": "warn",
    "no-console": "off",
  },
  plugins: {
    js,
  },
  linterOptions: {
    reportUnusedDisableDirectives: true,
  },
});

export default config;

