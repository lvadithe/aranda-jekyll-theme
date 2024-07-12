#!/bin/bash

function generatePDF() {
    language="$1"
    directory="_pages/${language}"

    # Remove existing pdf.md to create new file
    rm "${directory}/pdf.md"

    # List all files ending with .md in the _pages/{language} directory sorting by numerical order starting from second field separated by "/"
    FILES=$(find "${directory}" -type f -name "*.md" | sort -t '/' -k 2n)

    # Getting manual name from index.md
    MANUALNAME=$(grep 'title' "${directory}/index.md")

    # Create and initialize pdf.md to create page with complete information
    echo "---
${MANUALNAME}
permalink: /pdf
layout: pdf
---" > "${directory}/pdf.md"

    # Running through list of files $FILES to then open it and concat with pdf.md
    for line in $FILES
    do
        # Getting chapter name to write as a title inside pdf.md. Search the line that contains "excerpt: " and parse text to get only name
        CHAPTER=$(grep "excerpt: " "$line" | cut -d ":" -f2 | tr -d '"' | cut -d " " -f2-)

        # Check if this chapter exists in pdf.md to avoid repeated names in case the chapter markdown contains this name
        EXISTS_CHAPTER=$(grep "$CHAPTER" "${directory}/pdf.md" | wc -w)

        # Skip the main markdown. The Introduction chapter and Main contain the same prologue.
        if [[ $CHAPTER != "Inicio" ]]
        then
            # Write chapter if not exists
            if [ $EXISTS_CHAPTER -eq 0 ]
            then
                echo $CHAPTER
                echo "\n# $CHAPTER" >> "${directory}/pdf.md"
            fi
        fi

        # Getting manual title to write inside pdf.md. Search the line that contains "title: " and parse text to get only name
        TITLE=$(grep "title: " "$line" | cut -d ":" -f2 | tr -d '"' | cut -d " " -f2-)
        # Check if manual title exists
        EXISTS_TITLE=$(grep "$TITLE" "${directory}/pdf.md" | wc -w)

        if [ $EXISTS_TITLE -eq 0 ]
        then
            echo "\n## $TITLE" >> "${directory}/pdf.md"
        fi

        # Find the line where the comments end
        FROM=$(grep -n "\b---\b" "$line" | tail -1 | cut -d ":" -f1)
        FROM=$(($FROM + 1))

        # Write inside pdf.md from below line number to end of file
        tail -n +$FROM "$line" >> "${directory}/pdf.md"
    done
}

# Llamar a la función generatePDF para los idiomas es, en y pt
generatePDF "es"
generatePDF "en"
generatePDF "pt"
