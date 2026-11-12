# Ejercicios 1.1 y 1.2: Tipos de Dato, Dominios y Restricciones

## 1.1 Tipos de dato y dominios reutilizables (`001-dominios.sql`)

Para evitar duplicar reglas de formato y longitud en varias tablas, se definieron tres **dominios** (`CREATE DOMAIN`) y un **tipo enumerado** (`CREATE TYPE`) en [001-dominios.sql](./migraciones/001-dominios.sql):

| Objeto | Definición | Regla de dominio y ventaja |
| :--- | :--- | :--- |
| `dom_nss` | `VARCHAR(15) CHECK (VALUE ~ '^[0-9]{10,11}$')` | Garantiza que todo NSS en `paciente`, `paciente_telefono` y `orden_medica` tenga 10 u 11 dígitos numéricos sin repetir el `CHECK` en cada tabla. |
| `dom_telefono` | `VARCHAR(15) CHECK (VALUE ~ '^[0-9]{8,15}$')` | Valida formato numérico de 8 a 15 dígitos en `paciente_telefono`. |
| `dom_folio_orden` | `VARCHAR(20) CHECK (VALUE ~ '^ORD-[0-9]{4}-[0-9]{3,6}$')` | Estandariza el folio (`ORD-AAAA-NNN`) en `orden_medica`, `cita` y `orden_estudio`. |
| `enum_estatus_asistencia` | `ENUM ('PROGRAMADA','CONFIRMADA','ASISTIO','CANCELADA','NO_ASISTIO')` | Restringe los estados permitidos de una cita a nivel de tipo en `cita.estatus_asistencia`. |

### Tabla de columnas del proyecto propio

| Tabla | Columna | Tipo elegido | Justificación |
| :--- | :--- | :--- | :--- |
| `paciente` | `nss` | `dom_nss` | Identificador oficial numérico de 10–11 dígitos (texto para preservar ceros a la izquierda). |
| `paciente` | `nombre` | `VARCHAR(100)` | Nombre completo variable; suficiente sin desperdiciar espacio. |
| `paciente` | `estatus_vigencia` | `BOOLEAN` | Estado binario activo/inactivo (`DEFAULT TRUE`). |
| `paciente` | `unidad_medica_adscripcion` | `VARCHAR(100)` | Nombre de UMF/HGZ de longitud variable. |
| `paciente` | `nss_titular` | `dom_nss` | Referencia recursiva al titular; admite `NULL` si el paciente es titular. |
| `paciente_telefono` | `telefono` | `dom_telefono` | Cadena numérica de 8 a 15 dígitos; nunca numérico puro para no perder prefijos. |
| `orden_medica` | `folio_orden` | `dom_folio_orden` | Código estructurado `ORD-AAAA-NNNN`. |
| `orden_medica` | `fecha_cita_medico` | `DATE` | Solo fecha calendario (sin hora) para calcular días de anticipación. |
| `orden_medica` | `medico_emisor` | `VARCHAR(100)` | Nombre y cédula del médico tratante. |
| `cita` | `id_cita` | `SERIAL` | Clave subrogada autoincremental (`INT`). |
| `cita` | `fecha_hora_agendamiento` | `TIMESTAMPTZ` | Marca de tiempo exacta con zona horaria (`DEFAULT CURRENT_TIMESTAMP`). |
| `cita` | `fecha_hora_laboratorio` | `TIMESTAMPTZ` | Fecha y hora exacta de toma de muestra con zona horaria. |
| `cita` | `estatus_asistencia` | `enum_estatus_asistencia` | Lista cerrada de 5 estados (`DEFAULT 'PROGRAMADA'`). |
| `estudio` | `id_estudio` | `SERIAL` | Identificador entero autoincremental. |
| `estudio` | `nombre_estudio` | `VARCHAR(100)` | Nombre único del estudio clínico (`UNIQUE`). |
| `estudio` | `indicaciones_previas` | `TEXT` | Instrucciones de preparación sin límite rígido de longitud. |
| `prueba_sangre` | `tipo_tubo` / `color_tapon` | `VARCHAR(50)` / `VARCHAR(30)` | Especificación corta del insumo de laboratorio. |
| `prueba_sangre` | `ayuno_horas` | `INT` | Entero exacto (`DEFAULT 8`, rango `0..24`). |
| `prueba_orina` | `tipo_frasco` / `volumen_minimo` | `VARCHAR(50)` / `VARCHAR(30)` | Recipiente y volumen requerido. |
| `prueba_fecal` | `requiere_medio_transporte` | `BOOLEAN` | Indicador binario (`DEFAULT FALSE`). |
| `resultado` | `id_resultado` | `SERIAL` | Identificador entero autoincremental. |
| `resultado` | `valor_obtenido` | `VARCHAR(100)` | Admite valores cuantitativos o cualitativos (`Negativo`, `95.4`). |
| `resultado` | `unidad_medida` / `rango_referencia` | `VARCHAR(30)` / `VARCHAR(100)` | Opcionales en pruebas cualitativas. |
| `resultado` | `fecha_hora_emision` | `TIMESTAMPTZ` | Momento de validación del resultado (`DEFAULT CURRENT_TIMESTAMP`). |

---

## 1.2 Restricciones de columna (`ALTER TABLE` en `001-dominios.sql`)

Todas las restricciones agregadas mediante migración responden a una regla del negocio:

| # | Tabla | Restricción | Regla del dominio |
| :--- | :--- | :--- | :--- |
| 1 | `paciente` | `chk_paciente_nombre_valido` | El nombre del paciente debe tener al menos 3 caracteres útiles. |
| 2 | `paciente` | `chk_paciente_unidad_valida` | La unidad médica de adscripción debe tener al menos 4 caracteres. |
| 3 | `paciente` | `chk_paciente_no_auto_titular` | Un paciente no puede ser titular de sí mismo (`nss_titular <> nss`). |
| 4 | `orden_medica` | `chk_orden_fecha_valida` | La fecha de consulta médica debe ser igual o posterior a `2020-01-01`. |
| 5 | `orden_medica` | `chk_medico_emisor_valido` | El nombre/cédula del médico emisor debe tener al menos 5 caracteres. |
| 6 | `cita` | `chk_cita_horario_laboral` | Las tomas de muestra solo se agendan entre 06:00 y 20:59 (hora local). |
| 7 | `cita` | `chk_fechas_coherentes` | La fecha de laboratorio no puede ser anterior al agendamiento. |
| 8 | `estudio` | `chk_estudio_nombre_valido` | El nombre del estudio debe tener al menos 3 caracteres útiles. |
| 9 | `prueba_sangre` | `chk_sangre_tubo_valido` | El tipo de tubo debe tener al menos 3 caracteres. |
| 10 | `prueba_sangre` | `chk_sangre_tapon_valido` | El color de tapón debe tener al menos 3 caracteres. |
| 11 | `prueba_orina` | `chk_orina_volumen_valido` | El volumen mínimo debe especificar al menos 2 caracteres. |
| 12 | `resultado` | `chk_resultado_valor_no_vacio` | El valor obtenido no puede ser una cadena en blanco. |
| 13 | `resultado` | `chk_resultado_fecha_valida` | La fecha de emisión del resultado debe ser `>= 2020-01-01`. |
| 14 | `resultado` | `uq_resultado_cita_estudio` | Un estudio solo puede tener un resultado por cita (`UNIQUE (id_cita, id_estudio)`). |
