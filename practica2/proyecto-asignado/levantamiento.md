# Ejercicio 5: Levantamiento y Modelo EER del Proyecto Asignado (Datos Sísmicos)

## 1. Justificación de la Ingeniería Inversa Conceptual
El repositorio del proyecto asignado implementa un **almacén de datos dimensional (esquema en estrella)** diseñado para consultas analíticas (OLAP). Siguiendo las especificaciones de la práctica, este ejercicio realiza un proceso de ingeniería inversa para abstraer el esquema publicado hacia el **modelo conceptual (EER)** del dominio real de la sismicidad en México, capturando sus entidades reales, reglas de negocio y restricciones relacionales.

---

## 2. Abstracción de Entidades y Reglas de Negocio

### Entidades Fuertes
* **`UBICACION_GEOGRAFICA`**: Representa la delimitación territorial del evento (Estado, Municipio, Región Tectónica).
* **`ESTACION_SISMICA`**: Representa la infraestructura física de monitoreo (Red sísmica, coordenadas, estatus operativo).
* **`EVENTO_SISMICO`**: Representa la ocurrencia del sismo (Fecha/hora UTC, magnitud, profundidad, epicentro).

### Entidad Débil Identificada
* **`REGISTRO_ESTACION`** (Dependencia de Existencia e Identificación):  
  No puede existir sin un `EVENTO_SISMICO` y una `ESTACION_SISMICA` que capture la onda sísmica. Representa las lecturas individuales registradas por cada estación para un evento particular y se identifica de forma combinada.

### Jerarquía de Especialización Identificada
* **Superclase**: `EVENTO_SISMICO`
* **Subclases**:
    * `SISMO_TECTONICO` (Atributos propios: `placa_origen`, `mecanismo_focal`).
    * `SISMO_VOLCANICO` (Atributos propios: `volcan_asociado`, `frecuencia_tremor`).
* **Restricciones**: Disyuntiva ($d$), Total ($t$). Todo evento sísmico pertenece obligatoriamente a un tipo de origen y no puede pertenecer a ambos de forma simultánea.