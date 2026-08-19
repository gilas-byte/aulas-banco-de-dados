-- function 1 (situacao 1)

-- explicacao = Uma FUNCTION que recebe o ID de um programa e retorna a média aritmética das notas dadas pelos usuários na tabela de avaliações.

CREATE OR REPLACE FUNCTION fn_media_avaliacoes(p_id_programa INT)
RETURNS NUMERIC AS $$
DECLARE
    v_media NUMERIC;
BEGIN
    SELECT COALESCE(AVG(nota), 0) INTO v_media
    FROM AVALIACAO
    WHERE id_programa = p_id_programa;
    RETURN ROUND(v_media, 2);
END;
$$ LANGUAGE plpgsql;

-- teste function 1

SELECT fn_media_avaliacoes(1) AS media_breaking_bad;

-- function 2 (situacao 2)

-- explicacao = Uma FUNCTION que retorna uma tabela contendo o título e o ano dos programas vinculados a uma plataforma específica.

CREATE OR REPLACE FUNCTION fn_programas_por_plataforma(p_id_plataforma INT)
RETURNS TABLE (titulo VARCHAR, ano INT) AS $$
BEGIN
    RETURN QUERY
    SELECT p.titulo, p.ano
    FROM PROGRAMATV p
    INNER JOIN DISPONIBILIDADE d ON p.id_programa = d.id_programa
    WHERE d.id_plataforma = p_id_plataforma;
END;
$$ LANGUAGE plpgsql;

-- teste function 2

SELECT * FROM fn_programas_por_plataforma(1);

-- function 3 (situacao 3)

-- explicacao = Uma FUNCTION que concatena o nome do programa e o ano entre parênteses, ideal para gerar relatórios mais legíveis.

CREATE OR REPLACE FUNCTION fn_formatar_titulo(p_id_programa INT)
RETURNS VARCHAR AS $$
DECLARE
    v_resultado VARCHAR;
BEGIN
    SELECT titulo || ' (' || ano || ')' INTO v_resultado
    FROM PROGRAMATV
    WHERE id_programa = p_id_programa;
    RETURN v_resultado;
END;
$$ LANGUAGE plpgsql;

-- teste function 3

SELECT fn_formatar_titulo(2) AS titulo_formatado;

-- stored procedure 1 (situacao 4)

-- explicacao = Uma STORED PROCEDURE que insere um registro na tabela PROGRAMATV e já insere a respectiva ficha na tabela PROG_INFORMACOES, mantendo a integridade da relação.

CREATE OR REPLACE PROCEDURE sp_cadastrar_programa_completo(
    p_id_tipo INT, p_titulo VARCHAR, p_ano INT, 
    p_titulo_original VARCHAR, p_sinopse TEXT, p_id_pais INT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_novo_id INT;
BEGIN
    INSERT INTO PROGRAMATV (id_tipo, titulo, ano) 
    VALUES (p_id_tipo, p_titulo, p_ano) 
    RETURNING id_programa INTO v_novo_id;

    INSERT INTO PROG_INFORMACOES (id_programa, titulo_original, sinopse, id_pais)
    VALUES (v_novo_id, p_titulo_original, p_sinopse, p_id_pais);
    COMMIT;
END;
$$;

-- teste stored procedure 1

CALL sp_cadastrar_programa_completo(1, 'Peaky Blinders', 2013, 'Peaky Blinders', 'Gangue em Birmingham...', 3);

SELECT * FROM PROGRAMATV WHERE titulo = 'Peaky Blinders';

-- procedure 1 (situacao 5)

-- explicacao = Uma PROCEDURE para registrar a nota de um usuário. Se a nota não estiver entre 0 e 10, o banco lança uma exceção e impede a inserção.

CREATE OR REPLACE PROCEDURE sp_inserir_avaliacao(
    p_id_contato INT, p_id_programa INT, p_nota NUMERIC
)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_nota < 0 OR p_nota > 10 THEN
        RAISE EXCEPTION 'Erro: A nota deve estar entre 0 e 10.';
    END IF;
    INSERT INTO AVALIACAO (id_contato, id_programa, nota)
    VALUES (p_id_contato, p_id_programa, p_nota);
END;
$$;

-- teste procedure 1

CALL sp_inserir_avaliacao(2, 1, 9.0); -- Funciona

SELECT * FROM avaliacao;

CALL sp_inserir_avaliacao(1, 2, 11.5); -- Vai gerar erro

-- procedure 2 (situacao 6)

-- explicacao = PROCEDURE que atualiza a senha de um contato, exigindo que a nova senha tenha pelo menos 6 caracteres por segurança.

CREATE OR REPLACE PROCEDURE sp_atualizar_senha(
    p_id_contato INT, p_nova_senha VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    IF LENGTH(p_nova_senha) < 6 THEN
        RAISE EXCEPTION 'A senha deve ter no mínimo 6 caracteres.';
    END IF;
    UPDATE CONTATOS SET senha = p_nova_senha WHERE id_contato = p_id_contato;
END;
$$;

-- teste procedure 2

CALL sp_atualizar_senha(1, 'novasenhaForte');
SELECT nome, senha FROM CONTATOS WHERE id_contato = 1;

-- trigger 1 (situacao 7)

-- explicacao = Cria uma tabela de suporte e uma TRIGGER que grava um registro sempre que um programa é inserido ou deletado na tabela PROGRAMATV.

CREATE TABLE LOG_PROGRAMATV (
    id_log SERIAL PRIMARY KEY,
    id_programa INT,
    acao VARCHAR(50),
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION fn_log_programatv() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO LOG_PROGRAMATV (id_programa, acao) VALUES (NEW.id_programa, 'INSERÇÃO');
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO LOG_PROGRAMATV (id_programa, acao) VALUES (OLD.id_programa, 'EXCLUSÃO');
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_programatv
AFTER INSERT OR DELETE ON PROGRAMATV
FOR EACH ROW EXECUTE FUNCTION fn_log_programatv();

-- teste trigger 1

INSERT INTO PROGRAMATV (titulo, ano, id_tipo) VALUES ('Série Cancelada', 2024, 1);
DELETE FROM PROGRAMATV WHERE titulo = 'Série Cancelada';
SELECT * FROM LOG_PROGRAMATV;

-- trigger 2 (situacao 8)

-- explicacao = Uma TRIGGER disparada antes de inserir ou atualizar um CONTATOS, garantindo que o email inserido contenha o caractere @.

CREATE OR REPLACE FUNCTION fn_validar_email() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.email NOT LIKE '%@%' THEN
        RAISE EXCEPTION 'Email inválido. Faltou o @.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_email
BEFORE INSERT OR UPDATE ON CONTATOS
FOR EACH ROW EXECUTE FUNCTION fn_validar_email();

-- teste trigger 2

INSERT INTO CONTATOS (nome, email, senha) VALUES ('Teste', 'emailsemarroba', '123456'); -- Vai dar erro

-- trigger 3 (situacao 9)

-- explicacao = TRIGGER que bloqueia a exclusão de uma plataforma se ela já possuir algum programa vinculado na tabela DISPONIBILIDADE.

CREATE OR REPLACE FUNCTION fn_impedir_exclusao_plataforma() RETURNS TRIGGER AS $$
DECLARE
    v_qtd INT;
BEGIN
    SELECT COUNT(*) INTO v_qtd FROM DISPONIBILIDADE WHERE id_plataforma = OLD.id_plataforma;
    IF v_qtd > 0 THEN
        RAISE EXCEPTION 'Plataforma em uso. Exclusão bloqueada.';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_impedir_exclusao_plat
BEFORE DELETE ON PLATAFORMA
FOR EACH ROW EXECUTE FUNCTION fn_impedir_exclusao_plataforma();

-- teste trigger 3

DELETE FROM PLATAFORMA WHERE id_plataforma = 1; -- Vai dar erro pois a Netflix tem programas vinculados

-- trigger 4 (situacao 10)

-- explicacao = Adiciona uma coluna ultima_atualizacao no programa. A TRIGGER atualiza esse campo automaticamente com o horário do sistema toda vez que ocorre um UPDATE.

ALTER TABLE PROGRAMATV ADD COLUMN ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE OR REPLACE FUNCTION fn_atualizar_data() RETURNS TRIGGER AS $$
BEGIN
    NEW.ultima_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_atualiza_data_programa
BEFORE UPDATE ON PROGRAMATV
FOR EACH ROW EXECUTE FUNCTION fn_atualizar_data();

-- teste trigger 4

UPDATE PROGRAMATV SET ano = 2009 WHERE id_programa = 1;
SELECT titulo, ano, ultima_atualizacao FROM PROGRAMATV WHERE id_programa = 1;