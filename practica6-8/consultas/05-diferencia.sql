-- Consulta 5: Diferencia de Conjuntos (-)
-- Pregunta: ¿Que derechohabientes registrados no tienen ningun numero telefonico de contacto?
SELECT nss, nombre
FROM paciente
EXCEPT
SELECT p.nss, p.nombre
FROM paciente p
JOIN paciente_telefono t ON p.nss = t.nss;
