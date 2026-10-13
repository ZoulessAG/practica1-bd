-- ==============================================================================
-- Instituto Politécnico Nacional - Escuela Superior de Cómputo (ESCOM)
-- Práctica 3: Transformación del Modelo EER al Modelo Relacional
-- Proyecto Propio: Sistema de Citas Médicas y Laboratorio Clínico
-- Base de Datos: citas_medicas_p3 (PostgreSQL 15)
-- ==============================================================================

-- Limpieza en orden inverso de dependencias
DROP TABLE IF EXISTS resultado CASCADE;
DROP TABLE IF EXISTS prueba_fecal CASCADE;
DROP TABLE IF EXISTS prueba_orina CASCADE;
DROP TABLE IF EXISTS prueba_sangre CASCADE;
DROP TABLE IF EXISTS orden_estudio CASCADE;
DROP TABLE IF EXISTS cita CASCADE;
DROP TABLE IF EXISTS estudio CASCADE;
DROP TABLE IF EXISTS orden_medica CASCADE;
DROP TABLE IF EXISTS paciente_telefono CASCADE;
DROP TABLE IF EXISTS paciente CASCADE;

-- ------------------------------------------------------------------------------
-- 1. TABLA: paciente
-- Regla 1 (Entidad Fuerte) y Regla 4 (Relación Recursiva Titular-Beneficiario 1:N)
-- ------------------------------------------------------------------------------
CREATE TABLE paciente (
    nss VARCHAR(15) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    estatus_vigencia BOOLEAN NOT NULL DEFAULT TRUE,
    unidad_medica_adscripcion VARCHAR(100) NOT NULL,
    nss_titular VARCHAR(15),
    CONSTRAINT pk_paciente PRIMARY KEY (nss),
    CONSTRAINT fk_paciente_titular FOREIGN KEY (nss_titular)
        REFERENCES paciente (nss)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ------------------------------------------------------------------------------
-- 2. TABLA: paciente_telefono
-- Regla 3 (Atributo Multivaluado de Teléfonos)
-- ------------------------------------------------------------------------------
CREATE TABLE paciente_telefono (
    nss VARCHAR(15) NOT NULL,
    telefono VARCHAR(15) NOT NULL,
    CONSTRAINT pk_paciente_telefono PRIMARY KEY (nss, telefono),
    CONSTRAINT fk_telefono_paciente FOREIGN KEY (nss)
        REFERENCES paciente (nss)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_telefono_formato CHECK (LENGTH(telefono) >= 8)
);

-- ------------------------------------------------------------------------------
-- 3. TABLA: orden_medica
-- Regla 1 (Entidad Fuerte) y Regla 4 (Relación 1:N Presenta entre Paciente y Orden)
-- ------------------------------------------------------------------------------
CREATE TABLE orden_medica (
    folio_orden VARCHAR(20) NOT NULL,
    fecha_cita_medico DATE NOT NULL,
    medico_emisor VARCHAR(100) NOT NULL,
    nss_paciente VARCHAR(15) NOT NULL,
    CONSTRAINT pk_orden_medica PRIMARY KEY (folio_orden),
    CONSTRAINT fk_orden_paciente FOREIGN KEY (nss_paciente)
        REFERENCES paciente (nss)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ------------------------------------------------------------------------------
-- 4. TABLA: cita
-- Regla 1 (Entidad Fuerte) y Regla 6 (Relación 1:1 Genera con Orden Médica)
-- ------------------------------------------------------------------------------
CREATE TABLE cita (
    id_cita SERIAL NOT NULL,
    fecha_hora_agendamiento TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    fecha_hora_laboratorio TIMESTAMP WITH TIME ZONE NOT NULL,
    estatus_asistencia VARCHAR(20) DEFAULT 'PROGRAMADA' NOT NULL,
    folio_orden VARCHAR(20) NOT NULL,
    CONSTRAINT pk_cita PRIMARY KEY (id_cita),
    CONSTRAINT uq_cita_orden UNIQUE (folio_orden),
    CONSTRAINT fk_cita_orden FOREIGN KEY (folio_orden)
        REFERENCES orden_medica (folio_orden)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_estatus_asistencia CHECK (estatus_asistencia IN ('PROGRAMADA', 'CONFIRMADA', 'ASISTIO', 'CANCELADA', 'NO_ASISTIO')),
    CONSTRAINT chk_fechas_coherentes CHECK (fecha_hora_laboratorio >= fecha_hora_agendamiento)
);

-- ------------------------------------------------------------------------------
-- 5. TABLA: estudio (Supertipo)
-- Regla 1 (Entidad Fuerte) y Regla 9 (Jerarquía Estrategia A: Tabla por supertipo y por subtipo)
-- ------------------------------------------------------------------------------
CREATE TABLE estudio (
    id_estudio SERIAL NOT NULL,
    nombre_estudio VARCHAR(100) NOT NULL,
    indicaciones_previas TEXT,
    CONSTRAINT pk_estudio PRIMARY KEY (id_estudio),
    CONSTRAINT uq_nombre_estudio UNIQUE (nombre_estudio)
);

-- ------------------------------------------------------------------------------
-- 6. TABLA ASOCIATIVA: orden_estudio
-- Regla 5 (Relación N:M Contiene entre Orden Médica y Estudio)
-- ------------------------------------------------------------------------------
CREATE TABLE orden_estudio (
    folio_orden VARCHAR(20) NOT NULL,
    id_estudio INT NOT NULL,
    CONSTRAINT pk_orden_estudio PRIMARY KEY (folio_orden, id_estudio),
    CONSTRAINT fk_oe_orden FOREIGN KEY (folio_orden)
        REFERENCES orden_medica (folio_orden)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_oe_estudio FOREIGN KEY (id_estudio)
        REFERENCES estudio (id_estudio)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ------------------------------------------------------------------------------
-- 7. SUBTIPOS DE ESTUDIO (Regla 9 - Estrategia A)
-- ------------------------------------------------------------------------------
CREATE TABLE prueba_sangre (
    id_estudio INT NOT NULL,
    tipo_tubo VARCHAR(50) NOT NULL,
    color_tapon VARCHAR(30) NOT NULL,
    ayuno_horas INT NOT NULL DEFAULT 8,
    CONSTRAINT pk_prueba_sangre PRIMARY KEY (id_estudio),
    CONSTRAINT fk_sangre_estudio FOREIGN KEY (id_estudio)
        REFERENCES estudio (id_estudio)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_ayuno_horas CHECK (ayuno_horas >= 0 AND ayuno_horas <= 24)
);

CREATE TABLE prueba_orina (
    id_estudio INT NOT NULL,
    tipo_frasco VARCHAR(50) NOT NULL,
    volumen_minimo VARCHAR(30) NOT NULL,
    CONSTRAINT pk_prueba_orina PRIMARY KEY (id_estudio),
    CONSTRAINT fk_orina_estudio FOREIGN KEY (id_estudio)
        REFERENCES estudio (id_estudio)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE prueba_fecal (
    id_estudio INT NOT NULL,
    tipo_frasco VARCHAR(50) NOT NULL,
    requiere_medio_transporte BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_prueba_fecal PRIMARY KEY (id_estudio),
    CONSTRAINT fk_fecal_estudio FOREIGN KEY (id_estudio)
        REFERENCES estudio (id_estudio)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ------------------------------------------------------------------------------
-- 8. TABLA: resultado
-- Regla 1 (Entidad Fuerte), Regla 4 (Relación 1:N con Cita) y Relación con Estudio
-- ------------------------------------------------------------------------------
CREATE TABLE resultado (
    id_resultado SERIAL NOT NULL,
    valor_obtenido VARCHAR(100) NOT NULL,
    unidad_medida VARCHAR(30),
    rango_referencia VARCHAR(100),
    fecha_hora_emision TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    observaciones TEXT,
    id_cita INT NOT NULL,
    id_estudio INT NOT NULL,
    CONSTRAINT pk_resultado PRIMARY KEY (id_resultado),
    CONSTRAINT fk_resultado_cita FOREIGN KEY (id_cita)
        REFERENCES cita (id_cita)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_resultado_estudio FOREIGN KEY (id_estudio)
        REFERENCES estudio (id_estudio)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
