#!/bin/bash

# Ensure script is being run inside the source directory
if [ ! -d ".git" ]; then
  echo "Error: Please run this script inside the pfSense source directory."
  exit 1
fi

# Get the script name to exclude it from renaming
SCRIPT_NAME=$(basename "$0")

# Define old and new branding for pfSense
OLD_LOWER="pfsense"
NEW_LOWER="libresense"

OLD_CAPS="PFSENSE"
NEW_CAPS="LIBRESENSE"

OLD_MIXED="pfSense"
NEW_MIXED="libresense"

# Define old and new company names (case-insensitive replacement for Netgate)
OLD_COMPANY="Netgate"
NEW_COMPANY="OpenSourceCompany"

# Function to safely move files/directories only if the names are different
safe_mv() {
  if [ "$1" != "$2" ]; then
    mv "$1" "$2"
  fi
}

# Capture permissions for files and directories
capture_permissions() {
  find . -type f -exec stat --format="%a %n" {} \; > file_permissions.txt
  find . -type d -exec stat --format="%a %n" {} \; > dir_permissions.txt
}

# Restore permissions for files and directories
restore_permissions() {
  while IFS= read -r line; do
    perms=$(echo "$line" | cut -d ' ' -f 1)
    file=$(echo "$line" | cut -d ' ' -f 2-)
    chmod "$perms" "$file"
  done < file_permissions.txt

  while IFS= read -r line; do
    perms=$(echo "$line" | cut -d ' ' -f 1)
    dir=$(echo "$line" | cut -d ' ' -f 2-)
    chmod "$perms" "$dir"
  done < dir_permissions.txt
}

# Capture the permissions before making changes
echo "Capturing current file and directory permissions..."
capture_permissions

# Replace case-sensitive pfSense -> libresense in files, excluding Git files and the script itself
echo "Replacing pfSense branding with libresense in files..."
find . -depth ! -path "./.git*" ! -name "$SCRIPT_NAME" -type f -exec sed -i -e "s/${OLD_LOWER}/${NEW_LOWER}/g" -e "s/${OLD_CAPS}/${NEW_CAPS}/g" -e "s/${OLD_MIXED}/${NEW_MIXED}/g" {} \;

# Case-insensitive replacement of Netgate -> MyCompany in files, excluding Git files and the script itself
echo "Replacing Netgate with MyCompany (case-insensitive)..."
find . -depth ! -path "./.git*" ! -name "$SCRIPT_NAME" -type f -exec sed -i "s/${OLD_COMPANY}/${NEW_COMPANY}/gI" {} \;

# Rename files and directories containing "pfsense", "PFSENSE", "pfSense", excluding Git files and the script itself
echo "Renaming files and directories containing pfSense..."
find . -depth ! -path "./.git*" ! -name "$SCRIPT_NAME" -type f -name "*${OLD_LOWER}*" | while read file; do
  newfile=$(echo "$file" | sed "s/${OLD_LOWER}/${NEW_LOWER}/g")
  safe_mv "$file" "$newfile"
done

find . -depth ! -path "./.git*" ! -name "$SCRIPT_NAME" -type f -name "*${OLD_CAPS}*" | while read file; do
  newfile=$(echo "$file" | sed "s/${OLD_CAPS}/${NEW_CAPS}/g")
  safe_mv "$file" "$newfile"
done

find . -depth ! -path "./.git*" ! -name "$SCRIPT_NAME" -type f -name "*${OLD_MIXED}*" | while read file; do
  newfile=$(echo "$file" | sed "s/${OLD_MIXED}/${NEW_MIXED}/g")
  safe_mv "$file" "$newfile"
done

# Rename directories
find . -depth ! -path "./.git*" -type d -name "*${OLD_LOWER}*" | while read dir; do
  newdir=$(echo "$dir" | sed "s/${OLD_LOWER}/${NEW_LOWER}/g")
  safe_mv "$dir" "$newdir"
done

find . -depth ! -path "./.git*" -type d -name "*${OLD_CAPS}*" | while read dir; do
  newdir=$(echo "$dir" | sed "s/${OLD_CAPS}/${NEW_CAPS}/g")
  safe_mv "$dir" "$newdir"
done

find . -depth ! -path "./.git*" -type d -name "*${OLD_MIXED}*" | while read dir; do
  newdir=$(echo "$dir" | sed "s/${OLD_MIXED}/${NEW_MIXED}/g")
  safe_mv "$dir" "$newdir"
done

# Rename files and directories containing "Netgate" (case-insensitive), excluding Git files and the script itself
echo "Renaming files and directories containing Netgate (case-insensitive)..."
find . -depth ! -path "./.git*" ! -name "$SCRIPT_NAME" -type f -iname "*${OLD_COMPANY}*" | while read file; do
  newfile=$(echo "$file" | sed "s/${OLD_COMPANY}/${NEW_COMPANY}/gI")
  safe_mv "$file" "$newfile"
done

# Rename directories
find . -depth ! -path "./.git*" -type d -iname "*${OLD_COMPANY}*" | while read dir; do
  newdir=$(echo "$dir" | sed "s/${OLD_COMPANY}/${NEW_COMPANY}/gI")
  safe_mv "$dir" "$newdir"
done

# Restore the permissions after the rebranding
echo "Restoring original file and directory permissions..."
restore_permissions

# Optional: Replace branding in web UI files, excluding Git files and the script itself
WEB_UI_DIR="./usr/local/www/"
if [ -d "$WEB_UI_DIR" ]; then
  echo "Rebranding in web UI files..."
  find "$WEB_UI_DIR" -depth ! -path "./.git*" ! -name "$SCRIPT_NAME" -type f -exec sed -i -e "s/${OLD_LOWER}/${NEW_LOWER}/g" -e "s/${OLD_CAPS}/${NEW_CAPS}/g" -e "s/${OLD_MIXED}/${NEW_MIXED}/g" -e "s/${OLD_COMPANY}/${NEW_COMPANY}/gI" {} \;
else
  echo "Web UI directory ($WEB_UI_DIR) not found. Skipping..."
fi

# Optional: Replace branding in compiled binary files (risky), excluding Git files and the script itself
echo "Replacing branding in compiled binary files (optional and risky)..."
find . -depth ! -path "./.git*" ! -name "$SCRIPT_NAME" -type f -exec sed -i -e "s/${OLD_LOWER}/${NEW_LOWER}/g" -e "s/${OLD_CAPS}/${NEW_CAPS}/g" -e "s/${OLD_MIXED}/${NEW_MIXED}/g" -e "s/${OLD_COMPANY}/${NEW_COMPANY}/gI" {} \;

echo "Combined case-sensitive and case-insensitive rebranding completed!"
