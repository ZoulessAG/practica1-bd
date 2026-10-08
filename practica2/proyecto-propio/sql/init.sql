CREATE TABLE Paciente (
                          nss VARCHAR(15) PRIMARY KEY,
                          nombre VARCHAR(100) NOT NULL,
                          esta_vigente BOOLEAN DEFAULT TRUE,
                          unidad_medica VARCHAR(50) NOT NULL,
                          nucleo_familiar VARCHAR(50),
                          telefono VARCHAR(15)
);

CREATE TABLE Medico (
                        id_medico SERIAL PRIMARY KEY,
                        nombre VARCHAR(100) NOT NULL,
                        especialidad VARCHAR(50) NOT NULL
);

CREATE TABLE OrdenMedica (
                             id_orden SERIAL PRIMARY KEY,
                             nss_paciente VARCHAR(15) REFERENCES Paciente(nss),
                             id_medico INT REFERENCES Medico(id_medico),
                             fecha_cita_doctor DATE NOT NULL
);

CREATE TABLE Estudio (
                         id_estudio SERIAL PRIMARY KEY,
                         nombre VARCHAR(100) NOT NULL
);

CREATE TABLE CitaLaboratorio (
                                 id_cita SERIAL PRIMARY KEY,
                                 nss_paciente VARCHAR(15) REFERENCES Paciente(nss),
                                 id_orden INT REFERENCES OrdenMedica(id_orden),
                                 fecha_agendamiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                 fecha_programada TIMESTAMP NOT NULL,
                                 asistio BOOLEAN DEFAULT FALSE
);

CREATE TABLE Cita_Estudio (
                              id_cita INT REFERENCES CitaLaboratorio(id_cita),
                              id_estudio INT REFERENCES Estudio(id_estudio),
                              PRIMARY KEY (id_cita, id_estudio)
);

INSERT INTO Paciente VALUES ('1234567890', 'Juan Perez Lopez', TRUE, 'UMF 20', 'Esposa e Hijos', '5551234567');
INSERT INTO Medico VALUES (1, 'Dr. Roberto Gomez', 'Medicina General');
INSERT INTO OrdenMedica VALUES (101, '1234567890', 1, '2026-11-15');
INSERT INTO Estudio VALUES (1, 'Biometria Hematica'), (2, 'Examen General de Orina');
INSERT INTO CitaLaboratorio VALUES (1001, '1234567890', 101, '2026-10-01 08:30:00', '2026-10-25 07:00:00', TRUE);
INSERT INTO Cita_Estudio VALUES (1001, 1), (1001, 2);