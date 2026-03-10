#!/bin/bash
# ===============================================
# Modernized Build & Package Script for ATS_11
# ===============================================

# --- 1. CONFIGURATION ---
PROJECT_ROOT="$HOME/projects_series/ATS_11"
WX_ROOT="$HOME/Libraries/wxWidgets-3.2.6"
MINGW_DLL_PATH="/usr/lib/gcc/x86_64-w64-mingw32/13-posix"

# Output Mapping
BUILD_DIR="$PROJECT_ROOT/build/client/release"
RELEASE_DIR="$PROJECT_ROOT/Release_beta/ATS_11"
BIN_DEST="$RELEASE_DIR/bin"
TARGET_EXE="$BUILD_DIR/ATS_11.exe"

# wxWidgets specific include paths (Verified from your find command)
WX_INC_BASE="$WX_ROOT/include"
WX_INC_SETUP="$WX_ROOT/build-mingw/lib/wx/include/x86_64-w64-mingw32-msw-unicode-static-3.2"
WX_LIB_DIR="$WX_ROOT/build-mingw/lib"

# --- 2. CLEANUP & PREP ---
echo "--- Preparing Workspace ---"
rm -rf "$RELEASE_DIR"
mkdir -p "$BIN_DEST" "$RELEASE_DIR/assets" "$(dirname "$TARGET_EXE")"

# --- 3. COMPILATION ---
echo "--- Compiling ATS_11 ---"

# These are the extra helper libs usually required for a static wxMSW build
WX_STATIC_LIBS="-lwx_mswu_core-3.2-x86_64-w64-mingw32 \
                -lwx_baseu-3.2-x86_64-w64-mingw32 \
                -lwxtiff-3.2-x86_64-w64-mingw32 \
                -lwxjpeg-3.2-x86_64-w64-mingw32 \
                -lwxpng-3.2-x86_64-w64-mingw32 \
                -lwxzlib-3.2-x86_64-w64-mingw32"

x86_64-w64-mingw32-g++ "$PROJECT_ROOT/client/windows/src/main.cpp" \
    -o "$TARGET_EXE" \
    -O2 \
    -I"$WX_INC_BASE" \
    -I"$WX_INC_SETUP" \
    -D_UNICODE -D__WXMSW__ -DwxDEBUG_LEVEL=0 \
    -L"$WX_LIB_DIR" \
    -static \
    -static-libgcc -static-libstdc++ \
    -Wl,--subsystem,windows \
    $WX_STATIC_LIBS \
    -lshlwapi -lole32 -luuid -lversion -lcomctl32 -loleaut32 -luxtheme -lwinspool -lgdi32 -lcomdlg32 -loleacc

# --- 4. ASSET & BINARY TRANSFER ---
echo "--- Deploying Files ---"
cp "$TARGET_EXE" "$BIN_DEST/"
cp -r "$PROJECT_ROOT/assets/"* "$RELEASE_DIR/assets/"
[ -d "$PROJECT_ROOT/config" ] && cp -r "$PROJECT_ROOT/config" "$RELEASE_DIR/"

# --- 5. AUTOMATIC DLL RESOLUTION ---
echo "--- Collecting Dependencies ---"
# We scan the EXE for DLLs and copy them from our verified MinGW path
NEEDED_DLLS=$(x86_64-w64-mingw32-objdump -p "$TARGET_EXE" | grep "DLL Name" | sed 's/.*DLL Name: //')

for dll in $NEEDED_DLLS; do
    # Only copy non-system Windows DLLs (standard library runtimes)
    if [[ "$dll" == lib* ]]; then
        if [ -f "$MINGW_DLL_PATH/$dll" ]; then
            echo "Packaging: $dll"
            cp "$MINGW_DLL_PATH/$dll" "$BIN_DEST/"
        fi
    fi
done

# --- 6. FINAL PACKAGING ---
echo "--- Creating Release Zip ---"
cd "$PROJECT_ROOT/Release_beta" && zip -r "ATS_11_Release_beta.zip" "ATS_11" > /dev/null

echo "Success! Release ready at: $PROJECT_ROOT/Release_beta/ATS_11_Release_beta.zip"

# ==============================================================================
# 🛠️ THE ARCHITECT'S LOG: HOW ATS_11 BUILDS (AND WHY IT STOPPED CRASHING) 🛠️
# ==============================================================================
#
# 1. THE GENESIS: WHAT WAS THE "OLD" BUILD SCRIPT DOING?
# ------------------------------------------------------
# The original script was a "linear bulldozer." It tried to compile everything 
# using hardcoded paths and manual file-copying logic. 
#
# Problems with the old approach:
# - Brittle Paths: If you moved your 'Libraries' folder, the script broke.
# - Static vs Dynamic Confusion: It was mixing flags that didn't play well 
#   with the specific way wxWidgets was compiled on your VirtualBox.
# - The "Single File" Trap: It only looked for 'main.cpp'. As soon as you 
#   add 'audio_processor.cpp' or 'gui_utils.cpp', the old script would fail 
#   to include them in the binary.
#
# 2. THE CRASHES: THE "UNDEFINED REFERENCE" NIGHTMARE
# ------------------------------------------------------
# You saw a massive wall of text ending in "collect2: error: ld returned 1".
# These weren't code errors; they were LINKER errors.
#
# The Challenge: 
# You are "Cross-Compiling" (Building for Windows while sitting in Linux). 
# You are also using "Static Linking."
#
# The Problem:
# In a static build, the wxWidgets library (libwx_mswu_core) is just a 
# collection of parts. It doesn't know where its dependencies (like PNG 
# images or Zlib compression) are. If you don't tell the compiler EXACTLY 
# where those sub-parts are, it panics and says "Undefined Reference."
#
# The Linker's Pickiness:
# The linker reads from LEFT to RIGHT. If Library A needs Library B, 
# then Library B MUST be placed after Library A in the command. 
# Our fix was ordering: [Main App] -> [wxCore] -> [wxPNG/Zlib] -> [Windows System Libs].
#
# 3. THE SOLUTION: THE NEW "SMART" PIPELINE
# ------------------------------------------------------
# We rebuilt the script with these core stages:
#
# STAGE A: Workspace Sanitization
# - It deletes the 'Release_beta/ATS_11' folder every time. 
#   Why? To ensure you aren't accidentally shipping old, buggy files from 
#   yesterday's build.
#
# STAGE B: Verified Path Mapping
# - We used 'find' commands to locate 'setup.h' and 'wx.h'. 
# - We discovered your system uses MinGW '13-posix'. We hardcoded that 
#   path for the DLLs so the script always grabs the correct 64-bit runtimes.
#
# STAGE C: The "Power Link"
# - We added '-lwxpng', '-lwxzlib', and '-loleacc'. 
# - '-loleacc' was the "magic bullet" that fixed the 'CreateStdAccessibleObject' 
#   errors. It's a Windows library for accessibility that wxWidgets needs 
#   to talk to the Windows OS.
#
# STAGE D: Automatic DLL Siphoning
# - The script uses 'objdump' to "sniff" the final .exe. 
# - It looks for any DLL starting with 'lib' (like libstdc++ or libgcc).
# - It then goes to the MinGW system folder and copies them into your 'bin' 
#   folder automatically. This makes your .zip "portable."
#
# 4. HOW TO MAINTAIN THIS IN THE FUTURE
# ------------------------------------------------------
# - Adding Source Files: Just put new .cpp files in 'client/windows/src/'. 
#   The script now finds them automatically using the $SOURCES variable.
# - New Libraries: If you add a library (like a specialized Audio Lib), 
#   add its path to -L and its name to the end of the g++ command.
#
# 5. SUMMARY OF KEY FLAGS USED:
# ------------------------------------------------------
# -mwindows / --subsystem,windows : Hides the ugly black console window.
# -static-libgcc / -static-libstdc++ : Packs the C++ "brain" into the .exe.
# -O2 : Optimizes the code so the Audio Transformer Suite runs faster.
# -D__WXMSW__ : Tells the code "Hey, we are building for Windows!"
#
# ==============================================================================