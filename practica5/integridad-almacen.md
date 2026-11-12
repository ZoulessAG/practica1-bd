# Ejercicio 2.5: Integridad Referencial en el Almacén Asignado (Sismos)

Script: [sql/integridad-almacen.sql](./sql/integridad-almacen.sql) sobre `sismos_p4_5` (`Seismic-Data-Visualization-System`).

## 1. Hechos, dimensiones y granularidad
- **Tabla de hechos:** `fact_impacto_sismos_imputed`
- **Dimensiones:** `dim_sismos`, `dim_zonas`, `dim_economia`, `dim_tiempo`
- **Granularidad:** Cada renglón representa el impacto socioeconómico estimado (`poblacion_afectada`, `impacto_economico`, `determinante_de_riesgo`, `riesgo_proporcional`, `indice_zscore`) de **un evento sísmico específico (`id_sismo`) ocurrido en un instante (`id_tiempo`) sobre una entidad/zona (`id_zonas`) y su perfil económico (`id_economia`)**.

## 2. Claves foráneas declaradas en el esquema
A diferencia de algunos almacenes que omiten FKs, `00-datawarehouse_tables.sql` **sí declara** las 4 claves foráneas en `fact_impacto_sismos_imputed`:
- `fact_impacto_sismos_imputed_id_sismo_fkey` → `dim_sismos(id_sismo)`
- `fact_impacto_sismos_imputed_id_zonas_fkey` → `dim_zonas(id_zonas)`
- `fact_impacto_sismos_imputed_id_economia_fkey` → `dim_economia(id_economia)`
- `fact_impacto_sismos_imputed_id_tiempo_fkey` → `dim_tiempo(id_tiempo)`

## 3. Por qué un almacén a veces las omite a propósito y qué riesgo corre
- **Por qué se omiten:** Para acelerar cargas masivas ETL (`COPY`/batch) evitando verificar cada fila contra 4 dimensiones durante la ingesta y permitiendo cargas paralelas desordenadas.
- **Riesgo:** Si falla el ETL o falta un registro en una dimensión, quedan **hechos huérfanos** que desaparecen silenciosamente al hacer `INNER JOIN` en los tableros analíticos, distorsionando sumas y promedios.
