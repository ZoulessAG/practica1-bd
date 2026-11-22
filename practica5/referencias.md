# Ejercicios 2.1 y 2.2: Claves Foráneas y Acciones Referenciales

## 2.1 Tabla de claves foráneas del proyecto propio

| Tabla hija | Columna FK | Tabla padre (columna) | Relación EER | ¿Admite `NULL`? | Justificación por cardinalidad |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `paciente` | `nss_titular` | `paciente (nss)` | Titular–Beneficiario (1:N recursiva) | Sí | Un paciente titular no tiene titular superior (`0..1`). |
| `paciente_telefono` | `nss` | `paciente (nss)` | Atributo multivaluado de `paciente` | No | Todo teléfono pertenece obligatoriamente a un paciente. |
| `orden_medica` | `nss_paciente` | `paciente (nss)` | Presenta (1:N) | No | Toda orden médica se emite para un paciente existente (`1..1`). |
| `cita` | `folio_orden` | `orden_medica (folio_orden)` | Genera (1:1) | No | Una cita de laboratorio requiere una orden médica (`1..1`, `UNIQUE`). |
| `orden_estudio` | `folio_orden` | `orden_medica (folio_orden)` | Contiene (N:M) | No | Parte de la PK compuesta de la relación asociativa. |
| `orden_estudio` | `id_estudio` | `estudio (id_estudio)` | Contiene (N:M) | No | Parte de la PK compuesta de la relación asociativa. |
| `prueba_sangre` | `id_estudio` | `estudio (id_estudio)` | Especialización (supertipo–subtipo) | No | El subtipo comparte PK/FK con `estudio`. |
| `prueba_orina` | `id_estudio` | `estudio (id_estudio)` | Especialización (supertipo–subtipo) | No | El subtipo comparte PK/FK con `estudio`. |
| `prueba_fecal` | `id_estudio` | `estudio (id_estudio)` | Especialización (supertipo–subtipo) | No | El subtipo comparte PK/FK con `estudio`. |
| `resultado` | `id_cita` | `cita (id_cita)` | Produce (1:N) | No | Todo resultado proviene de una cita agendada. |
| `resultado` | `id_estudio` | `estudio (id_estudio)` | Corresponde a (1:N) | No | Todo resultado corresponde a un estudio del catálogo. |

## 2.2 Justificación de acciones referenciales (`ON DELETE` / `ON UPDATE`)

| FK | `ON DELETE` | `ON UPDATE` | Regla de negocio |
| :--- | :--- | :--- | :--- |
| `fk_paciente_titular` | `RESTRICT` | `CASCADE` | No se elimina un titular mientras tenga beneficiarios activos; si cambia su NSS, se propaga. |
| `fk_telefono_paciente` | `CASCADE` | `CASCADE` | Los teléfonos son propiedad del paciente y no tienen sentido sin él. |
| `fk_orden_paciente` | `RESTRICT` | `CASCADE` | No se elimina un paciente con historial de órdenes médicas. |
| `fk_cita_orden` | `CASCADE` | `CASCADE` | Si se cancela/elimina la orden raíz en pruebas administrativas, la cita dependiente desaparece con ella. |
| `fk_oe_orden` | `CASCADE` | `CASCADE` | El detalle de la orden depende existencialmente de `orden_medica`. |
| `fk_oe_estudio` | `RESTRICT` | `CASCADE` | No se puede borrar un estudio del catálogo si aparece en órdenes médicas. |
| `fk_sangre/orina/fecal_estudio` | `CASCADE` | `CASCADE` | El registro subtipo depende existencialmente de su supertipo `estudio`. |
| `fk_resultado_cita` | `CASCADE` | `CASCADE` | Los resultados pertenecen a la cita de laboratorio que los originó. |
| `fk_resultado_estudio` | `RESTRICT` | `CASCADE` | No se puede eliminar del catálogo un estudio que ya tiene resultados históricos. |
