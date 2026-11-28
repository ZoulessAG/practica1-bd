-- Consulta 7: Producto Cartesiano (x)
-- Pregunta: ¿Cual es la combinacion completa entre el catalogo de estudios de orina y los frascos de pruebas fecales?
SELECT e.nombre_estudio, pf.tipo_frasco
FROM estudio e
JOIN prueba_orina po ON e.id_estudio = po.id_estudio
CROSS JOIN (SELECT DISTINCT tipo_frasco FROM prueba_fecal) pf;
