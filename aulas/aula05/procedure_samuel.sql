ALTER TABLE venda ADD COLUMN status VARCHAR(20) DEFAULT 'Em Andamento';

UPDATE produto SET valor_unitario = 4999.99 WHERE id_produto = 1;
UPDATE produto SET valor_unitario = 3999.90 WHERE id_produto = 2;
UPDATE produto SET valor_unitario = 1200.99 WHERE id_produto = 8;

-- Colocando valores fictícios nas vendas do Cliente 1 (Carlos Silva)
UPDATE venda SET sub_total = 4500.00 WHERE id_venda = 1;
UPDATE venda SET sub_total = 1500.00 WHERE id_venda = 11;
UPDATE venda SET sub_total = 3000.00 WHERE id_venda = 12;

-- 1

CREATE OR REPLACE FUNCTION fn_total_carrinho_venda(p_id_venda INT)
RETURNS DECIMAL(15,2) AS $$
DECLARE
    v_total DECIMAL(15,2);
BEGIN
    SELECT SUM(quantidade * valor_unitario) INTO v_total
    FROM carrinho_venda 
    WHERE fk_id_venda = p_id_venda;
    
    RETURN COALESCE(v_total, 0.00);
END;
$$ LANGUAGE plpgsql;

-- 2

CREATE OR REPLACE FUNCTION fn_media_vendas_cliente(p_id_cliente INT)
RETURNS DECIMAL(15,2) AS $$
DECLARE
    v_media DECIMAL(15,2);
BEGIN
    SELECT AVG(sub_total) INTO v_media
    FROM venda 
    WHERE fk_id_cliente = p_id_cliente;
    
    RETURN COALESCE(v_media, 0.00);
END;
$$ LANGUAGE plpgsql;

-- 3

CREATE OR REPLACE FUNCTION fn_produtos_por_faixa_preco(p_min DECIMAL, p_max DECIMAL)
RETURNS TABLE (id_produto INT, nome_produto VARCHAR, valor DECIMAL) AS $$
BEGIN
    RETURN QUERY 
    SELECT p.id_produto, p.nome, p.valor_unitario
    FROM produto p 
    WHERE p.valor_unitario BETWEEN p_min AND p_max;
END;
$$ LANGUAGE plpgsql;

-- 4

CREATE OR REPLACE FUNCTION fn_vendas_por_periodo(p_data_inicio DATE, p_data_fim DATE)
RETURNS TABLE (id_venda INT, data_venda DATE, nome_cliente VARCHAR, valor_venda DECIMAL) AS $$
BEGIN
    RETURN QUERY 
    SELECT v.id_venda, v.data_venda, c.nome, v.sub_total
    FROM venda v 
    INNER JOIN cliente c ON v.fk_id_cliente = c.id_cliente
    WHERE v.data_venda BETWEEN p_data_inicio AND p_data_fim;
END;
$$ LANGUAGE plpgsql;

-- 5

-- trigger usado

-- 1. Criação da Função do Trigger 1
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

-- 2. Criação do Gatilho 1 na tabela carrinho_venda
DROP TRIGGER IF EXISTS trg_busca_preco ON carrinho_venda;
CREATE TRIGGER trg_busca_preco
BEFORE INSERT ON carrinho_venda
FOR EACH ROW
EXECUTE FUNCTION fn_busca_preco_produto();

-- procedure usado

CREATE OR REPLACE PROCEDURE sp_finalizar_venda(p_id_venda INT)
LANGUAGE plpgsql AS $$
DECLARE 
    v_qtd_itens INT;
BEGIN
    -- Conta quantos itens tem no carrinho desta venda
    SELECT COUNT(*) INTO v_qtd_itens FROM carrinho_venda WHERE fk_id_venda = p_id_venda;
    
    IF v_qtd_itens > 0 THEN
        UPDATE venda SET status = 'Finalizada' WHERE id_venda = p_id_venda;
        RAISE NOTICE 'Venda % finalizada! O Trigger 2 agora bloqueia alterações no carrinho.', p_id_venda;
    ELSE
        RAISE EXCEPTION 'Aperfeiçoamento ativo: Não é possível finalizar a venda %. O carrinho está vazio.', p_id_venda;
    END IF;
END;
$$;

-- 6

-- trigger usado

-- 1. Criação da Função do Trigger 2
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

-- 2. Criação do Gatilho 2 na tabela carrinho_venda
DROP TRIGGER IF EXISTS trg_bloqueia_alteracao_item ON carrinho_venda;
CREATE TRIGGER trg_bloqueia_alteracao_item
BEFORE INSERT OR UPDATE OR DELETE ON carrinho_venda
FOR EACH ROW
EXECUTE FUNCTION fn_bloqueia_venda_finalizada();

-- procedure usado

CREATE OR REPLACE PROCEDURE sp_atualizar_totais_venda(p_id_venda INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_subtotal DECIMAL(15,2);
BEGIN
    -- Soma os valores que foram inseridos no carrinho
    SELECT SUM(quantidade * valor_unitario) INTO v_subtotal
    FROM carrinho_venda WHERE fk_id_venda = p_id_venda;

    -- Atualiza a tabela principal
    UPDATE venda SET sub_total = COALESCE(v_subtotal, 0.00) WHERE id_venda = p_id_venda;
    
    RAISE NOTICE 'Totais da venda % consolidados com sucesso a partir do carrinho.', p_id_venda;
END;
$$;

-- testes

-- Teste Func 1: Qual o valor total somado dentro do carrinho da venda 1?
SELECT fn_total_carrinho_venda(1);

-- Teste Func 2: Qual a média de gastos (Ticket Médio) do cliente 1?
SELECT fn_media_vendas_cliente(1);

-- Teste Func 3: Mostrar produtos que custam entre 1000 e 5000 reais
SELECT * FROM fn_produtos_por_faixa_preco(1000.00, 5000.00);

-- Teste Func 4: Mostrar as vendas feitas em Fevereiro e Março de 2025, com o nome do cliente
SELECT * FROM fn_vendas_por_periodo('2025-02-01', '2025-03-31');

-- 1. PREPARAÇÃO: Garantir que a venda 1 está "Em Andamento"
UPDATE venda SET status = 'Em Andamento' WHERE id_venda = 1;

-- 2. O ANTES (Tire print daqui!): Mostra o status atual da venda
SELECT id_venda, status 
FROM venda 
WHERE id_venda = 1;

-- 3. A AÇÃO: Chama a procedure para finalizar a venda (já que ela tem itens no carrinho)
CALL sp_finalizar_venda(1);

-- 4. O DEPOIS (Tire print daqui!): Mostra que o status mudou para 'Finalizada'
SELECT id_venda, status 
FROM venda 
WHERE id_venda = 1;

-- 5. O BÔNUS (Tire print do erro!): Tenta colocar um produto no carrinho da venda 1
-- O banco vai estourar o erro vermelho na tela provando que o Trigger 2 está protegendo a venda!
INSERT INTO carrinho_venda (fk_id_venda, fk_id_produto, quantidade, valor_unitario, percentual_impostos) 
VALUES (1, 10, 1, 1500.00, 10.00);

-- 1. PREPARAÇÃO: Zerar o sub_total da venda 2 para mostrar a mágica acontecendo
UPDATE venda SET sub_total = 0.00 WHERE id_venda = 2;

-- 2. O ANTES PARTE 1 (Tire print!): Mostra que a venda 2 está com o valor zerado na tabela principal
SELECT id_venda, sub_total 
FROM venda 
WHERE id_venda = 2;

-- 3. O ANTES PARTE 2 (Tire print!): Mostra que o carrinho da venda 2 tem itens e valores
SELECT fk_id_produto, quantidade, valor_unitario, (quantidade * valor_unitario) as total_do_item
FROM carrinho_venda 
WHERE fk_id_venda = 2;

-- 4. A AÇÃO: Executa a procedure que vai somar o carrinho e atualizar a venda
CALL sp_atualizar_totais_venda(2);

-- 5. O DEPOIS (Tire print!): Mostra que o sub_total da venda 2 foi atualizado com a soma exata dos itens!
SELECT id_venda, sub_total 
FROM venda 
WHERE id_venda = 2;