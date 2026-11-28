-- Consulta 6: Interseccion de Conjuntos (cap)
-- Pregunta: ¿Que estudios clinicos fueron prescritos simultaneamente en las ordenes ORD-2026-0001 y ORD-2026-0003?
SELECT id_estudio
FROM orden_estudio
WHERE folio_orden = 'ORD-2026-0001'
INTERSECT
SELECT id_estudio
FROM orden_estudio
WHERE folio_orden = 'ORD-2026-0003';
