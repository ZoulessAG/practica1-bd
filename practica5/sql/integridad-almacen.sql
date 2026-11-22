-- ==============================================================================
-- Práctica 5 - Ejercicio 2.5: Verificación de Integridad Referencial en Sismos
-- Base de datos: sismos_p4_5
-- ==============================================================================

-- 1. Listar claves foráneas declaradas en fact_impacto_sismos_imputed
SELECT tc.constraint_name, kcu.column_name, ccu.table_name AS tabla_referenciada
  FROM information_schema.table_constraints tc
  JOIN information_schema.key_column_usage kcu ON tc.constraint_name = kcu.constraint_name
  JOIN information_schema.constraint_column_usage ccu ON tc.constraint_name = ccu.constraint_name
 WHERE tc.table_name = 'fact_impacto_sismos_imputed'
   AND tc.constraint_type = 'FOREIGN KEY'
 ORDER BY tc.constraint_name;

-- 2. Búsqueda de hechos huérfanos (debe devolver 0 filas)
SELECT f.id_sismo, f.id_zonas, f.id_economia, f.id_tiempo
  FROM fact_impacto_sismos_imputed f
  LEFT JOIN dim_sismos s   ON f.id_sismo = s.id_sismo
  LEFT JOIN dim_zonas z    ON f.id_zonas = z.id_zonas
  LEFT JOIN dim_economia e ON f.id_economia = e.id_economia
  LEFT JOIN dim_tiempo t   ON f.id_tiempo = t.id_tiempo
 WHERE s.id_sismo IS NULL
    OR z.id_zonas IS NULL
    OR e.id_economia IS NULL
    OR t.id_tiempo IS NULL;
