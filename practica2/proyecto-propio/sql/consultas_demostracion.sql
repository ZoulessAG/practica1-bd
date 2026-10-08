SELECT
    p.nss,
    p.nombre AS paciente,
    p.esta_vigente,
    c.fecha_programada AS cita_laboratorio,
    o.fecha_cita_doctor AS cita_doctor,
    (o.fecha_cita_doctor - CAST(c.fecha_programada AS DATE)) AS dias_anticipacion,
    e.nombre AS estudio_solicitado,
    c.asistio
FROM Paciente p
         JOIN CitaLaboratorio c ON p.nss = c.nss_paciente
         JOIN OrdenMedica o ON c.id_orden = o.id_orden
         JOIN Cita_Estudio ce ON c.id_cita = ce.id_cita
         JOIN Estudio e ON ce.id_estudio = e.id_estudio
WHERE p.nss = '1234567890';