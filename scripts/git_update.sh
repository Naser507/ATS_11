#!/bin/bash
# Simple git update script for ATS_11

echo "Adding all changes..."
git add .

echo "Committing..."
read -p "Enter commit message: " msg
git commit -m "$msg"

echo "Pushing to origin..."
git push origin main  # or 'master' if your default branch is master

echo "Update complete!"
