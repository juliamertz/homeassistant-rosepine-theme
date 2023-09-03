#!/bin/sh

npx @rose-pine/build -t ./template.yaml -f rgb-function
./combine.js
rm dist/rose-pine-dawn.yaml

rm -rf themes
mkdir themes ./themes/rose-pine ./themes/rose-pine-moon
mv dist/rose-pine.yaml ./themes/rose-pine
mv dist/rose-pine-moon.yaml ./themes/rose-pine-moon
rm -rf dist