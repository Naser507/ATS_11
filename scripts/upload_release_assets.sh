#!/usr/bin/env bash

set -e

PROJECT_NAME="ATS_11"
PACKAGE_PATH="Release_beta/${PROJECT_NAME}_Release_beta.zip"

echo "----- ATS_11 Release Script -----"

# Ensure script runs from repo root
if [ ! -d ".git" ]; then
    echo "Error: Run this script from the project root."
    exit 1
fi

# Check package exists
if [ ! -f "$PACKAGE_PATH" ]; then
    echo "Error: Package not found at $PACKAGE_PATH"
    exit 1
fi


# Get latest release tag
LATEST_TAG=$(gh release list --limit 1 | awk '{print $1}')

echo "Latest release tag: $LATEST_TAG"

echo
read -p "Use automatic version increment? (y/n): " AUTO


increment_version () {

    local tag="$1"

    # If empty, start versioning
    if [ -z "$tag" ]; then
        echo "v1"
        return
    fi

    # Scan from right until non-digit
    suffix=$(echo "$tag" | grep -o '[0-9]*$')

    if [ -z "$suffix" ]; then
        echo "${tag}1"
    else
        prefix=${tag%"$suffix"}
        new_number=$((suffix + 1))
        echo "${prefix}${new_number}"
    fi
}


if [[ "$AUTO" == "y" || "$AUTO" == "Y" ]]; then

    NEW_TAG=$(increment_version "$LATEST_TAG")

else

    echo
    read -p "Enter release name/tag: " NEW_TAG

fi


echo
echo "Creating release: $NEW_TAG"


gh release create "$NEW_TAG" \
    "$PACKAGE_PATH" \
    --title "$NEW_TAG" \
    --notes "Release $NEW_TAG" \
    --latest


echo
# echo "Release uploaded successfully."

echo "--------------------------------"
echo "Upload complete"
echo "--------------------------------"