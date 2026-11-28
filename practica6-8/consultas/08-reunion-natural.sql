-- Consulta 8: Reunion Natural / Equi-Join (bowtie)
-- Pregunta: ¿Cual es el nombre del paciente y el medico emisor de cada orden medica expedida?
SELECT p.nss, p.nombre, o.folio_orden, o.medico_emisor, o.fecha_cita_medico
FROM paciente p
JOIN orden_medica o ON p.nss = o.nss_paciente;
