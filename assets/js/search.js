document.addEventListener('DOMContentLoaded', function() {
    // Obtener los datos del JSON inyectado en el HTML
    const sidebarDataElement = document.getElementById('sidebar-data');
    
    if (sidebarDataElement) {
        // Obtener el contenido JSON del script
        const data = JSON.parse(sidebarDataElement.textContent || sidebarDataElement.innerText);
        console.log("data", data);
  
        const resultsContainer = document.getElementById('search-results');
        const searchInput = document.getElementById('search-input');
  
        // Función para filtrar y mostrar los resultados
        function search() {
            const query = searchInput.value.toLowerCase();
            resultsContainer.innerHTML = '';  // Limpiar los resultados previos
  
            // Iterar sobre los capítulos en data.docs
            data.docs.forEach(chapter => {
                const chapterTitle = chapter.title.toLowerCase();
                
                // Verificar si el capítulo coincide con la búsqueda
                if (chapterTitle.includes(query)) {
                    // Crear un ítem para el capítulo
                    const chapterItem = document.createElement('li');
                    chapterItem.textContent = chapter.title;
                    resultsContainer.appendChild(chapterItem);
                }
  
                // Verificar las páginas dentro del capítulo
                if (chapter.pages) {
                    chapter.pages.forEach(page => {
                        // Si la página es un objeto con un título
                        if (typeof page === 'object' && page.title) {
                            const pageTitle = page.title.toLowerCase();
                            if (pageTitle.includes(query)) {
                                // Crear un ítem para la página
                                const pageItem = document.createElement('li');
                                pageItem.textContent = page.title;
                                resultsContainer.appendChild(pageItem);
                            }
                        } 
                        // Si la página es una cadena de texto (solo la URL o el archivo de página)
                        else if (typeof page === 'string') {
                            const pageName = page.toLowerCase();
                            if (pageName.includes(query)) {
                                // Crear un ítem para la página
                                const pageItem = document.createElement('li');
                                pageItem.textContent = page;  // Muestra la URL o archivo
                                resultsContainer.appendChild(pageItem);

                                // Aquí es donde añadimos la lógica para obtener el título de la página .md generada en HTML
                                const pageUrl = page.replace('_pages', '').replace('.md', '.html');  // Convertir _pages/.../.md a la ruta .html correspondiente
                                console.log("p", pageUrl);
                                // Asegurarse de que la URL esté en la forma correcta para ser accedida
                                const fullPageUrl = `${window.location.origin}${pageUrl}`; // Usamos window.location.origin para obtener la URL completa
                                console.log("f", ageUrl);
                                fetch(fullPageUrl)  // Usamos la URL generada, como /configura_inicio/configuracion_preliminar.html
                                    .then(response => {
                                        if (response.ok) {
                                            return response.text();  // Obtener el contenido HTML
                                        }
                                        throw new Error('Error al cargar la página');
                                    })
                                    .then(html => {
                                        // Crear un DOM temporal para extraer el título de la página HTML
                                        const tempDiv = document.createElement('div');
                                        tempDiv.innerHTML = html;
                                        const pageTitleElement = tempDiv.querySelector('h1, title');  // Buscar el título de la página (en <h1> o <title>)

                                        if (pageTitleElement) {
                                            const pageTitleText = pageTitleElement.textContent || pageTitleElement.innerText;
                                            const pageLink = document.createElement('a');
                                            pageLink.href = fullPageUrl;  // Usar la URL procesada por Jekyll
                                            pageLink.textContent = `Ver: ${pageTitleText}`;  // Añadir el título de la página como un enlace
                                            resultsContainer.appendChild(pageLink);
                                        }
                                    })
                                    .catch(error => {
                                        console.error('Error cargando la página:', error);
                                    });
                            }
                        }
                    });
                }
            });
        }
  
        // Llamar a la función de búsqueda cuando el input cambia
        searchInput.addEventListener('input', search);
    } else {
        console.error('No se pudo encontrar el elemento con los datos del sidebar.');
    }
});
