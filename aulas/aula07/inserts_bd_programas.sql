-- Inserindo dados básicos
INSERT INTO PAIS (nome) VALUES ('Estados Unidos'), ('Brasil'), ('Reino Unido');
INSERT INTO TIPO (nome) VALUES ('Série'), ('Filme'), ('Documentário');
INSERT INTO GENERO (nome) VALUES ('Drama'), ('Comédia'), ('Ação');
INSERT INTO PLATAFORMA (nome) VALUES ('Netflix'), ('Prime Video'), ('Max');

-- Inserindo contatos
INSERT INTO CONTATOS (nome, email, senha) VALUES 
('João Silva', 'joao@email.com', 'senha123'),
('Maria Souza', 'maria@email.com', 'senha456');

-- Inserindo atores
INSERT INTO ATOR (nome, id_pais) VALUES 
('Bryan Cranston', 1), ('Wagner Moura', 2), ('Cillian Murphy', 3);

-- Inserindo programas
INSERT INTO PROGRAMATV (titulo, ano, id_tipo) VALUES 
('Breaking Bad', 2008, 1),
('Tropa de Elite', 2007, 2);

-- Inserindo informações, disponibilidade e elenco
INSERT INTO PROG_INFORMACOES (id_programa, titulo_original, sinopse, id_pais) VALUES 
(1, 'Breaking Bad', 'Professor de química vira produtor de metanfetamina.', 1),
(2, 'Tropa de Elite', 'Dia a dia do BOPE no Rio de Janeiro.', 2);

INSERT INTO DISPONIBILIDADE (id_programa, id_plataforma) VALUES (1, 1), (2, 2);
INSERT INTO PRO_ELENCO (id_ator, id_programa, chk_ator) VALUES (1, 1, TRUE), (2, 2, TRUE);
INSERT INTO AVALIACAO (id_contato, id_programa, nota) VALUES (1, 1, 9.5), (2, 2, 8.0);