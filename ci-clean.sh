#!/usr/bin/env bash
rm -rf *.md
rm -rf Components/ UBTCustomFunctions/ .github/ docs/
mv build/*.html .
mv build/*/ .
rm -rf build/ UVKBuildTool/

for i in `find ./ -type f -name '*.html' -printf '%p\n'` ; do
	sed -i 's/\.\//https:\/\/pkggen.madladsquad.com\//g' "$i"
	sed -i 's/\/index\.html//g' "$i"
	sed -i 's/\.html//g' "$i"
done
