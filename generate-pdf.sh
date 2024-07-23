#!/bin/bash

# Remove existing pdf.md to create a new file
rm _pages/pdf.md

# List all files in the _pages directory, sorting by numerical order starting from the second field separated by "/"
FILES=$(find _pages -type f | sort -t '/' -k 2n)

# Getting manual name from index.md
MANUALNAME=$(grep 'title' _pages/index.md)

# Create and initialize pdf.md to create a page with complete information
echo "---
$MANUALNAME
permalink: /pdf
layout: pdf
---" > _pages/pdf.md

# Running through the list of files $FILES to process each one
for line in $FILES
do
    # Adjust paths and write inside pdf.md from below line number to EOF
    sed -i 's/\/en\/assets\//\/assets\//g; s/\/en\//\//g' "$line"

    # Getting chapter name to write as a title inside pdf.md.
    CHAPTER=$(grep "excerpt: " "$line" | cut -d ":" -f2- | tr -d '"' | cut -d " " -f2-)

    # Check if this chapter exists in pdf.md to avoid repeated names.
    EXISTS_CHAPTER=$(grep "$CHAPTER" _pages/pdf.md | wc -l)

    # Skip the main markdown. The Introduction chapter and Main contain the same prologue.
    if [[ "$CHAPTER" != "Inicio" ]]
    then
        # Write chapter if not exists
        if [ $EXISTS_CHAPTER -eq 0 ]
        then
            echo $CHAPTER
            echo "\n# $CHAPTER" >> _pages/pdf.md
        fi
    fi

    # Getting manual title to write inside pdf.md.
    TITLE=$(grep "title: " "$line" | cut -d ":" -f2- | tr -d '"' | cut -d " " -f2-)
    # Check if manual title exists
    EXISTS_TITLE=$(grep "$TITLE" _pages/pdf.md | wc -l)

    if [ $EXISTS_TITLE -eq 0 ]
    then
        echo "\n## $TITLE" >> _pages/pdf.md
    fi

    # Find the line where the content begins after the YAML front matter
    FROM=$(grep -n "\b---\b" "$line" | tail -1 | cut -d ":" -f1)
    FROM=$(($FROM + 1))

    # Write inside pdf.md from below line number to EOF
    tail -n +$FROM "$line" >> _pages/pdf.md
done
