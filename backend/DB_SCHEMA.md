# Article Schema

## Colecciones

- **articles** → Artículos creados por el usuario dentro de la app.  
  - En esta colección, el campo `url` será siempre `null` ya que el artículo no proviene de una fuente externa.
- **bookmarks** → Artículos obtenidos desde la API y guardados por el usuario.  
  - En esta colección, el campo `url` contendrá la dirección web original del artículo.

## Estructura de documento `Article`

| Campo          | Tipo     | Descripción |
| -------------- | -------- | ----------- |
| **id**         | `int`    | Identificador único del artículo. |
| **author**     | `string` | Nombre del autor del artículo. |
| **source**     | `string` | Fuente del artículo (nombre del medio o autor). |
| **category**   | `string` | Categoría a la que pertenece el artículo. |
| **title**      | `string` | Título del artículo. |
| **description**| `string` | Breve descripción o resumen del artículo. |
| **content**    | `string` | Contenido completo del artículo. |
| **url**        | `string \| null` | URL original del artículo. En `articles` será siempre `null`, en `bookmarks` será una cadena con la URL de origen. |
| **urlToImage** | `string` | URL de la imagen principal del artículo. **En el caso de imágenes propias, será una referencia a Firebase Cloud Storage en la carpeta `media/articles`.** |
| **lectureTime**| `int`    | Tiempo estimado de lectura en minutos. |
| **publishedAt**| `string` | Fecha y hora de publicación en formato ISO 8601. |
| **saved**      | `bool`   | Indica si el artículo está guardado por el usuario (true/false). |

## Notas
- Las imágenes propias deben almacenarse en **Firebase Cloud Storage** bajo la carpeta `/articles/`.
- En Firestore, los documentos de ambas colecciones (`articles` y `bookmarks`) siguen la misma estructura.
- La clave `urlToImage` debe ser siempre una cadena válida que apunte a una imagen accesible.
