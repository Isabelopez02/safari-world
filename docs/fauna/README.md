# Fuentes del catálogo de Huachipa

## Cantidades y fechas

El [ZoObservatorio de OSINFOR](https://zoobservatorio.osinfor.gob.pe/Home/ListFauna) publica para el Parque Zoológico Huachipa una supervisión del **22 de mayo de 2023**, incorporada al portal el 9 de junio de 2023: **133 registros de taxones y 1.047 individuos**. La tabla original se conserva como datos estructurados en `inventario_osinfor_2023.json`.

La [Municipalidad de Lima](https://www.gob.pe/institucion/munilima/noticias/1261823-el-alcalde-de-lima-apertura-un-nuevo-hospital-veterinario-en-huachipa-los-reyes-del-zoologico-tienen-su-clinica-top) reportó **152 especies y casi mil animales el 10 de octubre de 2025**. Son referencias de fechas distintas, no una cifra de población confirmada en tiempo real.

El catálogo incluye los 133 registros de OSINFOR y ocho fichas adicionales: camello, leopardo, ronsoco, llama, alpaca, pavo real, pato mandarín y faisán dorado. La [publicación sobre Makucha y Gertrudis](https://www.gob.pe/institucion/leyendas/noticias/1382534-dia-mundial-de-la-tierra-ven-a-conocer-a-makucha-y-gertrudis-en-el-parque-de-las-leyendas-sede-huachipa), la [nota sobre los ronsocos y la fauna de Huachipa](https://www.gob.pe/institucion/leyendas/noticias/1211036-mas-de-200-mil-personas-ya-han-visitado-a-los-capibaras-bebes-en-el-parque-de-las-leyendas-sede-huachipa) y la [reapertura del Bosque de Aves](https://www.gob.pe/institucion/leyendas/noticias/1117619-gran-reapertura-del-bosque-de-aves-en-la-sede-huachipa-del-parque-de-las-leyendas) respaldan las incorporaciones. La observación de llamas y alpacas también está documentada en el [boletín de una visita escolar de julio de 2025](https://www.recoleta.edu.pe/storage/boletines/July2025/Compartiendo%203017.pdf).

**141 fichas no significa 141 especies confirmadas actualmente en exhibición.** Se conservan los taxones exactamente como aparecen en el inventario, incluyendo una boa híbrida, una subespecie y un registro de `Plecturocebus sp.`. Se eliminaron las filas genéricas que duplicaban grupos ya identificados, como «monos», «serpientes» y «anfibios».

## Información para visitantes

Cada ficha aporta descripción, identificación visual, alimentación natural, distribución, reproducción, papel ecológico, amenazas generales, consejos de observación y créditos. Los resúmenes biológicos en español se consultaron mediante la API pública de iNaturalist, que proporciona introducciones de Wikipedia. Estos textos mantienen su atribución CC BY-SA y los enlaces a la fuente. Los estados de conservación solo se toman de evaluaciones globales de IUCN enlazadas por iNaturalist; no se utilizan categorías regionales como si fueran globales.

Se indica la fecha de la fuente de presencia. Un registro histórico no acredita que el ejemplar continúe en exhibición. Las 41 referencias de zona que ya tenía el prototipo se conservan como aproximadas; las otras 100 fichas no generan coordenadas ni rutas ficticias.

## Fotografías

Las **141 fotografías están incluidas en `assets/images/fauna/`**. La app usa el mismo componente para mostrarlas en el mapa, el carrusel, el catálogo, la selección de destino y las fichas. No depende de URLs externas para cargar las fotos.

El manifiesto `catalogo_huachipa.json` incluye identificación del taxón, autor, licencia, URL de la página original, URL de descarga, dimensiones y fecha de revisión visual. Los créditos también están accesibles en cada ficha y en `CREDITOS_FOTOGRAFIAS.md`.

Las imágenes son referencias de la especie o taxón, no fotografías identificadas de los ejemplares de Huachipa. Las referencias de la boa híbrida, la subespecie de boa y el género sin especie determinada se identifican como tales. La imagen de la culebra de costa (`OS127`) está bajo CC BY-NC para el uso académico no comercial de este proyecto; su licencia y autor se indican junto al resto de atribuciones. La fuente Urbanist se distribuye bajo OFL en `assets/fonts/OFL.txt`.

La revisión visual sustituyó imágenes de huevos, esqueletos, dibujos, ejemplares muertos y encuadres poco útiles. Además se verificó la decodificación de todas las fotografías con Flutter.

## Actualización

1. Editar `catalogo_huachipa.json`, conservando las fuentes y fechas. Una nueva ficha debe incluir su foto local, créditos e identificación. Solo habilitar `en_mapa` cuando se disponga de una referencia de ubicación revisada.
2. Ejecutar `python scripts/generar_catalogo_fauna.py` desde la raíz. Genera `catalogo_fauna.dart`, `base_datos_animales.dart` y los marcadores a partir de una sola lista.
3. Ejecutar `dart format lib/core/data/catalogo_fauna.dart lib/core/data/base_datos_animales.dart lib/core/data/datos_marcadores.dart`.
4. Ejecutar `flutter test test/fauna_catalogo_test.dart` y `flutter analyze`.

Para obtener fotografías de nuevos registros puede usarse `python scripts/sincronizar_fotos_fauna.py --inat --only ID`. Este script necesita Pillow y conexión a Internet. Conserva los archivos que ya tienen licencia registrada. Las fotos nuevas deben revisarse visualmente antes de generar los datos Dart. El uso cotidiano de la aplicación y la ejecución de las pruebas no requieren descargar fotografías ni disponer de Python.
