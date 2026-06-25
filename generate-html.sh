#!/usr/bin/env bash
if [[ "$1" == "" ]]; then
	mkdir build &> /dev/null || (rm -rf build && mkdir build)
	cp *.md docs/ build/ -r
	cd build/ || exit
fi

extract() {
	# Try H1 header first
	title=$(grep -E "^# " "$1" | head -1 | sed 's/^# //')
	# If no H1, try lower-level headers
	if [[ -z "$title" ]]; then
		title=$(grep -E "^##+ " "$1" | head -1 | sed -E 's/^##+ //')
	fi
	# If still empty, fall back to capitalized filename (removes hyphens/underscores/leading spaces)
	if [[ -z "$title" ]]; then
		title=$(basename "$1" .md | tr '-' ' ' | tr '_' ' ' | sed 's/^ *//')
	fi

	out_dir=$(echo `dirname $1`/`basename $1 md`html 2> /dev/null)

	echo "Processing file: ${out_dir}"

	pandoc --from=gfm --standalone --template ../template.html -s "$1" -o "${out_dir}" --metadata title="${title}" 2> /dev/null
	sed -i 's/<table style="width:100%;">/<div class="table"><table style="width:100%;">/g' "${out_dir}"
	sed -i 's/<\/table>/<\/table><\/div>/g' "${out_dir}"

	rm $(realpath "$1")
}
export -f extract

cpus=$(grep -c processor /proc/cpuinfo) || cpus=$(sysctl -n hw.ncpu)
find ./ -type f -name '*.md' -printf '%p\n' | parallel -j "${cpus}" extract || exit

cp ../main.css .
cp ../TwemojiMozilla.woff2 .
