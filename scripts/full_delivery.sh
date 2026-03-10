#!/bin/bash
# =====================================================
# FULL DELIVERY PIPELINE (Simplified)
# Runs build, package, and upload scripts in sequence
# =====================================================

PROJECT_ROOT="$HOME/projects_series/ATS_11"

echo "---------------------------------"
echo "STEP 1: BUILD"
echo "---------------------------------"
bash "$PROJECT_ROOT/scripts/build.sh"

echo "---------------------------------"
echo "STEP 2: PACKAGE RELEASE"
echo "---------------------------------"
bash "$PROJECT_ROOT/scripts/package_release.sh"

echo "---------------------------------"
echo "STEP 3: UPLOAD RELEASE"
echo "---------------------------------"
bash "$PROJECT_ROOT/scripts/upload_release_assets.sh"

echo "---------------------------------"
echo "FULL DELIVERY COMPLETE"
echo "---------------------------------"