-- Consulta 4: Union de Conjuntos (Compatibilidad de Union)
-- Pregunta: ¿Cuales son todos los identificadores NSS que fungen como titulares o beneficiarios?
SELECT nss, nombre, 'TITULAR' AS tipo_derechohabiente
FROM paciente
WHERE nss_titular IS NULL
UNION
SELECT nss, nombre, 'BENEFICIARIO' AS tipo_derechohabiente
FROM paciente
WHERE nss_titular IS NOT NULL;
