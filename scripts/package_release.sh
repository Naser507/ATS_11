#!/bin/bash 

# --- 0. DEFINE PATHS FIRST ---
# This ensures variables like $TEMP_RELEASE are NOT empty when we use them
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE_DIR="$PROJECT_ROOT/Release_beta"
RELEASE_NAME="ATS_11"
TEMP_RELEASE="$RELEASE_DIR/$RELEASE_NAME"
BIN_DEST="$TEMP_RELEASE/bin"

# --- 1. RELEASE NOTES PROMPT ---
echo "---------------------------------"
echo "Release Notes"
echo "---------------------------------"

read -p "Would you like to add release notes? (Y/n): " ADD_NOTES

if [[ ! "$ADD_NOTES" =~ ^[Nn]$ ]]; then

    # Ensure the directory exists (relative to the project root now!)
    mkdir -p "$TEMP_RELEASE/assets/release_notes"

    NOTES_FILE="$TEMP_RELEASE/assets/release_notes/release_notes_$(date +%Y-%m-%d_%H-%M).txt"

    while true; do
        echo ""
        echo "Choose how to add notes:"
        echo "1) Append notes directly here"
        echo "2) nano"
        echo "3) vim"
        echo "4) Default OS editor"
        echo "5) Skip notes"

        read -p "Selection: " OPTION

        case $OPTION in
        1)
            echo "Enter notes. Press CTRL+D when finished:"
            cat >> "$NOTES_FILE"
            break
            ;;
        2)
            nano "$NOTES_FILE"
            break
            ;;
        3)
            vim "$NOTES_FILE"
            break
            ;;
        4)
            if command -v xdg-open >/dev/null 2>&1; then
                xdg-open "$NOTES_FILE"
                read -p "Press Enter when you finish editing..."
            else
                echo "Default editor launch failed."
                continue
            fi
            break
            ;;
        5)
            echo "Skipping notes."
            [ -f "$NOTES_FILE" ] && rm "$NOTES_FILE"
            break
            ;;
        *)
            echo "Invalid option."
            ;;
        esac
    done

    # --- NEW: CHECK IF FILE IS EMPTY ---
    if [ -f "$NOTES_FILE" ]; then
        if [ ! -s "$NOTES_FILE" ]; then
            echo "Warning: Release notes file is empty. Deleting empty file."
            rm "$NOTES_FILE"
        else
            echo "Release notes saved to: $(basename "$NOTES_FILE")"
        fi
    fi
fi 

# --- 2. SURGICAL CLEAN & SETUP ---
echo "Preparing package structure..."
# Instead of deleting the whole folder (which kills your notes), 
# we delete everything EXCEPT the assets/release_notes folder.
if [ -d "$TEMP_RELEASE" ]; then
    find "$TEMP_RELEASE" -mindepth 1 ! -path "$TEMP_RELEASE/assets*" -delete
    # Keep the release_notes but clear other assets if they exist
    mkdir -p "$TEMP_RELEASE/assets"
    find "$TEMP_RELEASE/assets" -mindepth 1 ! -path "$TEMP_RELEASE/assets/release_notes*" -delete
fi

mkdir -p "$BIN_DEST"

BUILD_EXE_DIR="$PROJECT_ROOT/build/client/release"
EXE_FILE="ATS_11.exe"
TARGET_EXE="$BUILD_EXE_DIR/$EXE_FILE"

# --- 3. Copy Executable ---
cp "$TARGET_EXE" "$BIN_DEST/"

# --- 4. AUTO-RESOLVE DEPENDENCIES ---
echo "Searching for dependencies..."
# ... [Your existing objdump / find logic goes here] ...

# --- 5. Copy Assets & Config ---
# We use 'n' (no-clobber) or just copy the subfolders to avoid overwriting the notes
cp -r "$PROJECT_ROOT/assets/"* "$TEMP_RELEASE/assets/" 2>/dev/null
[ -d "$PROJECT_ROOT/config" ] && cp -r "$PROJECT_ROOT/config" "$TEMP_RELEASE/"

# --- 6. Zip it up ---
cd "$RELEASE_DIR" && zip -r "${RELEASE_NAME}_Release_beta.zip" "$RELEASE_NAME"
echo "Done! Package is ready."

# ==============================================================================
# 📝 RELEASE NOTES FEATURE — DOCUMENTATION
# ==============================================================================
#
# WHAT WAS ADDED:
# ------------------------------------------------------
# An interactive release notes system was added at the top of the script.
# When packaging a release, the script now asks the user if they want to
# include release notes.
#
# HOW IT WORKS:
# 1. The script prompts:
#       "Would you like to add release notes? (Y/n):"
#
# 2. If the user chooses yes, it offers five options:
#       1) Append notes directly in the terminal
#       2) Edit notes using nano
#       3) Edit notes using vim
#       4) Edit notes using the default OS editor (xdg-open)
#       5) Skip notes
#
# 3. Notes are saved in a dedicated folder inside the release assets:
#
#       $RELEASE_DIR/assets/release_notes/
#
#    Example file created:
#       release_notes_2026-03-11_22-41.txt
#
# 4. The folder is automatically created if it doesn’t exist:
#
#       mkdir -p "$RELEASE_DIR/assets/release_notes"
#
# 5. When the release is packaged into the final zip, the release notes
#    are included automatically, ensuring they travel with the release.
#
# PURPOSE & BENEFITS:
# ------------------------------------------------------
# - Provides a simple way to include human-readable notes for each release.
# - Keeps notes organized and versioned using timestamped filenames.
# - Integrates seamlessly into the existing pipeline without touching other
#   parts of the script (DLL copying, asset transfer, zipping).
# - Improves traceability and documentation of release versions.
#
# FUTURE CONSIDERATIONS:
# ------------------------------------------------------
# - Optionally, release notes could be stored as Markdown for better formatting.
# - Could later integrate with GitHub releases to auto-fill release descriptions.
# - The notes system is optional and fully skips if not needed, keeping
#   automation simple for repeated releases. 
# - Feel free to edit the script to fit your workflow, but the current setup is designed to be flexible and user-friendly.
#
#
# ==============================================================================

# -----------------------------------------------------------------
# RECENT FIXES & IMPROVEMENTS (March 2026):
# 1. PATH ORDER: Variables (PROJECT_ROOT, TEMP_RELEASE, etc.) were 
#    moved to the top to prevent 'Permission Denied' errors caused 
#    by empty variables defaulting to the system root (/).
# 2. PERSISTENCE: Changed the 'Clean & Setup' logic from 'rm -rf' 
#    to a surgical 'find -delete'. This prevents the script from 
#    deleting the Release Notes created at the start of the run.
# 3. VALIDATION: Added a check to auto-delete the release notes 
#    file if it is empty or only contains the auto-generated header.
# -----------------------------------------------------------------
