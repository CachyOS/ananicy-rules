#!/usr/bin/env bash

# this script can sort rules in wine_proton and linux-native folders
# don't use this script to sort common.rules and non-latin rules
# use it to sort files "from a to z", "the" and numerical

# Usage: ./sort_elements.sh wine_proton_a.rules
#
# Usage to sort multiple files with single command (a to z) numerical and the. run this script in the root of the repo
# 
# for letter in {a..z} numerical the; do
#     ./sort-games.sh "00-default/Games/wine_proton/wine_proton_${letter}.rules"
# done

# for letter in {a..z} numerical the; do
#     ./sort-games.sh "00-default/Games/linux-native/linux-native_${letter}.rules"
# done


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

    is_header_line() {
        local l="$1"
        [[ -z "$l" ]] && return 0
        [[ "$l" == "# Add games in alphabetical order." ]] && return 0
        [[ "$l" == "# Add name of game next to the url." ]] && return 0
        [[ "$l" == "# Get name of game from steam." ]] && return 0
        [[ "$l" == "# If not from any store add name you think it needs." ]] && return 0
        [[ "$l" == "# There are a lot of titles with \"The\" prefix. I want to separate these titles from the game titles actually start with \"T\"." ]] && return 0
        [[ "$l" == "### "* ]] && return 0
        return 1
    }

    local header=""
    local header_line_count=0
    local all_lines=()
    mapfile -t all_lines < "$file"

    for line in "${all_lines[@]}"; do
        if is_header_line "$line"; then
            header+="$line"$'\n'
            (( header_line_count++ ))
        else
            break
        fi
    done

    local body_lines=("${all_lines[@]:$header_line_count}")

    for line in "${body_lines[@]}"; do
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
    done

    save_element

    local sorted_ids
    mapfile -t sorted_ids < <(printf '%s\n' "${!ids[@]}" | sort)

    local output="${header%$'\n'}"$'\n'
    local last_id="${sorted_ids[-1]}"
    for id in "${sorted_ids[@]}"; do
        output+="${names[$id]}"$'\n'
        if [[ "$id" == "$last_id" ]]; then
            output+="${jsons[$id]}"$'\n'
        else
            output+="${jsons[$id]}"$'\n'$'\n'
        fi
    done

    printf '%s' "${output%$'\n'}" > "$file"
}

parse_and_sort "${1}"
