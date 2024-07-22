# Remove existing pdf.md to create new file
rm _pages/pdf.md

# List all files ending with .md in the _pages directory, sorting by numerical order starting from second field separated by "/"
FILES=$(find _pages -type f -name "*.md" | sort -t '/' -k 2n)

# Getting manual name from index.md
MANUALNAME=$(grep 'title' _pages/index.md)

# Create and initialize pdf.md to create page with complete information
echo "---
$MANUALNAME
permalink: /pdf
layout: pdf
---" > _pages/pdf.md

# Running through list of files $FILES to then open it and concat with pdf.md
for line in $FILES
do
    # Getting chapter name to write as a title inside pdf.md. Search the line that contains "excerpt: " and parse text to get only name
    CHAPTER=$(grep "excerpt: " "$line" | cut -d ":" -f2 | tr -d '"' | cut -d " " -f2-)

    # Check if this chapter exists in pdf.md to avoid repeated names in case the chapter markdown contains this name
    EXISTS_CHAPTER=$(grep "$CHAPTER" _pages/pdf.md | wc -l)

    # Skip the main markdown. The Introduction chapter and Main contain the same prologue.
    if [[ $CHAPTER != "Inicio" ]]
    then
        # Write chapter if not exists
        if [ $EXISTS_CHAPTER -eq 0 ]
        then
            echo -e "\n# $CHAPTER" >> _pages/pdf.md
        fi
    fi

    # Getting manual title to write inside pdf.md. Search the line that contains "title: " and parse text to get only name
    TITLE=$(grep "title: " "$line" | cut -d ":" -f2 | tr -d '"' | cut -d " " -f2-)
    # Check if manual title exists
    EXISTS_TITLE=$(grep "$TITLE" _pages/pdf.md | wc -l)

    if [ $EXISTS_TITLE -eq 0 ]
    then
        echo -e "\n## $TITLE" >> _pages/pdf.md
    fi

    # Extract the PDF file path from the .md file and adjust the name
    PDF_PATH=$(grep "pdf: " "$line" | cut -d ":" -f2 | tr -d '"' | cut -d " " -f2-)
    PDF_NAME=$(basename "$(dirname "$PDF_PATH")").pdf

    # Append the PDF name to pdf.md
    echo -e "\n### $PDF_NAME\n" >> _pages/pdf.md
done
