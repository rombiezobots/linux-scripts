#!/usr/bin/env bash
# Rename a folder, and replace its old name with the new one in every
# file and folder name inside it.
#
# Usage: rename_tree.sh <folder> <new_name>
#   e.g. rename_tree.sh shot_010 shot_020
#        shot_010/shot_010_comp.nk  ->  shot_020/shot_020_comp.nk

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <folder> <new_name>" >&2
    exit 1
fi

folder="${1%/}"
old="$(basename -- "$folder")"
new="$2"

if [[ ! -d "$folder" ]]; then
    echo "Error: '$folder' is not a folder" >&2
    exit 1
fi

# -depth renames the contents before the folders that hold them;
# the top folder itself comes last.
find "$folder" -depth -print0 | while IFS= read -r -d '' path; do
    name="$(basename -- "$path")"
    new_name="${name//"$old"/"$new"}"
    [[ "$new_name" == "$name" ]] && continue

    target="$(dirname -- "$path")/$new_name"
    if [[ -e "$target" ]]; then
        echo "Skip (exists): $path -> $target" >&2
        continue
    fi

    echo "$path -> $target"
    mv -- "$path" "$target"
done
