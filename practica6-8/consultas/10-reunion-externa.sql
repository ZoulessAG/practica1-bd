-- Consulta 10: Reunion Externa Izquierda (LEFT OUTER JOIN)
-- Pregunta: ¿Cuales son todos los pacientes y sus telefonos, preservando a los pacientes que no tienen telefono registrado?
SELECT p.nss, p.nombre, COALESCE(t.telefono, 'SIN TELEFONO REGISTRADO') AS telefono
FROM paciente p
LEFT JOIN paciente_telefono t ON p.nss = t.nss;
