-- Consulta 13: Division Relacional (div)
-- Pregunta: ¿Que ordenes medicas prescriben TODOS los estudios de orina del catalogo institucional?
SELECT o.folio_orden, o.nss_paciente, o.medico_emisor
FROM orden_medica o
WHERE NOT EXISTS (
    SELECT po.id_estudio
    FROM prueba_orina po
    EXCEPT
    SELECT oe.id_estudio
    FROM orden_estudio oe
    WHERE oe.folio_orden = o.folio_orden
);
