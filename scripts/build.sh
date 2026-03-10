#!/bin/bash
# ===============================================
# Final Build Script for ATS_11
# ===============================================

# -------------------------
# 0. Set project root
# -------------------------
PROJECT_ROOT="$HOME/projects_series/ATS_11"
echo "Project root: $PROJECT_ROOT"

# Paths
RELEASE_DIR="$PROJECT_ROOT/Release_beta"
TEMP_RELEASE="$RELEASE_DIR/ATS_11"
BIN_DEST="$TEMP_RELEASE/bin"
BUILD_EXE="$PROJECT_ROOT/build/client/release/ATS_11.exe"

# -------------------------
# 1. wxWidgets paths
# -------------------------
WX_ROOT="$HOME/Libraries/wxWidgets-3.2.6"
WX_INCLUDE="$WX_ROOT/include"
WX_BUILD_INCLUDE="$WX_ROOT/build-mingw/lib/wx/include/x86_64-w64-mingw32-msw-unicode-static-3.2"
WX_LIB="$WX_ROOT/build-mingw/lib"

WX_CXXFLAGS="-I$WX_INCLUDE -I$WX_BUILD_INCLUDE -D_UNICODE -D__WXMSW__"
WX_LDFILES="$WX_LIB/libwx_mswu_core-3.2-x86_64-w64-mingw32.a $WX_LIB/libwx_baseu-3.2-x86_64-w64-mingw32.a"

# -------------------------
# 2. Clean previous build
# -------------------------
echo "Cleaning old build: $BUILD_EXE"
rm -rf "$TEMP_RELEASE"
mkdir -p "$BIN_DEST"
mkdir -p "$TEMP_RELEASE/assets"
rm -f "$BUILD_EXE"

# -------------------------
# 3. Compile ATS_11.exe
# -------------------------
echo "Compiling fresh binary from main.cpp..."
mkdir -p "$(dirname "$BUILD_EXE")"

x86_64-w64-mingw32-g++ "$PROJECT_ROOT/client/windows/src/main.cpp" \
    -o "$BUILD_EXE" \
    -static-libgcc -static-libstdc++ \
    -mwindows \
    $WX_CXXFLAGS \
    $WX_LDFILES \
    -lshlwapi -lole32 -luuid -lversion -lcomctl32 -loleaut32 -luxtheme

# Stop if compilation failed
if [ ! -f "$BUILD_EXE" ]; then
    echo "Error: Compilation failed! Check your C++ code."
    exit 1
fi

# -------------------------
# 4. Copy EXE
# -------------------------
cp "$BUILD_EXE" "$BIN_DEST/"

# -------------------------
# 5. Resolve DLL Dependencies
# -------------------------
echo "Scanning $BUILD_EXE for required DLLs..."
NEEDED_DLLS=$(x86_64-w64-mingw32-objdump -p "$BUILD_EXE" | grep "DLL Name" | sed 's/.*DLL Name: //')

SEARCH_PATHS=(
    "/usr/x86_64-w64-mingw32/bin"
    "/usr/lib/gcc/x86_64-w64-mingw32"
    "$WX_LIB"
)

for dll in $NEEDED_DLLS; do
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

# -------------------------
# 6. Copy assets and config
# -------------------------
cp -r "$PROJECT_ROOT/assets/"* "$TEMP_RELEASE/assets/"
[ -d "$PROJECT_ROOT/config" ] && cp -r "$PROJECT_ROOT/config" "$TEMP_RELEASE/"

# -------------------------
# 7. Zip the release
# -------------------------
cd "$RELEASE_DIR" && zip -r "ATS_11_Release_beta.zip" "ATS_11"
echo "Package built at: $RELEASE_DIR/ATS_11_Release_beta.zip"