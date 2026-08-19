-- ===================================
-- Trigger 1
-- ===================================

-- 1. Criação da Função
CREATE OR REPLACE FUNCTION fn_busca_preco_produto()
RETURNS TRIGGER AS $$
BEGIN
    -- Busca o valor do produto na tabela produto e joga na nova linha do carrinho
    SELECT valor_unitario INTO NEW.valor_unitario
    FROM produto
    WHERE id_produto = NEW.fk_id_produto;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Criação do Gatilho
DROP TRIGGER IF EXISTS trg_busca_preco ON carrinho_venda;
CREATE TRIGGER trg_busca_preco
BEFORE INSERT ON carrinho_venda
FOR EACH ROW
EXECUTE FUNCTION fn_busca_preco_produto();

-- ===================================
-- Trigger 2
-- ===================================

-- 1. Criação da Função
CREATE OR REPLACE FUNCTION fn_bloqueia_venda_finalizada()
RETURNS TRIGGER AS $$
DECLARE
    v_status VARCHAR;
    v_id_venda INT;
BEGIN
    -- Pega o ID da venda (OLD para DELETE, NEW para INSERT/UPDATE)
    v_id_venda := COALESCE(NEW.fk_id_venda, OLD.fk_id_venda);

    -- Busca o status atual da venda
    SELECT status INTO v_status
    FROM venda
    WHERE id_venda = v_id_venda;

    -- Regra de bloqueio
    IF v_status = 'Finalizada' THEN
        RAISE EXCEPTION 'Ação bloqueada: Não é possível modificar o carrinho de uma venda com status Finalizada.';
    END IF;

    -- Retorna o registro adequado
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 2. Criação do Gatilho
DROP TRIGGER IF EXISTS trg_bloqueia_alteracao_item ON carrinho_venda;
CREATE TRIGGER trg_bloqueia_alteracao_item
BEFORE INSERT OR UPDATE OR DELETE ON carrinho_venda
FOR EACH ROW
EXECUTE FUNCTION fn_bloqueia_venda_finalizada();

-- ===================================
-- Trigger 3
-- ===================================

-- 1. Criação da tabela de Log (Com os mesmos atributos da tabela Venda do seu script)
CREATE TABLE IF NOT EXISTS log_venda (
    id_log_venda SERIAL PRIMARY KEY,
    id_venda INT,
    data_venda DATE,
    numero VARCHAR(60), 
    sub_total DECIMAL(15,2),
    desconto DECIMAL(15,2), 
    total_impostos DECIMAL(15,2),
    fk_id_cliente INT,
    status VARCHAR(20),
    operacao CHAR(1) CHECK (operacao IN ('i', 'u', 'd')),
    data_hora_log TIMESTAMP NOT NULL
);

-- 2. Criação da Função
CREATE OR REPLACE FUNCTION fn_registrar_log_venda()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO log_venda (id_venda, data_venda, numero, sub_total, desconto, total_impostos, fk_id_cliente, status, operacao, data_hora_log)
        VALUES (NEW.id_venda, NEW.data_venda, NEW.numero, NEW.sub_total, NEW.desconto, NEW.total_impostos, NEW.fk_id_cliente, NEW.status, 'i', CURRENT_TIMESTAMP);
        RETURN NEW;
        
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO log_venda (id_venda, data_venda, numero, sub_total, desconto, total_impostos, fk_id_cliente, status, operacao, data_hora_log)
        VALUES (NEW.id_venda, NEW.data_venda, NEW.numero, NEW.sub_total, NEW.desconto, NEW.total_impostos, NEW.fk_id_cliente, NEW.status, 'u', CURRENT_TIMESTAMP);
        RETURN NEW;
        
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO log_venda (id_venda, data_venda, numero, sub_total, desconto, total_impostos, fk_id_cliente, status, operacao, data_hora_log)
        VALUES (OLD.id_venda, OLD.data_venda, OLD.numero, OLD.sub_total, OLD.desconto, OLD.total_impostos, OLD.fk_id_cliente, OLD.status, 'd', CURRENT_TIMESTAMP);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 3. Criação do Gatilho
DROP TRIGGER IF EXISTS trg_auditoria_venda ON venda;
CREATE TRIGGER trg_auditoria_venda
AFTER INSERT OR UPDATE OR DELETE ON venda
FOR EACH ROW
EXECUTE FUNCTION fn_registrar_log_venda();

-- ===================================
-- Consultas
-- ===================================

-- Trigger 1

-- 1. Dando um preço de verdade para o produto 10 na tabela produto
UPDATE produto SET valor_unitario = 1299.90 WHERE id_produto = 10;

-- 2. Apagando aquele item com preço NULL que a gente inseriu antes no carrinho
DELETE FROM carrinho_venda WHERE fk_id_venda = 1 AND fk_id_produto = 10;

-- 3. Rodando o teste do Trigger
INSERT INTO carrinho_venda (fk_id_venda, fk_id_produto, quantidade, percentual_impostos)
VALUES (1, 10, 5, 10.00);

-- 4. Dando o SELECT
SELECT fk_id_venda, fk_id_produto, quantidade, valor_unitario 
FROM carrinho_venda 
WHERE fk_id_venda = 1 AND fk_id_produto = 10;

-- Trigger 2

-- Finalizando a venda 2
UPDATE venda SET status = 'Finalizada' WHERE id_venda = 2;

-- Tentando inserir um item na venda 2 (Deve gerar um erro na tela)
INSERT INTO carrinho_venda (fk_id_venda, fk_id_produto, quantidade, percentual_impostos)
VALUES (2, 1, 1, 5.00);

-- Trigger 3

-- Criando uma venda nova (Gera operação 'i' no log)
INSERT INTO venda (id_venda, data_venda, fk_id_cliente, status, desconto) 
VALUES (999, '2026-04-06', 1, 'Em Andamento', 0.00);

-- Atualizando a venda nova (Gera operação 'u' no log)
UPDATE venda SET desconto = 50.00 WHERE id_venda = 999;

-- Deletando a venda nova (Gera operação 'd' no log)
DELETE FROM venda WHERE id_venda = 999;

-- Vendo o histórico completo na tabela de log
SELECT id_venda, status, desconto, operacao, data_hora_log 
FROM log_venda 
WHERE id_venda = 999;