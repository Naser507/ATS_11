#!/bin/bash
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE_DIR="$PROJECT_ROOT/Release_beta"
RELEASE_NAME="ATS_11"
TEMP_RELEASE="$RELEASE_DIR/$RELEASE_NAME"
BIN_DEST="$TEMP_RELEASE/bin"

BUILD_EXE_DIR="$PROJECT_ROOT/build/client/release"
EXE_FILE="ATS_11.exe"
TARGET_EXE="$BUILD_EXE_DIR/$EXE_FILE"

# --- 1. Clean & Setup ---
rm -rf "$TEMP_RELEASE"
mkdir -p "$BIN_DEST"
mkdir -p "$TEMP_RELEASE/assets"

# --- 2. Copy Executable ---
cp "$TARGET_EXE" "$BIN_DEST/"

# --- 3. AUTO-RESOLVE DEPENDENCIES ---
echo "Searching for dependencies..."

# We use objdump to find 'DLL Name' entries in the .exe
# Then we search common MinGW paths for those files.
MINGW_PATH="/usr/lib/gcc/x86_64-w64-mingw32" # Adjust based on your 'whereis' output
MINGW_BIN="/usr/x86_64-w64-mingw32/bin"      # Common location for wxWidgets/System DLLs

# Get list of DLLs the EXE actually asks for
NEEDED_DLLS=$(x86_64-w64-mingw32-objdump -p "$TARGET_EXE" | grep "DLL Name" | sed 's/.*DLL Name: //')

for dll in $NEEDED_DLLS; do
    # Ignore standard Windows system DLLs (kernel32.dll, etc) as they exist on every PC
    if [[ ! "$dll" =~ ^(KERNEL32|USER32|GDI32|MSVCRT|ADVAPI32|SHELL32|ole32|COMCTL32) ]]; then
        # Search for the DLL in your cross-compiler folders
        FOUND=$(find /usr/x86_64-w64-mingw32/ /usr/lib/gcc/x86_64-w64-mingw32/ -name "$dll" -print -quit 2>/dev/null)
        
        if [ -n "$FOUND" ]; then
            echo "Found and copying: $dll"
            cp "$FOUND" "$BIN_DEST/"
        else
            echo "Warning: Could not find $dll in system paths."
        fi
    fi
done

# --- 4. Copy Assets & Config ---
cp -r "$PROJECT_ROOT/assets/"* "$TEMP_RELEASE/assets/"
[ -d "$PROJECT_ROOT/config" ] && cp -r "$PROJECT_ROOT/config" "$TEMP_RELEASE/"

# --- 5. Zip it up ---
cd "$RELEASE_DIR" && zip -r "${RELEASE_NAME}_Release_beta.zip" "$RELEASE_NAME"
echo "Done! Package is ready."