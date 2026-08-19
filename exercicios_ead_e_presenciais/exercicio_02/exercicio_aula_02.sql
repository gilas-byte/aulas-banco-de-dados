-- Limpa o banco caso precise rodar o script novamente
DROP TABLE IF EXISTS plano_ativ, aula_capacidade, plano_aula, plano_prof, plano_ensino, unidade_curricular, atividade, capacidade, professor, curso CASCADE;

-- Tabelas Independentes (Sem Chaves Estrangeiras)
CREATE TABLE curso (
    id_curso SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    objetivo TEXT
);

CREATE TABLE professor (
    id_professor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    matricula VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE capacidade (
    id_capacidade SERIAL PRIMARY KEY,
    descricao TEXT NOT NULL,
    tipo VARCHAR(50)
);

CREATE TABLE atividade (
    id_atividade SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

-- Tabelas Dependentes Nível 1
CREATE TABLE unidade_curricular (
    id_uc SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    ano INT,
    semestre INT,
    funcao VARCHAR(100),
    id_curso INT REFERENCES curso(id_curso)
);

-- Tabelas Dependentes Nível 2
CREATE TABLE plano_ensino (
    id_plano_ensino SERIAL PRIMARY KEY,
    ano INT,
    semestre INT,
    cod_turma VARCHAR(20),
    id_uc INT REFERENCES unidade_curricular(id_uc)
);

-- Tabelas Dependentes Nível 3 (Incluindo Associativas)
CREATE TABLE plano_prof (
    id_plano_ensino INT REFERENCES plano_ensino(id_plano_ensino),
    id_professor INT REFERENCES professor(id_professor),
    PRIMARY KEY (id_plano_ensino, id_professor)
);

CREATE TABLE plano_aula (
    id_plano_aula SERIAL PRIMARY KEY,
    data DATE,
    descricao TEXT,
    avaliacao NUMERIC(5,2), -- Usado para funções de agregação depois
    id_plano_ensino INT REFERENCES plano_ensino(id_plano_ensino)
);

-- Tabelas Dependentes Nível 4 (Associativas do Plano de Aula)
CREATE TABLE aula_capacidade (
    id_plano_aula INT REFERENCES plano_aula(id_plano_aula),
    id_capacidade INT REFERENCES capacidade(id_capacidade),
    PRIMARY KEY (id_plano_aula, id_capacidade)
);

CREATE TABLE plano_ativ (
    id_plano_aula INT REFERENCES plano_aula(id_plano_aula),
    id_atividade INT REFERENCES atividade(id_atividade),
    PRIMARY KEY (id_plano_aula, id_atividade)
);

-- ==================================================
-- Inserção de Dados
-- ==================================================

INSERT INTO curso (nome, objetivo) VALUES 
('Ciência da Computação', 'Formar desenvolvedores'), ('Engenharia de Software', 'Gestão de projetos'), ('Sistemas de Informação', 'Foco corporativo'), ('Análise e Desenv. de Sistemas', 'Foco prático'), ('Engenharia de Dados', 'Tratar grandes volumes'), ('Inteligência Artificial', 'Modelos preditivos');

INSERT INTO professor (nome, matricula) VALUES 
('Alan Turing', 'MAT001'), ('Ada Lovelace', 'MAT002'), ('Linus Torvalds', 'MAT003'), ('Grace Hopper', 'MAT004'), ('Tim Berners-Lee', 'MAT005'), ('Margaret Hamilton', 'MAT006');

INSERT INTO capacidade (descricao, tipo) VALUES 
('Lógica de Programação', 'Técnica'), ('Comunicação Assertiva', 'Soft Skill'), ('Modelagem de Dados', 'Técnica'), ('Gestão de Tempo', 'Soft Skill'), ('Desenvolvimento Web', 'Técnica'), ('Administração Linux', 'Técnica');

INSERT INTO atividade (nome) VALUES 
('Lista de Exercícios'), ('Prova Escrita'), ('Apresentação de Seminário'), ('Projeto Prático'), ('Discussão em Grupo'), ('Laboratório de Código');

INSERT INTO unidade_curricular (nome, ano, semestre, funcao, id_curso) VALUES 
('Algoritmos', 2024, 1, 'Base', 1), ('Banco de Dados', 2024, 2, 'Específica', 1), ('Engenharia de Requisitos', 2024, 1, 'Base', 2), ('Redes de Computadores', 2025, 1, 'Específica', 3), ('Sistemas Operacionais', 2025, 2, 'Específica', 1), ('Estrutura de Dados', 2024, 2, 'Base', 4);

INSERT INTO plano_ensino (ano, semestre, cod_turma, id_uc) VALUES 
(2024, 1, 'T01', 1), (2024, 2, 'T02', 2), (2024, 1, 'T03', 3), (2025, 1, 'T04', 4), (2025, 2, 'T05', 5), (2024, 2, 'T06', 6);

INSERT INTO plano_aula (data, descricao, avaliacao, id_plano_ensino) VALUES 
('2024-03-01', 'Introdução à Lógica', 8.5, 1), ('2024-03-08', 'Estruturas Condicionais', 9.0, 1), ('2024-08-10', 'Modelo Relacional', 7.5, 2), ('2024-08-17', 'Comandos SQL', 10.0, 2), ('2024-03-05', 'Levantamento de Requisitos', 8.0, 3), ('2025-03-10', 'Modelo OSI', 6.5, 4);

-- Inserindo > 15 nas tabelas associativas (plano_prof, aula_capacidade, plano_ativ)
INSERT INTO plano_prof (id_plano_ensino, id_professor) VALUES 
(1,1), (1,2), (2,3), (2,4), (3,5), (3,6), (4,1), (4,3), (5,2), (5,4), (6,5), (6,1), (1,3), (2,5), (3,1), (4,2);

INSERT INTO aula_capacidade (id_plano_aula, id_capacidade) VALUES 
(1,1), (1,2), (2,1), (2,3), (3,3), (3,4), (4,5), (4,6), (5,2), (5,4), (6,1), (6,6), (1,3), (2,4), (3,5), (4,1);

INSERT INTO plano_ativ (id_plano_aula, id_atividade) VALUES 
(1,1), (1,6), (2,1), (2,4), (3,2), (3,5), (4,4), (4,6), (5,3), (5,5), (6,2), (6,4), (1,2), (2,2), (3,1), (4,1);

-- ==================================================
-- Consultas de Verificação
-- ================================================== 

-- consulta 1
SELECT nome, matricula FROM professor WHERE nome ILIKE '%a%';

-- consulta 2
SELECT descricao, avaliacao FROM plano_aula WHERE avaliacao >= 8.0 AND avaliacao < 10.0;

--consulta 3
SELECT nome, ano, semestre FROM unidade_curricular WHERE ano BETWEEN 2024 AND 2025;

-- consulta 4
SELECT descricao, tipo FROM capacidade WHERE tipo IN ('Técnica', 'Soft Skill');

-- consulta 5
SELECT c.nome AS curso, uc.nome AS disciplina 
FROM curso c 
JOIN unidade_curricular uc ON c.id_curso = uc.id_curso;

-- consulta 6
SELECT descricao, avaliacao FROM plano_aula ORDER BY avaliacao DESC LIMIT 3;

-- consulta 7
SELECT id_curso, COUNT(*) AS total_disciplinas 
FROM unidade_curricular 
GROUP BY id_curso;

-- consulta 8
SELECT AVG(avaliacao) AS media_geral_avaliacoes FROM plano_aula;

-- consulta 9
SELECT SUM(avaliacao) AS soma_total_notas FROM plano_aula;

-- consulta 10
SELECT id_plano_ensino, COUNT(id_professor) AS total_professores 
FROM plano_prof 
GROUP BY id_plano_ensino 
HAVING COUNT(id_professor) > 2;

-- consulta 11
SELECT nome FROM curso c 
WHERE EXISTS (
    SELECT 1 FROM unidade_curricular uc WHERE uc.id_curso = c.id_curso
);

-- consulta 12
SELECT p.nome, pe.cod_turma, pe.ano 
FROM professor p
JOIN plano_prof pp ON p.id_professor = pp.id_professor
JOIN plano_ensino pe ON pp.id_plano_ensino = pe.id_plano_ensino;

-- consulta 13
SELECT cod_turma, ano, semestre FROM plano_ensino 
WHERE ano = 2024 OR (semestre = 2 AND cod_turma = 'T05');

-- consulta 14
SELECT pa.descricao, COUNT(ac.id_capacidade) AS qtd_capacidades
FROM plano_aula pa
JOIN aula_capacidade ac ON pa.id_plano_aula = ac.id_plano_aula
GROUP BY pa.descricao;

-- consulta 15
SELECT pe.cod_turma, AVG(pa.avaliacao) AS media_aula
FROM plano_ensino pe
JOIN plano_aula pa ON pe.id_plano_ensino = pa.id_plano_ensino
WHERE pe.ano = 2024
GROUP BY pe.cod_turma
HAVING AVG(pa.avaliacao) > 7.0
ORDER BY media_aula DESC;