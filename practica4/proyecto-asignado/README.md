# Ejercicio 1.7: Proyecto Asignado — Sismos (Datos y Dominios)

- **Repositorio asignado:** `gabrielhuav/Seismic-Data-Visualization-System`
- **Fuente oficial de datos:** Catálogo público del **Servicio Sismológico Nacional (SSN)** (`ssn.unam.mx`) e indicadores sociodemográficos/económicos de **INEGI**.

## 1.7.1 Carga y verificación de esquema en PostgreSQL
Se levantó el esquema `sql/00-datawarehouse_tables.sql` en la base de datos `sismos_p4_5` (`postgres_laboratorio`):
- Dimensiones: `dim_sismos`, `dim_zonas`, `dim_tiempo`, `dim_economia`
- Tabla de hechos: `fact_impacto_sismos_imputed`

*(Nota: los archivos `01-dim_zonas.sql` a `05-fact_impacto_sismos_imputed.sql` del repositorio del proyecto asignado contienen la carga del almacén dimensional para reproducir los conteos del artículo AZCATL 2026).*

## 1.7.2 Comparación con el artículo
- En el artículo (*Cuando México tiembla: la historia contada por los datos*, Villa Vargas et al., 2026), los totales dependen del corte histórico de eventos del SSN y del censo/censos económicos del INEGI integrados al almacén.
- Cualquier diferencia al cargar un recorte más reciente del catálogo público del SSN responde a la ventana temporal seleccionada (fechas de corte) y a la actualización continua de magnitudes revisadas por el SSN.

## 1.7.3 Restricciones de dominio faltantes y 3 propuestas
El archivo `00-datawarehouse_tables.sql` declara `PRIMARY KEY` y `FOREIGN KEY`, pero **omite restricciones `CHECK` de dominio** y `NOT NULL` en atributos clave. Se proponen las siguientes tres restricciones sobre una copia:

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
