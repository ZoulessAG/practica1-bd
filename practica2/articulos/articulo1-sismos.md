# 📄 Resumen de Artículo Científico 1

**Cita en formato APA (7.ª edición):**
> Villa Vargas, J. M., Hurtado Avilés, G., & Climent Hernández, J. A. (2026). Cuando México tiembla: la historia contada por los datos. *AZCATL Revista de Divulgación de la Ciencia, la Ingeniería y la Innovación*, 4(6), 28-33. https://doi.org/10.24275/AZC2026E1004

---

### 1. ¿Qué problema aborda el artículo y por qué importa?
El artículo aborda la fragmentación y falta de accesibilidad visual de los registros históricos de sismicidad en México. La actividad tectónica en el país genera un volumen constante de datos que resulta complejo de interpretar en su formato crudo. Su relevancia radica en que la transformación de estos datos en información estructurada y geoespacial permite analizar patrones espacio-temporales, fortaleciendo la divulgación científica, la prevención de riesgos sísmicos y la toma de decisiones en protección civil.

### 2. ¿De dónde provienen los datos, en qué formato estaban y qué tuvo que hacerse para poder usarlos?
Los datos provienen de los catálogos públicos del Servicio Sismológico Nacional (SSN) de México. Originalmente se encontraban en formatos heterogéneos y no estructurados (archivos planos CSV/TXT y consultas web desarticuladas). Para poder utilizarlos, se requirió un proceso de extracción, limpieza, normalización de magnitudes/coordenadas, filtrado de datos atípicos o incompletos y la estructuración en un modelo de base de datos relacional y geoespacial apto para consultas eficientes.

### 3. ¿Cómo se modeló la información?
El dominio se modeló identificando como hecho principal los **eventos sísmicos** (medidos mediante variables como magnitud, profundidad y coordenadas de epicentro). Estos hechos se vinculan con dimensiones contextuales como:
* **Ubicación geográfica:** Estados, municipios y regiones tectónicas.
* **Temporalidad:** Fecha, hora y época del registro.
* **Aspectos técnicos:** Estatutos de revisión y estaciones de monitoreo.

Las relaciones conectan cada sismo registrado con su ubicación exacta y sus parámetros temporales y técnicos.

### 4. ¿Qué preguntas concretas puede responder el sistema resultante?
* ¿Cuáles son las zonas geográficas con mayor concentración de epicentros y mayor magnitud promedio en los últimos años?
* ¿Existe alguna correlación o distribución particular entre la profundidad de los sismos y la magnitud registrada?
* ¿Cómo ha variado la frecuencia de eventos sísmicos por región a lo largo del tiempo?

### 5. ¿Qué limitaciones reconocen los autores y qué trabajo futuro proponen?
* **Limitaciones:** Heterogeneidad en la precisión de datos históricos antiguos respecto a los modernos, e imposibilidad actual de integrarle fuentes de monitoreo en tiempo real.
* **Trabajo Futuro:** Evolucionar la arquitectura hacia un entorno *lakehouse* o almacén de datos dimensional que integre análisis predictivos mediante *machine learning* y alertas tempranas interactivas.