# Diccionario de Datos y Preservación del Significado
## Proyecto Propio: Citas Médicas y Laboratorio

---

## 1. Diagrama del Modelo Relacional

![Diagrama Relacional](diagrama-relacional.png)

---

## 2. Diccionario de Datos Relacional

| Tabla | Columna | Tipo de Dato | Restricciones | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| `paciente` | `nss` | `VARCHAR(15)` | `PRIMARY KEY`, `NOT NULL` | Número de Seguridad Social, identificador único del derechohabiente. |
| `paciente` | `nombre` | `VARCHAR(100)` | `NOT NULL` | Nombre completo del derechohabiente. |
| `paciente` | `estatus_vigencia` | `BOOLEAN` | `NOT NULL`, `DEFAULT TRUE` | Bandera de vigencia de derechos ante el instituto. |
| `paciente` | `unidad_medica_adscripcion`| `VARCHAR(100)`| `NOT NULL` | Clínica o UMF asignada al derechohabiente. |
| `paciente` | `nss_titular` | `VARCHAR(15)` | `FOREIGN KEY REFERENCES paciente(nss)` | NSS del titular si este registro es beneficiario (recursivo). |
| `paciente_telefono` | `nss` | `VARCHAR(15)` | `PRIMARY KEY`, `FOREIGN KEY REFERENCES paciente(nss)` | NSS del derechohabiente propietario del teléfono. |
| `paciente_telefono` | `telefono` | `VARCHAR(15)` | `PRIMARY KEY`, `NOT NULL`, `CHECK` | Número telefónico de contacto (permite múltiples números). |
| `orden_medica` | `folio_orden` | `VARCHAR(20)` | `PRIMARY KEY`, `NOT NULL` | Código de folio alfanumérico emitido por el médico. |
| `orden_medica` | `fecha_cita_medico` | `DATE` | `NOT NULL` | Fecha en la que el médico expidió la orden. |
| `orden_medica` | `medico_emisor` | `VARCHAR(100)` | `NOT NULL` | Nombre o cédula profesional del médico tratante. |
| `orden_medica` | `nss_paciente` | `VARCHAR(15)` | `NOT NULL`, `FOREIGN KEY REFERENCES paciente(nss)` | Derechohabiente al que se le expidió la orden médica. |
| `cita` | `id_cita` | `SERIAL` | `PRIMARY KEY`, `NOT NULL` | Identificador secuencial de la cita en laboratorio. |
| `cita` | `fecha_hora_agendamiento` | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT NOW()` | Fecha y hora en que se agendó la cita. |
| `cita` | `fecha_hora_laboratorio` | `TIMESTAMPTZ` | `NOT NULL`, `CHECK(>= agendamiento)`| Fecha y hora programada para acudir a toma de muestra. |
| `cita` | `estatus_asistencia` | `VARCHAR(20)` | `NOT NULL`, `CHECK(IN(...))` | Estado de la cita ('PROGRAMADA', 'CONFIRMADA', 'ASISTIO', etc.). |
| `cita` | `folio_orden` | `VARCHAR(20)` | `NOT NULL`, `UNIQUE`, `FOREIGN KEY` | Folio de la orden médica asociada a la cita ($1:1$). |
| `estudio` | `id_estudio` | `SERIAL` | `PRIMARY KEY`, `NOT NULL` | Identificador autoincremental del catálogo de estudios. |
| `estudio` | `nombre_estudio` | `VARCHAR(100)` | `NOT NULL`, `UNIQUE` | Denominación del estudio clínico. |
| `estudio` | `indicaciones_previas` | `TEXT` | Opcional | Instrucciones preparatorias para el paciente. |
| `orden_estudio`| `folio_orden` | `VARCHAR(20)` | `NOT NULL`, `FOREIGN KEY`, `PK COMPUESTA` | Orden médica que prescribe el estudio ($N:M$). |
| `orden_estudio`| `id_estudio` | `INT` | `NOT NULL`, `FOREIGN KEY`, `PK COMPUESTA` | Estudio prescrito en la orden. |
| `prueba_sangre`| `id_estudio` | `INT` | `PRIMARY KEY`, `FOREIGN KEY` | Vínculo de supertipo hacia `estudio(id_estudio)`. |
| `prueba_sangre`| `tipo_tubo` | `VARCHAR(50)` | `NOT NULL` | Tipo de tubo de ensayo (gel separador, anticoagulante). |
| `prueba_sangre`| `color_tapon` | `VARCHAR(30)` | `NOT NULL` | Color estandarizado del tapón (Rojo, Oro, Lila). |
| `prueba_sangre`| `ayuno_horas` | `INT` | `NOT NULL`, `CHECK(>= 0 AND <= 24)` | Horas mínimas requeridas de ayuno previo. |
| `prueba_orina` | `id_estudio` | `INT` | `PRIMARY KEY`, `FOREIGN KEY` | Vínculo de supertipo hacia `estudio(id_estudio)`. |
| `prueba_orina` | `tipo_frasco` | `VARCHAR(50)` | `NOT NULL` | Envase estéril recolector. |
| `prueba_orina` | `volumen_minimo`| `VARCHAR(30)` | `NOT NULL` | Volumen mínimo requerido para el análisis. |
| `prueba_fecal` | `id_estudio` | `INT` | `PRIMARY KEY`, `FOREIGN KEY` | Vínculo de supertipo hacia `estudio(id_estudio)`. |
| `prueba_fecal` | `tipo_frasco` | `VARCHAR(50)` | `NOT NULL` | Frasco o vial colector de muestra fecal. |
| `prueba_fecal` | `requiere_medio_transporte` | `BOOLEAN` | `NOT NULL`, `DEFAULT FALSE`| Indica si requiere medio líquido preservador. |
| `resultado` | `id_resultado` | `SERIAL` | `PRIMARY KEY`, `NOT NULL` | Identificador único del reporte analítico emitido. |
| `resultado` | `valor_obtenido`| `VARCHAR(100)`| `NOT NULL` | Lectura numérica o cualitativa obtenida en laboratorio. |
| `resultado` | `unidad_medida` | `VARCHAR(30)` | Opcional | Unidad física de medición (mg/dL, g/L, mm3). |
| `resultado` | `rango_referencia` | `VARCHAR(100)`| Opcional | Rango biológico de referencia esperado. |
| `resultado` | `fecha_hora_emision` | `TIMESTAMPTZ`| `NOT NULL`, `DEFAULT NOW()`| Marca de tiempo exacta de liberación del resultado. |
| `resultado` | `observaciones` | `TEXT` | Opcional | Comentarios clínicos adicionales. |
| `resultado` | `id_cita` | `INT` | `NOT NULL`, `FOREIGN KEY` | Cita de laboratorio que generó este resultado. |
| `resultado` | `id_estudio` | `INT` | `NOT NULL`, `FOREIGN KEY` | Estudio clínico al que califica este resultado. |

---

## 3. Matriz de Preservación del Significado (Ejercicio 6.5)

| Elemento en Modelo EER | Representación en Esquema Relacional | Mecanismo de Preservación de Reglas de Negocio | Estado de Preservación |
| :--- | :--- | :--- | :--- |
| **Entidad `PACIENTE`** | Tabla `paciente` | Clave primaria en `nss`. | Preservado íntegramente. |
| **Atributo Multivaluado `telefono`** | Tabla `paciente_telefono` | Clave primaria compuesta `(nss, telefono)` con `ON DELETE CASCADE`. Soporta múltiples números por paciente. | Preservado (Regla 3). |
| **Relación recursiva `depende_de`** | Columna `nss_titular` en tabla `paciente` | Clave foránea autorreferencial con `RESTRICT`. Permite titulares sin dependientes y beneficiarios ligados. | Preservado (Regla 4). |
| **Relación `PRESENTA`** | Clave foránea `nss_paciente` en `orden_medica` | `NOT NULL` y `FOREIGN KEY`, obligando a que toda orden pertenezca a un paciente existente. | Preservado (Regla 4). |
| **Relación $1:1$ `GENERA`** | Clave foránea `folio_orden` en tabla `cita` | Restricción `UNIQUE` y `NOT NULL`. Evita que una orden agende múltiples citas. | Preservado (Regla 6). |
| **Relación $N:M$ `CONTIENE`** | Tabla asociativa `orden_estudio` | Clave primaria compuesta `(folio_orden, id_estudio)` con claves foráneas en cascada. | Preservado (Regla 5). |
| **Jerarquía `ESTUDIO` ($d, t$)** | Supertipo `estudio` + subtipos `prueba_sangre`, `prueba_orina`, `prueba_fecal` | Claves primarias foráneas compartidas (`ON DELETE CASCADE`). Evita nulos en subtipos. | Preservado (Regla 9, Estrategia A). |
| **Relación `ARROJA` ($1:N$)** | Claves foráneas `id_cita` e `id_estudio` en tabla `resultado` | `NOT NULL` y `ON DELETE CASCADE`. Vincula cada resultado a la cita y al estudio evaluado. | Preservado fielmente. |
