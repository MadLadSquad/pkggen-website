#!/usr/bin/env bash
rm -rf *.md
rm -rf docs/*.md
rm -rf Components/ UBTCustomFunctions/ .github/ blog/
mv build/*.html .
mv build/*/ .
rm -rf build/ UVKBuildTool/

for i in `find ./ -type f -name '*.html' -printf '%p\n'` ; do
	sed -i 's/\.\//https:\/\/pkggen.madladsquad.com\//g' "$i"
	sed -i 's/\/index\.html//g' "$i"
	sed -i 's/\.html//g' "$i"
done
