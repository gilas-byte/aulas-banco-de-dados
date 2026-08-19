-- ===========================================================================
-- 1. TABELAS INDEPENDENTES (Sem chaves estrangeiras)
-- ===========================================================================

CREATE TABLE PAIS (
    id_pais SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE TIPO (
    id_tipo SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

CREATE TABLE GENERO (
    id_genero SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

CREATE TABLE PLATAFORMA (
    id_plataforma SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE CONTATOS (
    id_contato SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL
);

-- ===========================================================================
-- 2. TABELAS DEPENDENTES (Com chaves estrangeiras simples)
-- ===========================================================================

-- ATOR depende de PAIS (Relacionamento Origem)
CREATE TABLE ATOR (
    id_ator SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    id_pais INT NOT NULL,
    CONSTRAINT fk_ator_pais FOREIGN KEY (id_pais) REFERENCES PAIS(id_pais) ON DELETE RESTRICT
);

-- PROGRAMATV depende de TIPO (Relacionamento Classificado)
CREATE TABLE PROGRAMATV (
    id_programa SERIAL PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    ano INT NOT NULL,
    id_tipo INT NOT NULL,
    CONSTRAINT fk_programatv_tipo FOREIGN KEY (id_tipo) REFERENCES TIPO(id_tipo) ON DELETE RESTRICT
);

-- PROG_INFORMACOES depende de PROGRAMATV (Possui 1:1) e PAIS (Origem)
CREATE TABLE PROG_INFORMACOES (
    id_prog_inf SERIAL PRIMARY KEY,
    titulo_original VARCHAR(150),
    sinopse TEXT,
    id_programa INT UNIQUE NOT NULL,
    id_pais INT NOT NULL,
    CONSTRAINT fk_prog_inf_programa FOREIGN KEY (id_programa) REFERENCES PROGRAMATV(id_programa) ON DELETE CASCADE,
    CONSTRAINT fk_prog_inf_pais FOREIGN KEY (id_pais) REFERENCES PAIS(id_pais) ON DELETE RESTRICT
);

-- ===========================================================================
-- 3. TABELAS ASSOCIATIVAS (Relacionamentos Muitos-para-Muitos)
-- ===========================================================================

-- AVALIACAO une CONTATOS e PROGRAMATV (Contém o atributo nota)
CREATE TABLE AVALIACAO (
    id_contato INT,
    id_programa INT,
    nota NUMERIC(3,1) NOT NULL,
    PRIMARY KEY (id_contato, id_programa),
    CONSTRAINT fk_avaliacao_contato FOREIGN KEY (id_contato) REFERENCES CONTATOS(id_contato) ON DELETE CASCADE,
    CONSTRAINT fk_avaliacao_programa FOREIGN KEY (id_programa) REFERENCES PROGRAMATV(id_programa) ON DELETE CASCADE
);

-- PRO_ELENCO une ATOR e PROGRAMATV (Contém atributos chk_ator e chk_diretor)
CREATE TABLE PRO_ELENCO (
    id_ator INT,
    id_programa INT,
    chk_ator BOOLEAN DEFAULT FALSE,
    chk_diretor BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (id_ator, id_programa),
    CONSTRAINT fk_elenco_ator FOREIGN KEY (id_ator) REFERENCES ATOR(id_ator) ON DELETE CASCADE,
    CONSTRAINT fk_elenco_programa FOREIGN KEY (id_programa) REFERENCES PROGRAMATV(id_programa) ON DELETE CASCADE
);

-- PROG_GENERO (Pertence) une PROGRAMATV e GENERO
CREATE TABLE PROG_GENERO (
    id_programa INT,
    id_genero INT,
    PRIMARY KEY (id_programa, id_genero),
    CONSTRAINT fk_prog_genero_programa FOREIGN KEY (id_programa) REFERENCES PROGRAMATV(id_programa) ON DELETE CASCADE,
    CONSTRAINT fk_prog_genero_genero FOREIGN KEY (id_genero) REFERENCES GENERO(id_genero) ON DELETE CASCADE
);

-- DISPONIBILIDADE (Disponível) une PROGRAMATV e PLATAFORMA
CREATE TABLE DISPONIBILIDADE (
    id_programa INT,
    id_plataforma INT,
    PRIMARY KEY (id_programa, id_plataforma),
    CONSTRAINT fk_disponibilidade_programa FOREIGN KEY (id_programa) REFERENCES PROGRAMATV(id_programa) ON DELETE CASCADE,
    CONSTRAINT fk_disponibilidade_plataforma FOREIGN KEY (id_plataforma) REFERENCES PLATAFORMA(id_plataforma) ON DELETE CASCADE
);