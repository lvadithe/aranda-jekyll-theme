#!/bin/bash

# Remove existing pdf.md to create a new file
rm _pages/pdf.md

# List all files ending with .md in the _pages directory sorting by numerical order starting from the second field separated by "/"
FILES=$(find _pages -type f -name "*.md" | sort -t '/' -k 2n)

# Getting manual name from index.md
MANUALNAME=$(grep 'title' _pages/index.md)

# Create and initialize pdf.md to create a page with complete information
echo "---
$MANUALNAME
permalink: /pdf
layout: pdf
---" > _pages/pdf.md

# Running through the list of files $FILES to then open it and concat with pdf.md
for line in $FILES
do
    # Adjust paths and write inside pdf.md from below line number to eof
    sed 's/\/en\///g' "$line" | {
        # Getting chapter name to write as a title inside pdf.md. Search the line that contains "excerpt: " and parse text to get only the name
        CHAPTER=$(grep "excerpt: " | cut -d ":" -f2- | tr -d '"' | cut -d " " -f2-)

        # Check if this chapter exists in pdf.md to avoid repeated names in case the chapter markdown contains this name
        EXISTS_CHAPTER=$(grep "$CHAPTER" _pages/pdf.md | wc -l)

        # Skip the main markdown. The Introduction chapter and Main contain the same prologue.
        if [[ "$CHAPTER" != "Inicio" ]]
        then
            # Write chapter if not exists
            if [ $EXISTS_CHAPTER -eq 0 ]
            then
                echo -e "\n# $CHAPTER" >> _pages/pdf.md
            fi
        fi

        # Getting manual title to write inside pdf.md. Search the line that contains "title: " and parse text to get only the name
        TITLE=$(grep "title: " | cut -d ":" -f2- | tr -d '"' | cut -d " " -f2-)
        # Check if manual title exists
        EXISTS_TITLE=$(grep "$TITLE" _pages/pdf.md | wc -l)

        if [ $EXISTS_TITLE -eq 0 ]
        then
            echo -e "\n## $TITLE" >> _pages/pdf.md
        fi

        # Find the line where the comments end
        FROM=$(grep -n "\b---\b" "$line" | tail -1 | cut -d ":" -f1)
        FROM=$(($FROM + 1))

        # Write inside pdf.md from below line number to eof
        tail -n +$FROM "$line" >> _pages/pdf.md
    }
done