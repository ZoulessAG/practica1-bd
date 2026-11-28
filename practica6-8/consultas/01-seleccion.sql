-- Consulta 1: Seleccion Simple (sigma)
-- Pregunta: ¿Cuales son los derechohabientes con vigencia de derechos activa en el sistema?
SELECT nss, nombre, unidad_medica_adscripcion
FROM paciente
WHERE estatus_vigencia = true;
