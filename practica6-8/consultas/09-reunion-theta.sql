-- Consulta 9: Reunion Theta con condicion de desigualdad (bowtie_theta)
-- Pregunta: ¿Que pares de estudios sanguineos tienen horas de ayuno distintas, comparando el mas exigente contra el menor?
SELECT s1.id_estudio AS estudio_mayor_ayuno, s1.ayuno_horas AS ayuno_a,
       s2.id_estudio AS estudio_menor_ayuno, s2.ayuno_horas AS ayuno_b
FROM prueba_sangre s1
JOIN prueba_sangre s2 ON s1.ayuno_horas > s2.ayuno_horas;
