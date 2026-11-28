-- Consulta 11: Agrupacion y Agregacion (gamma)
-- Pregunta: ¿Cuantas citas clinicas existen agrupadas por estatus de asistencia?
SELECT estatus_asistencia, COUNT(id_cita) AS total_citas
FROM cita
GROUP BY estatus_asistencia
ORDER BY total_citas DESC;
