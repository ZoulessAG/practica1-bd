# Ejercicio 6: Propuestas de Mejora del Proyecto Asignado
## Sistema de Visualización de Datos Sísmicos de México (ESCOM IPN)

---

## Integrante 1: Aguilar Garcia Ian Andrew (ZoulessAG)

### Propuesta 1 (Issue #2): Sistema de alertas tempranas y cálculo de réplicas en tiempo real
1. **Título y necesidad:** Sistema de alertas tempranas y cálculo probabilístico de réplicas en tiempo real para eventos de magnitud mayor o igual a 6.0. Resuelve la falta de un módulo predictivo pos-evento que alerte a protección civil sobre la probabilidad de réplicas destructivas inmediatas.
2. **Descripción de la funcionalidad:** La interfaz del sismólogo o analista de riesgos muestra una alerta automática cuando ocurre un sismo significativo, desplegando una estimación porcentual de ocurrencia de réplicas en las siguientes 24 y 48 horas con magnitud estimada.
3. **Cambios en el modelo de datos:** Se agrega la entidad `replica_ai_predictions` vinculada a `EVENTO_SISMICO` con los atributos `id_prediccion` (PK), `id_evento_origen` (FK), `probabilidad_replica`, `magnitud_estimada`, `ventana_tiempo_horas`, `nivel_alerta`, `version_modelo` y `fecha_generacion`.
4. **En qué se apoya:** En la sección de trabajo futuro del Artículo 1 (Villa et al., 2026), donde se destaca la necesidad de evolucionar el análisis descriptivo hacia modelos analíticos predictivos de réplicas sísmicas.
5. **Dificultad estimada:** Alta. Requiere integrar modelos estocásticos y de aprendizaje automático junto con procesamiento en tiempo real.

### Propuesta 2 (Issue #3): Clasificación avanzada por mecanismo focal y geometría de falla
1. **Título y necesidad:** Clasificación geofísica de eventos por mecanismo focal y orientación del plano de falla. Atiende la carencia de datos sobre la cinemática de la fractura (fallamiento normal, inverso o transcurrente).
2. **Descripción de la funcionalidad:** Permite al investigador filtrar los sismos no solo por profundidad y magnitud, sino por el tipo de esfuerzo tectónico y visualizar el diagrama de "pelota de playa" asociado a la deformación.
3. **Cambios en el modelo de datos:** Especialización de la entidad `EVENTO_SISMICO` agregando atributos técnicos: `rumbo_strike`, `buzamiento_dip`, `desplazamiento_rake` y `tipo_mecanismo` en una tabla derivada o extendida.
4. **En qué se apoya:** En la limitación identificada en el artículo de sismos sobre la simplificación de los eventos sísmicos a puntos escalares sin tensor de momento sísmico.
5. **Dificultad estimada:** Media. Exige incorporar atributos de geometría angular y validaciones trigonométricas en el gestor.

### Propuesta 3 (Issue #4): Catálogo normalizado de escalas de intensidad perceptible (Mercalli)
1. **Título y necesidad:** Normalización y registro de aceleración de suelo e intensidad perceptual en Escala Mercalli Modificada (MMI). Resuelve la confusión entre magnitud instrumental y la intensidad real con la que la población percibe la sacudida.
2. **Descripción de la funcionalidad:** El usuario general consulta mapas de calor que reflejan la intensidad con la que se sintió el sismo en distintas colonias o municipios mediante números romanos (I a XII).
3. **Cambios en el modelo de datos:** Creación de la entidad `INTENSIDAD_MERCALLI` (`id_intensidad` PK, `grado_romano`, `descripcion_impacto`, `aceleracion_min_pga`, `aceleracion_max_pga`) relacionada $1:N$ con reportes de percepción de cada evento.
4. **En qué se apoya:** En las conclusiones del Artículo 1 que subrayan la importancia de comunicar el riesgo de manera comprensible para tomadores de decisiones no técnicos.
5. **Dificultad estimada:** Baja. Se basa en una tabla de catálogo estándar y reglas de cálculo deterministas por aceleración de pico de terreno (PGA).

---

## Integrante 2: Vega Treviño Kevin Edu (Elslowee)

### Propuesta 4 (Issue #12): Integración de alertas de tsunami para epicentros oceánicos
1. **Título y necesidad:** Módulo de monitoreo y advertencia de potencial tsunamigénico para sismos con epicentro submarino o costero. Mitiga el riesgo de impacto oceánico no advertido oportunamente.
2. **Descripción de la funcionalidad:** El sistema detecta automáticamente si el sismo ocurrió en zona marítima con profundidad menor a 60 km y magnitud superior a 6.5, emitiendo una notificación de evaluación marítima.
3. **Cambios en el modelo de datos:** Nueva entidad `ALERTA_TSUNAMI` (`id_alerta` PK, `id_sismo` FK, `tiempo_arribo_estimado`, `altura_ola_esperada_m`, `estatus_alerta`, `costa_afectada`) con relación $1:1$ con eventos calificados.
4. **En qué se apoya:** En la línea de trabajo futuro del monitoreo integral costero de la fosa mesoamericana citada en el Artículo 1.
5. **Dificultad estimada:** Media. Demanda filtros geoespaciales marítimos y cálculo de tiempos de propagación de onda en agua.

### Propuesta 5 (Issue #13): Módulo de reportes ciudadanos (Sismología Participativa)
1. **Título y necesidad:** Sistema de reporte colaborativo ciudadano ("¿Lo sentiste?"). Atiende la falta de densidad de sensores en localidades remotas mediante ciencia ciudadana.
2. **Descripción de la funcionalidad:** Los ciudadanos acceden desde su teléfono para confirmar si percibieron el temblor, el tipo de movimiento experimentado (trepidatorio, oscilatorio) y si hubo caída de objetos.
3. **Cambios en el modelo de datos:** Entidad débil `REPORTE_CIUDADANO` (`id_reporte` PK, `id_sismo` FK, `fecha_hora_reporte`, `latitud_usuario`, `longitud_usuario`, `movimiento_percibido`, `danio_aparente`).
4. **En qué se apoya:** En las recomendaciones de integración de datos abiertos heterogéneos descritas en los artículos 1 y 2.
5. **Dificultad estimada:** Media. Requiere sanitización de entradas no confiables y validación de proximidad geoespacial.

### Propuesta 6 (Issue #14): Intersección espacial con infraestructura crítica
1. **Título y necesidad:** Análisis espacial de superposición del radio de afectación sísmica con infraestructura crítica (hospitales, puentes, presas y redes eléctricas).
2. **Descripción de la funcionalidad:** Ante un sismo, el sistema genera automáticamente una lista de hospitales y puentes ubicados dentro de la elipse de mayor aceleración, con semáforo de prioridad de inspección.
3. **Cambios en el modelo de datos:** Entidad `INFRAESTRUCTURA_CRITICA` (`id_activo` PK, `nombre`, `tipo_activo`, `capacidad`, `coordenadas`) y tabla asociativa `EVALUACION_INFRAESTRUCTURA` (`id_evaluacion` PK, `id_sismo` FK, `id_activo` FK, `distancia_epicentro_km`, `nivel_riesgo_estimado`).
4. **En qué se apoya:** En la metodología dimensional geoespacial del Artículo 3 (González et al., en prensa) sobre monitoreo de obras públicas municipales.
5. **Dificultad estimada:** Alta. Demanda extensiones espaciales (PostGIS) y cálculo de intersección topológica poligonal.

---

## Integrante 3: Quintanar Sanchez Alondra (AlooXoX)

### Propuesta 7 (Issue #8): Identificación y visualización de enjambres sísmicos
1. **Título y necesidad:** Detección y agrupamiento automático de secuencias de sismos o enjambres sin sismo principal evidente. Permite alertar sobre actividad tectónica anómala o reactivación volcánica.
2. **Descripción de la funcionalidad:** El analista visualiza un panel que resalta zonas donde la tasa de sismos por kilómetro cuadrado y por hora supera el umbral basal estadístico histórico.
3. **Cambios en el modelo de datos:** Entidad `ENJAMBRE_SISMICO` (`id_enjambre` PK, `fecha_inicio`, `fecha_fin`, `centroide_latitud`, `centroide_longitud`, `total_eventos`, `volcan_asociado`) relacionada $1:N$ con `EVENTO_SISMICO` mediante clave foránea nullable `id_enjambre`.
4. **En qué se apoya:** En las limitaciones de almacenamiento plano expuestas en el levantamiento dimensional del proyecto asignado.
5. **Dificultad estimada:** Media. Emplea algoritmos de agrupamiento espaciotemporal (como DBSCAN espacial) ejecutados sobre la base de datos.

### Propuesta 8 (Issue #9): Monitoreo de brechas sísmicas (Seismic Gaps)
1. **Título y necesidad:** Monitoreo analítico de segmentos de falla con acumulación de energía sin sismos de magnitud relevante en periodos prolongados (ej. Brecha de Guerrero).
2. **Descripción de la funcionalidad:** Muestra indicadores de tiempo transcurrido desde el último evento mayor en cada zona sismogénica, alertando sobre zonas con silencio sísmico anómalo.
3. **Cambios en el modelo de datos:** Entidad `BRECHA_SISMICA` (`id_brecha` PK, `nombre_zona`, `poligono_geografico`, `magnitud_historica_maxima`, `fecha_ultimo_evento_mayor`, `potencial_acumulado_estimado`).
4. **En qué se apoya:** En el análisis histórico de la distribución temporal de sismos presentado en el Artículo 1.
5. **Dificultad estimada:** Media. Requiere consultas analíticas de ventana temporal y funciones de agregación históricas.

### Propuesta 9 (Issue #10): Exportación de reportes y subconjuntos de datos
1. **Título y necesidad:** Módulo de exportación estructurada en formatos científicos estandarizados (QuakeML, GeoJSON, CSV filtrado). Atiende la rigidez del visor que solo muestra tablas en pantalla.
2. **Descripción de la funcionalidad:** Investigadores pueden seleccionar un polígono geográfico y rango de fechas, descargando los datos sísmicos con metadatos completos y formato interoperable.
3. **Cambios en el modelo de datos:** Entidad de registro de exportaciones `LOG_EXPORTACION` (`id_exportacion` PK, `fecha_solicitud`, `parametros_filtro_json`, `formato_salida`, `total_registros_descargados`).
4. **En qué se apoya:** En la necesidad de interoperabilidad con herramientas sismológicas como ObsPy mencionada en los requerimientos del proyecto asignado.
5. **Dificultad estimada:** Baja. Implementa vistas parametrizadas y generación de serializaciones estándar.

---

## Integrante 4: Sanchez Palma Joel (alcatel04)

### Propuesta 10 (Issue #5): Mapeo de vulnerabilidad por tipo de suelo
1. **Título y necesidad:** Integración del mapa de zonificación geotécnica (zona de lago, transición y loma) para ponderar la amplificación de ondas sísmicas en cuencas sedimentarias.
2. **Descripción de la funcionalidad:** El mapa colorea el riesgo de cada municipio o alcaldía combinando la magnitud del sismo con el factor de sitio del suelo sobre el que se asienta.
3. **Cambios en el modelo de datos:** Entidad `TIPO_SUELO` (`id_tipo_suelo` PK, `clave_geotecnica`, `factor_amplificacion_onda`, `periodo_fundamental_segundos`) vinculada a la dimensión `UBICACION_GEOGRAFICA`.
4. **En qué se apoya:** En el marco conceptual de vulnerabilidad territorial desarrollado en el Artículo 2 sobre información heterogénea en la CDMX.
5. **Dificultad estimada:** Media. Integra tablas maestras de mecánica de suelos con la cartografía base.

### Propuesta 11 (Issue #6): Registro histórico de daños estructurales
1. **Título y necesidad:** Catálogo histórico de daños sufridos por edificaciones durante sismos de gran magnitud (1985, 2017). Facilita el cruce entre eventos presentes y antecedentes de afectación estructural.
2. **Descripción de la funcionalidad:** Los ingenieros estructuristas pueden consultar antecedentes de colapsos o grietas en manzanas específicas para inspecciones preventivas.
3. **Cambios en el modelo de datos:** Entidad `HISTORIAL_DANIO` (`id_danio` PK, `id_sismo_causante` FK, `ubicacion_calle`, `alcaldia`, `tipo_danio`, `colapso_total`, `victimas_reportadas`).
4. **En qué se apoya:** En las conclusiones del Artículo 3 sobre la importancia de auditar el impacto a largo plazo de fenómenos sobre el entorno urbano.
5. **Dificultad estimada:** Baja. Se estructura mediante entidades relacionales estándar y consultas cruzadas históricas.

### Propuesta 12 (Issue #7): Zonificación de impacto real mediante isosistas (Polígonos Espaciales)
1. **Título y necesidad:** Generación y modelado de polígonos cerrados de isosistas (curvas de igual sacudida) derivados de atenuación matemática y lecturas instrumentales de aceleración.
2. **Descripción de la funcionalidad:** El sistema dibuja sobre el mapa los contornos concéntricos o distorsionados de aceleración real, permitiendo a los municipios evaluar el nivel de impacto recibido.
3. **Cambios en el modelo de datos:** Entidad `ISOSISTA` (`id_isosista` PK, `id_sismo` FK, `nivel_aceleracion_gal`, `geometria_poligono_wkt`, `area_afectada_km2`) con relación $1:N$ con `EVENTO_SISMICO`.
4. **En qué se apoya:** En los modelos matemáticos de atenuación de ondas sísmicas citados en la bibliografía técnica del Artículo 1.
5. **Dificultad estimada:** Alta. Requiere cálculo matemático de curvas de atenuación espacial y renderizado de geometrías espaciales complejas.
