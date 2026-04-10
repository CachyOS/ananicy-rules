#!/usr/bin/env bash

# make sure that file that you are sorting only has games defined like this:

# # The Age of Decadence https://store.steampowered.com/app/230070/The_Age_of_Decadence/
# { "name": "AoD.exe", "type": "Game" }
# { "name": "AoD64.exe", "type": "Game" }

# temporarily remove extra comments from the file before sorting and add them back afterward
# don't use this script to sort common.rules and non-latin
# Usage: ./sort_elements.sh wine_proton_a.rules


parse_and_sort() {
    local file="$1"
    local -A ids names jsons

    local current_id="" current_name="" current_jsons=""

    save_element() {
		if [[ -z "$current_id" ]]; then
    		[[ -z "$current_name" ]] && return
    		echo "ERROR: empty id for entry: $current_name" >&2
    		exit 1
		fi
        if [[ -n "${ids[$current_id]+_}" ]]; then
            echo "ERROR: duplicate id '$current_id', found in: $current_name" >&2
            exit 1
        fi
        ids["$current_id"]="$current_id"
        names["$current_id"]="$current_name"
        jsons["$current_id"]="$current_jsons"
    }

    make_id() {
        local title="$1"
        echo "$title" | sed 's/http.*//' | sed 's/[^a-zA-Z0-9 ]//g' | tr -d ' ' | tr '[:upper:]' '[:lower:]'
    }

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" == \#* ]]; then
            save_element
            current_name="$line"
            local title="${line:2}"
            current_id=$(make_id "$title")
            current_jsons=""
        elif [[ "$line" == \{* ]]; then
            [[ -n "$current_jsons" ]] && current_jsons+=$'\n'
            current_jsons+="$line"
        fi
    done < "$file"

    save_element

    local sorted_ids
    mapfile -t sorted_ids < <(printf '%s\n' "${!ids[@]}" | sort)

    local output=""
    for id in "${sorted_ids[@]}"; do
        output+="${names[$id]}"$'\n'
        output+="${jsons[$id]}"$'\n'$'\n'
    done

    printf '%s' "$output" > "$file"
}

parse_and_sort "${1}"
