# Applicant Showcase para Symmetry - Final Report

## 1. Introducción

Para empezar, me gustaría aclarar que la aplicación se llama DNews en un intento de un triple juego de palabras: Daily News, The News, y también David News. La D intenta agrupar esos tres términos. Además, he generado un logo utilizando inteligencia artificial. Una versión reducidad para el icono de la app, y otra más extendida para cuando estás dentro de la misma.

Mi punto de partida es el siguiente: anteriormente he creado varias aplicaciones en React Native, así que no tenía mucha base de Flutter, pero cuando empecé en esto del desarrollo móvil comencé en Flutter cuando aún no se había viralizado el uso de la inteligencia artificial, por lo que estuve varios meses (unos 3 meses, compenetrados con el primer año de carrera de la universidad) creando una aplicación móvil a mano hecha en Flutter, centrándome completamente en la estética, pues en ese entonces ni siquiera empecé planteando un backend, simplemente quería tener una aplicación creada por mí.

No obstante, dicha aplicación fue creada sin seguir ninguno de los principios requeridos en el proyecto sobre arquitectura limpia, uso de BLOC, etc, así que el primer día en cuanto recibí el correo electrónico de Mauro explicándome que tendría que realizar una prueba técnica (lunes a las 16:30 de la tarde) decidí dedicar el día completo a entender todos estos conceptos que han sido nuevos para mí y que me han llegado a abrumar un poco, pues quería demostrar más bien habilidades en la parte de diseño, funcionalidades, originalidad y uso de la aplicación, aunque comprendo que es vital entender los principios de la limpieza del código antes de pasar a la implementación de las funcionalidades.

Hace apenas unos meses también hice una aplicación en Flutter para llevar a cabo mi gestión económica, una app muy simple y minimalista, sin abrumar al usuario (es decir, a mí, el único usuario) con funcionalidades muy complejas que no necesito para saber cuánto dinero recibo y cuánto gasto. Esta aplicación sí que la llegué a terminar, usando firebase para guardar todas mis transacciones.

Es por esto que la parte del backend no me ha resultado compleja, pues tenía una base que me ha sido suficiente para implementar este sencillo proyecto.

No tengo más punto de partida que este, a parte de conocimientos básicos, evidentemente, sobre tecnologías usadas hoy en día en el mundo del desarrollo, como pueden ser Github para subir distintas versiones, Trello para organizar las diferentes tareas, Figma para diseñar la aplicación antes de ponerme a programar y Cursor para boostear mi velocidad usando la Inteligencia Artificial.

---

## 2. Proceso de aprendizaje

Como bien he comentado en la introducción, conocía todas las tecnologías usadas, pero no en profundidad, ni era consciente del enorme campo que supone la limpieza y estructuración del código, más aún desarrollado en Flutter, donde puedes perderte fácilmente cuando el proyecto se va haciendo grande.

Como esto era de lo más básico, tuve que estar más tiempo del que me hubiese gustado aprendiendo sobre limpieza del código, uso de BLOC, Cubits, las distintas capas de la aplicación, conexión entre ellas, etc. Para aprenderlo usé la mayoría de vídeos proporcionados por Diego en el respositorio de Github.

En cuanto al diseño de la aplicación, tenía unos esquemas mentales, y cogí inspiración de páginas web como **Mobbin** o **Dribbble**. Plasmé estos esquemas en un proyecto de Figma, y fui actualizándolos poco a poco con nuevas ideas que se me iban ocurriendo sobre la marcha, y probando cómo quedarían los distintos diseños en Figma antes de perder tiempo implementándolos en el código.

Opté por un diseño sencillo y minimalista pero a la vez muy estético y que aporta la información necesaria para darle la máxima funcionalidad a la aplicación, sin abrumar al usuario, de tal forma que una persona mayor podría usarla con mucha facilidad, mientras que una persona joven encontraría similitud con diseños como el de Apple o algunas redes sociales como Instagram (por ejemplo, a la hora de subir los artículos), lo que facilita el uso para todos los públicos, fomentando por encima de todo la experiencia del usuario.

El diseño se puede resumir en la siguiente frase: Una estética seria y tradicional adaptada a las nuevas generaciones (incentivando que los más jóvenes accedan a una aplicación parecida a un periódico tradicional). Además, quise que siendo orientada a un periodista, la experiencia del mismo fuese agradable y sobre todo sencilla, por lo que tiene un botón específico para subir los posts en la parte de abajo, alcanzable por el pulgar sin tener que estirar la mano, y llevando directamente a la pantalla de creación del artículo, sin tonterías de por medio.

---

## 3. Desafíos encontrados

El principal desafío como vengo reiterando ha sido mantener un código limpio sin violar ninguna restricción y tratando de entender lo que estoy haciendo. Me ha costado un poco saber cuándo usar los BLOCS, y entender para qué servían las entities, repositories, etc. Lo más difícil ha sido la business layer.

No obstante, también he tenido otros desafíos, como la escritura y borrado de artículos en firebase, pues he separado la lógica de los artículos en dos colecciones: una para los artículos escritos por el usuario, y otra para los artículos de la API que son guardados por el usuario. Es por esto que en los escritos por el usuario he añadido una propiedad “saved” (para no repetir el almacenamiento del artículo dos veces si un artículo está guardado), y los archivos de la API que por defecto no están almacenados en mi firebase, cuando son guardados se almacenan en la colección “bookmarks”.  Esto me ha dado muchos dolores de cabeza, al hacerme pensar si lo mejor es almacenar todos los artículos de la API, cómo tratar colecciones separadas, etc.

Al final opté por tener estas dos colecciones, y no almacenar todos los artículos de la API, por lo que para reutilizar el mismo esquema para los dos tipos de artículos, he tenido que dejar algunos campos de los artículos creados por el periodista siempre a null, como la URL que debería llevar a la noticia real.

No he tenido ningún desafío mayor a parte de estos, el resto simplemente han sido diferentes ideas de diseño y experiencia del usuario, y decantarme por algunas. He puesto todas las diferentes versiones en Figma. 

---

## 4. Reflexión sobre el proyecto y dirección del mismo

Aprendizaje a nivel técnico y profesional:

Este mini proyecto me ha servido para comprender mejor el funcionamiento de Flutter por dentro, pues siempre lo había visto como un framework un tanto complejo de escalar debido al lenguaje dart, pero gracias a los principios aplicados y una vez comprendidos, me ha sido sencillo escalar el proyecto y creo que podría seguir haciéndolo más grande sin los problemas que he tenido anteriormente con Flutter.

Gracias a las restricciones de limpieza y en especial la de tiempo este proyecto me ha hecho entender lo importante que es una buena organización, limpieza del código y siempre intentar hacer las cosas bien a pesar de no tener mucho tiempo para ello.

En cuanto a la dirección del proyecto, la verdad es que he tenido una idea que creo que le podría venir muy bien al producto, e incluso podría llegar a lanzarse al mercado con varias modificaciones. He pensado que sería una buena idea llevar el proyecto en otra dirección, quitando la sección de publicar tus propios artículos, y aprovechar la estructura para convertirlo en una aplicación que haga lo siguiente:

- Mostrar a los usuarios las noticias del día, de varios periódicos.
- Al entrar a leer una noticia, el usuario podría combinar esta misma noticia pero publicada por los diferentes periódicos, y usando Inteligencia Artificial generar una noticia a partir de todas las demás pero sin ningún tipo de sesgo político ni ideológico.

Esto permitiría a la gente tener una plataforma no subvencionada donde informarse de la actualidad, desde la más absoluta neutralidad. Se me ocurrió debido a que evidentemente los medios tradicionales están subvencionados y siempre tienen un sesgo, no contando las noticias como son realmente, y otras plataformas como Twitter/X dan demasiada voz a que la gente opine sobre la actualidad, lo que no te permite informarte de forma neutral para obtener tu propia opinión.

---

## 5. Proof of the Project

[Incluye aquí capturas de pantalla y enlaces a videos que muestren la versión final de tu proyecto.]

---

## 6. Overdelivery

### New Features Implemented

Las nuevas funcionalidades implementadas son:

- [Poder acceder al contenido de una noticia](videos/article_view_showcase.mp4): al hacer click en una noticia, el usuario puede leer su contenido, no solo ver el titular y la descripción desde fuera como en el diseño inicial.
- Posibilidad de [escribir texto en formato Markdown](videos/markdown_showcase.mp4) al escribir un artículo.
- [Artículos guardados](videos/bookmarks_showcase.mp4): el usuario puede guardar los artículos que quiera y luego acceder a ellos desde la Home Page en el icono del marcador.
- [Cambiar las distintas categorías de noticias](videos/categories_showcase.mp4): he implementado un ScrollView horizontal que se queda pegado arriba de la pantalla cuando estás viendo noticias, para así cambiar fácilmente de categoría incluso si estoy al final de una categoría, sin tener que scrollear hasta arriba del todo para cambiar la sección. Las categorías son: General, Business, Health, Science, Technology, DNews. La categoría DNews contiene únicamente los artículos creados por el usuario.
- Cálculo de tiempo de lectura de los artículos: para mostrar el tiempo de lectura real de los artículos, básicamente cojo el length del contenido al extraer los datos de la api (en la implementación del repositorio). Como los artículos de la API tienen el contenido cortado pero muestran, por ejemplo [+3942 chars], he utilizado expresiones regulares para extraer ese extra de caracteres y ponerles un tiempo de lectura accurate, considerando que el humano promedio lee unas 200 palabras por minuto. Cuanto más escribas en una noticia, más tiempo de lectura tendrá, así el usuario está bien informado antes de leerla.

Otras funcionalidades secundarias:

- Efecto de skeleton cuando los datos están cargando de la API y Firestore para mejorar la apariencia, en vez de usar un CircularProgressIndicator
- Almacenamiento en caché del estado de Saved de los artículos para no tener que llamar constantemente a Firestore para comprobar el estado de Saved de un artículo.

### How Can You Improve This

Creo que con más tiempo podría haber mejorado algunas secciones en cuanto a diseño, como la parte de escribir tu propio post, y también mejorar muchas microinteracciones, en especial al pulsar los botones, cambiar de categoría, etc.

También podría haber añadido otras funcionalidades, como un formato TikTok para ver las noticias scrolleando (esta era muy buena idea pero no me dio tiempo a implementarla) combinado con un narrador opcional que te podría leer las noticias por ti.

---

Tiempo dedicado al proyecto:

- Comencé a trabajar en él el lunes a las 17 de la tarde (aunque estuve todo el día etendiendo los principios de limpieza del código)
- El martes comencé la app. El miércoles por la noche la acabé. En estos dos días le habré dedicado unas 16 horas al proyecto y otras 2 horas el jueves para elaborar el reporte y grabar los vídeos.


Enlaces:
- [Repositorio en GitHub](https://github.com/daviidltp/dnews)
- [Proyecto completo en Figma](https://www.figma.com/design/UrHlnVc3AjC9ekC7OgyzGq/Untitled?node-id=0-1&t=gSL19F1YxGHJzXF7-1)
