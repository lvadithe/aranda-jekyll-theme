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
  