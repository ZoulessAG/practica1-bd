-- Consulta 3: Seleccion y Proyeccion Combinadas
-- Pregunta: ¿Cuales son las pruebas de sangre que requieren 8 o mas horas de ayuno estricto?
SELECT id_estudio, tipo_tubo, color_tapon, ayuno_horas
FROM prueba_sangre
WHERE ayuno_horas >= 8;
