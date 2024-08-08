const { Linter } = require("eslint");
const js = require("@eslint/js");

module.exports = new Linter.Config({
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

