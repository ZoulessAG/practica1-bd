-- Consulta 12: Agrupacion Multitabla con Conteo (gamma)
-- Pregunta: ¿Cuantos estudios de laboratorio en total ha prescrito cada medico emisor?
SELECT o.medico_emisor, COUNT(oe.id_estudio) AS total_estudios_prescritos
FROM orden_medica o
JOIN orden_estudio oe ON o.folio_orden = oe.folio_orden
GROUP BY o.medico_emisor
ORDER BY total_estudios_prescritos DESC;
