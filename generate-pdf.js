const fs = require('fs');
const path = require('path');

function generatePDF(language) {
    // Construir la ruta al directorio específico según el idioma
    const markdownDirectory = path.join(__dirname, '_pages', language);

    // Eliminar el archivo pdf.md existente para crear uno nuevo
    const pdfFilePath = path.join(markdownDirectory, 'pdf.md');
    try {
        fs.unlinkSync(pdfFilePath);
    } catch (err) {
        // Manejar error si el archivo no existe
    }

    // Listar todos los archivos que terminan en .md en el directorio de markdown, ordenados numéricamente
    const files = fs.readdirSync(markdownDirectory)
        .filter(file => file.endsWith('.md'))
        .sort((a, b) => {
            const aNum = parseInt(a.split('.')[0]);
            const bNum = parseInt(b.split('.')[0]);
            return aNum - bNum;
        });

    // Obtener el nombre del manual desde index.md
    const indexFilePath = path.join(markdownDirectory, 'index.md');
    const indexContent = fs.readFileSync(indexFilePath, 'utf8');
    const manualNameMatch = indexContent.match(/title:\s*(.*)/);
    const manualName = manualNameMatch ? manualNameMatch[1] : '';

    // Crear e inicializar pdf.md para crear una página con información completa
    fs.writeFileSync(pdfFilePath, `---
${manualName}
permalink: /pdf
layout: pdf
---
`);

    // Iterar sobre la lista de archivos y añadir contenido a pdf.md
    files.forEach(fileName => {
        const filePath = path.join(markdownDirectory, fileName);
        const fileContent = fs.readFileSync(filePath, 'utf8');

        const chapterMatch = fileContent.match(/excerpt:\s*(.*)/);
        const chapter = chapterMatch ? chapterMatch[1] : '';

        const existsChapter = fs.readFileSync(pdfFilePath, 'utf8').includes(chapter);

        // Saltar el markdown principal. Los capítulos de Introducción y Main contienen el mismo prólogo.
        if (chapter !== 'Inicio' && !existsChapter) {
            fs.appendFileSync(pdfFilePath, `\n# ${chapter}\n`);
        }

        const titleMatch = fileContent.match(/title:\s*(.*)/);
        const title = titleMatch ? titleMatch[1] : '';

        const existsTitle = fs.readFileSync(pdfFilePath, 'utf8').includes(title);

        if (!existsTitle) {
            fs.appendFileSync(pdfFilePath, `\n## ${title}\n`);
        }

        const fromMatch = fileContent.match(/\b---\b/);
        const from = fromMatch ? parseInt(fromMatch.index) + 4 : 0; // Suponiendo "---" como delimitador, ajustar según sea necesario

        const contentToAppend = fileContent.substring(from);

        fs.appendFileSync(pdfFilePath, contentToAppend);
    });
}

// Llamar a la función generatePDF para los idiomas es, en y pt
generatePDF('es');
generatePDF('en');
generatePDF('pt');
