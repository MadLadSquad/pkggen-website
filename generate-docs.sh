#!/usr/bin/env bash

cd docs
for file in *.md; do
    echo -e "\n\n---\n" >> "$file"
    cat _Sidebar.md >> "$file"
done
find ./ -type f -exec sed -i -E 's/https:\/\/github\.com\/MadLadSquad\/pkggen\/wiki/https:\/\/pkggen\.madladsquad\.com\/docs\//g' {} \;
cd ..
