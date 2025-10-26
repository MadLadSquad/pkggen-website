#!/usr/bin/env bash

for file in docs/*.md; do
    echo -e "\n\n---\n" >> "$file"
    cat docs/_Sidebar.md >> "$file"
done
find ./ -type f -exec sed -i -E 's/https:\/\/github\.com\/MadLadSquad\/(.*)\/wiki/https:\/\/pkggen\.madladsquad\.com\/docs\/\1/g' {} \;

