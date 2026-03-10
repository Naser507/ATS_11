#!/bin/bash
# ===============================================
# Script: scripts/inspect_project.sh
# Purpose: Display tree structure with sizes, 
#          emptiness checks, and hidden files.
# ===============================================

# Use current directory or a provided path
TARGET_DIR="${1:-.}"

# Function to process each file/folder
process_item() {
    local indent="$1"
    local path="$2"
    local name=$(basename "$path")
    
    # Get size in human-readable format
    local size=$(du -sh "$path" 2>/dev/null | cut -f1)
    
    # Check if empty
    local empty_status=""
    if [ -d "$path" ]; then
        if [ -z "$(ls -A "$path")" ]; then
            empty_status=" [EMPTY]"
        fi
    else
        if [ ! -s "$path" ]; then
            empty_status=" [EMPTY]"
        fi
    fi

    # Print the line with colors (Blue for dirs, White for files)
    if [ -d "$path" ]; then
        printf "%s├── \e[1;34m%s\e[0m (%s)%s\n" "$indent" "$name" "$size" "$empty_status"
    else
        printf "%s├── %s (%s)%s\n" "$indent" "$name" "$size" "$empty_status"
    fi

    # If it's a directory and not empty, recurse
    if [ -d "$path" ] && [ -z "$empty_status" ]; then
        for item in "$path"/.*; do
            # Skip . and ..
            [[ "$item" == "$path/." || "$item" == "$path/.." ]] && continue
            [ -e "$item" ] && process_item "$indent    " "$item"
        done
        for item in "$path"/*; do
            [ -e "$item" ] && [[ ! "$item" =~ \/\. ]] && process_item "$indent    " "$item"
        done
    fi
}

echo "Inspecting: $(realpath "$TARGET_DIR")"
echo "."

# Start the recursion for visible and hidden items in root
for item in "$TARGET_DIR"/.*; do
    [[ "$item" == "$TARGET_DIR/." || "$item" == "$TARGET_DIR/.." ]] && continue
    [ -e "$item" ] && process_item "" "$item"
done

for item in "$TARGET_DIR"/*; do
    [ -e "$item" ] && [[ ! "$item" =~ \/\. ]] && process_item "" "$item"
done