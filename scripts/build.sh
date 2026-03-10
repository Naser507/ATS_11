#!/bin/bash
# ===============================================
# Updated Script: scripts/package_release.sh
# Purpose: Automatically resolve and bundle all dependencies
# ===============================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE_DIR="$PROJECT_ROOT/Release_beta"
TEMP_RELEASE="$RELEASE_DIR/ATS_11"
BIN_DEST="$TEMP_RELEASE/bin"
BUILD_EXE="$PROJECT_ROOT/build/client/release/ATS_11.exe"

# 1. Setup Clean Environment
rm -rf "$TEMP_RELEASE"
mkdir -p "$BIN_DEST"
mkdir -p "$TEMP_RELEASE/assets"

# 2. Copy the EXE
cp "$BUILD_EXE" "$BIN_DEST/"

# 3. THE SMART PART: Resolve Dependencies
echo "Scanning $BUILD_EXE for required DLLs..."

# Use objdump to find 'DLL Name' entries
# Then we filter out core Windows system DLLs that everyone already has
# Then we search your MinGW and wxWidgets build folders for the matches
NEEDED_DLLS=$(x86_64-w64-mingw32-objdump -p "$BUILD_EXE" | grep "DLL Name" | sed 's/.*DLL Name: //')

# Define where your compiler and wxWidgets keep their DLLs
SEARCH_PATHS=(
    "/usr/x86_64-w64-mingw32/bin"
    "/usr/lib/gcc/x86_64-w64-mingw32"
    "$HOME/Libraries/wxWidgets-3.2.6/build-mingw/lib" # Path to your wx DLLs
)

for dll in $NEEDED_DLLS; do
    # Skip standard Windows system files (Kernel32, User32, etc.)
    if [[ ! "$dll" =~ ^(KERNEL32|USER32|GDI32|MSVCRT|ADVAPI32|SHELL32|ole32|COMCTL32|WS2_32|RPCRT4) ]]; then
        found=false
        for path in "${SEARCH_PATHS[@]}"; do
            if [ -f "$path/$dll" ]; then
                echo "Found and copying: $dll"
                cp "$path/$dll" "$BIN_DEST/"
                found=true
                break
            fi
        done
        if [ "$found" = false ]; then
            echo "Warning: Could not find dependency: $dll"
        fi
    fi
done

# 4. Copy Assets and Config
cp -r "$PROJECT_ROOT/assets/"* "$TEMP_RELEASE/assets/"
[ -d "$PROJECT_ROOT/config" ] && cp -r "$PROJECT_ROOT/config" "$TEMP_RELEASE/"

# 5. Zip and Finish
cd "$RELEASE_DIR" && zip -r "ATS_11_Release_beta.zip" "ATS_11"
echo "Package built at: $RELEASE_DIR/ATS_11_Release_beta.zip"