#!/usr/bin/env bash

# this script can sort rules in wine_proton and linux-native folders
# don't use this script to sort non-latin rules
# use it to sort files "from a to z", "the", numerical and "common"
# for more information run ./sort-games.sh --help

is_header_line() {
    local l="$1"
    [[ -z "$l" ]] && return 0
    [[ "$l" == "# Add games in alphabetical order." ]] && return 0
    [[ "$l" == "# Add name of game next to the url." ]] && return 0
    [[ "$l" == "# Ordered based on executable name" ]] && return 0
    [[ "$l" == "# Get name of game from steam." ]] && return 0
    [[ "$l" == "# If not from any store add name you think it needs." ]] && return 0
    [[ "$l" == "# There are a lot of titles with \"The\" prefix. I want to separate these titles from the game titles actually start with \"T\"." ]] && return 0
    [[ "$l" == "### "* ]] && return 0
    return 1
}


parse_and_sort() {
    local file="$1"
    local use_diacritics="$2"
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
        if [[ -n "$use_diacritics" ]]; then
            echo "$title" | sed 's/https\?:[^ ]*//' | python3 -c "import sys,re; t=sys.stdin.read(); t=re.sub(r'[^\x00-\u024f ]','',t); t=re.sub(r'[^a-zA-Z0-9\u00c0-\u024f ]','',t); print(t,end='')" | tr '[:upper:]' '[:lower:]' | tr -d ' '
        else
            echo "$title" | sed 's/http.*//' | sed 's/[^a-zA-Z0-9 ]//g' | tr -d ' ' | tr '[:upper:]' '[:lower:]'
        fi
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

parse_and_sort_common() {
    local file="$1"
    local -A names jsons
    local current_name="" current_json="" current_key="" footer=""

    save_element() {
        [[ -z "$current_key" ]] && return
        names["$current_key"]="$current_name"
        jsons["$current_key"]="$current_json"
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
        if [[ -n "$footer" ]]; then
            footer+="$line"$'\n'
            continue
        fi
        if [[ "$line" == "### "* ]]; then
            save_element
            current_name="" current_json="" current_key=""
            footer="$line"$'\n'
            continue
        fi
        if [[ "$line" == \#* ]]; then
            if [[ -n "$current_json" ]]; then
                save_element
                current_name="$line"
                current_json=""
                current_key=""
            else
                [[ -n "$current_name" ]] && current_name+=$'\n'
                current_name+="$line"
            fi
        elif [[ "$line" == \{* ]]; then
            current_json="$line"
            current_key=$(echo "$line" | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        fi
    done

    save_element

    local sorted_keys
    mapfile -t sorted_keys < <(printf '%s\n' "${!names[@]}" | sort -f)

    local output="${header%$'\n'}"$'\n'
    local last_key="${sorted_keys[-1]}"
    for key in "${sorted_keys[@]}"; do
        output+="${names[$key]}"$'\n'
        if [[ "$key" == "$last_key" ]]; then
            output+="${jsons[$key]}"$'\n'
        else
            output+="${jsons[$key]}"$'\n'$'\n'
        fi
    done

    if [[ -n "$footer" ]]; then
        output+=$'\n'"${footer%$'\n'}"
    fi

    printf '%s' "${output%$'\n'}" > "$file"
}

print_help() {
    echo "Usage: ./sort-games.sh <file>"
    echo "       ./sort-games.sh [OPTION] [FILE]"
    echo ""
    echo "Options:"
    echo "  --all                    Sort wine_proton and linux-native a-z, numerical, 'the' and 'common' files"
    echo "  --proton                 Sort wine_proton a-z, numerical, 'the' and 'common' files"
    echo "  --native                 Sort linux-native a-z, numerical, 'the' and 'common' files"
    echo "  --common <file>          Sort common.rules file"
    echo "  --use-diacritics <file>  sort japanese/chinese entries (requires python)."
    echo "                           Entries should have pinyin (for chinese) or romaji (for japanese) as prefix."
    echo "                           See examples in wine_proton_non-latin.rules."
    echo "                           Make a temporary file, e.g. chinese.rules, move entries there,"
    echo "                           sort, then move entries back to the corresponding file."
    echo ""    
    echo "Note: Do not use this script to sort non-latin files."    
    echo ""
    echo "Examples:"
    echo "  ./sort-games.sh --all"
    echo "  ./sort-games.sh --proton"
    echo "  ./sort-games.sh --common 00-default/Games/wine_proton/common.rules"
    echo "  ./sort-games.sh --use-diacritics chinese.rules"
    echo "  ./sort-games.sh 00-default/Games/wine_proton/wine_proton_a.rules"
}




if [[ "$1" == "--help" ]]; then
    print_help
elif [[ "$1" == "--common" ]]; then
    parse_and_sort_common "$2"
elif [[ "$1" == "--use-diacritics" ]]; then
    parse_and_sort "$2" "1"
elif [[ "$1" == "--proton" ]]; then
    for letter in {a..z} numerical the; do
        parse_and_sort "00-default/Games/wine_proton/wine_proton_${letter}.rules" ""
    done
    parse_and_sort_common "00-default/Games/wine_proton/common.rules"
elif [[ "$1" == "--native" ]]; then
    for letter in {a..z} numerical the; do
        parse_and_sort "00-default/Games/linux-native/linux-native_${letter}.rules" ""
    done
    parse_and_sort_common "00-default/Games/linux-native/common.rules"
elif [[ "$1" == "--all" ]]; then
    for letter in {a..z} numerical the; do
        parse_and_sort "00-default/Games/wine_proton/wine_proton_${letter}.rules" ""
    done
    parse_and_sort_common "00-default/Games/wine_proton/common.rules"
    for letter in {a..z} numerical the; do
        parse_and_sort "00-default/Games/linux-native/linux-native_${letter}.rules" ""
    done
    parse_and_sort_common "00-default/Games/linux-native/common.rules"
elif [[ "$1" == --* ]]; then
    echo "Unknown option: $1. Run --help for usage." >&2
    exit 1
else
    parse_and_sort "$1" ""
fi
