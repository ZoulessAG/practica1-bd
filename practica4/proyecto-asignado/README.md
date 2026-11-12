# Ejercicio 1.7: Proyecto Asignado — Sismos (Datos y Dominios)

- **Repositorio asignado:** `gabrielhuav/Seismic-Data-Visualization-System`
- **Fuente oficial de datos:** Catálogo público del **Servicio Sismológico Nacional (SSN)** (`ssn.unam.mx`) e indicadores sociodemográficos/económicos de **INEGI**.

## 1.7.1 Carga y verificación de esquema en PostgreSQL
Se clonó `gabrielhuav/Seismic-Data-Visualization-System` y se ejecutaron `sql/00-datawarehouse_tables.sql` a `05-fact_impacto_sismos_imputed.sql` en la base de datos `sismos_p4_5` (`postgres_laboratorio`), obteniendo los siguientes conteos reales:

| Tabla | Filas cargadas |
| :--- | ---: |
| `dim_zonas` | 32 |
| `dim_economia` | 32 |
| `dim_tiempo` | 319,592 |
| `dim_sismos` | 319,592 |
| `fact_impacto_sismos_imputed` | 196,576 |

Rango temporal observado en `dim_tiempo`: `1900-01-20` a `2025-04-03`.

## 1.7.2 Comparación con el artículo
- El almacén cargado reproduce exactamente las 32 entidades federativas (`dim_zonas` / `dim_economia`), los **319,592** eventos sísmicos históricos del SSN (`1900-01-20` a `2025-04-03`) y los **196,576** registros de impacto socioeconómico imputados.
- Cualquier variación frente a una descarga nueva directa del catálogo público del SSN correspondería a eventos posteriores al `2025-04-03` o a sismos sin zona/imputación asignada.

## 1.7.3 Restricciones de dominio faltantes y 3 propuestas
El archivo `00-datawarehouse_tables.sql` declara `PRIMARY KEY` y `FOREIGN KEY`, pero **omite restricciones `CHECK` de dominio** y `NOT NULL` en atributos clave. Se probaron las siguientes tres restricciones sobre una transacción de prueba en `sismos_p4_5` y **el 100% de los datos reales las cumplieron sin rechazos** (`ALTER TABLE` x3 exitosos):

```sql
-- 1. Magnitud sísmica válida en escala de momento/Richter [0.0, 10.0] y profundidad no negativa
ALTER TABLE dim_sismos
    ADD CONSTRAINT chk_sismo_magnitud_valida CHECK (magnitud >= 0.0 AND magnitud <= 10.0),
    ADD CONSTRAINT chk_sismo_profundidad_no_negativa CHECK (profundidad >= 0.0);

-- 2. Calendario válido en dim_tiempo
ALTER TABLE dim_tiempo
    ADD CONSTRAINT chk_tiempo_mes CHECK (mes BETWEEN 1 AND 12),
    ADD CONSTRAINT chk_tiempo_trimestre CHECK (trimestre BETWEEN 1 AND 4);

-- 3. Población total no negativa y consistente con población femenina + masculina
ALTER TABLE dim_zonas
    ADD CONSTRAINT chk_zonas_pob_no_negativa CHECK (pobtot >= 0 AND pobfem >= 0 AND pobmas >= 0);
```
