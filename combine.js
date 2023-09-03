#!/usr/bin/env node

const fs = require("fs");
const YAML = require("yaml");

const files = fs.readdirSync("./dist");
const variants = {};

for (const filename of files) {
  const content = fs.readFileSync(`./dist/${filename}`, "utf8");
  const parsed = YAML.parse(content);
  const variant = Object.keys(parsed)[0];
  variants[variant] = parsed[variant].modes.dark;
}

for (const variant of Object.keys(variants)) {
  const data = {
    [variant]: {
      modes: {
        dark: variants[variant],
        light: variants["Rosé Pine Dawn"],
      },
    },
  };

  const filename = variant.toLowerCase().replace(/\s/g, "-").replace(/é/g, "e");
  fs.writeFile(`./dist/${filename}.yaml`, YAML.stringify(data), (err) => {});
}
