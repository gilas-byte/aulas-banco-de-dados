-- alterando alguns dados para testar as funções e procedures criadas

UPDATE produto
SET quantidade_atual = 50,
    valor_unitario = 4999.99,
    percentual_impostos = 15.00
WHERE id_produto = 1;

UPDATE venda SET sub_total = 8999.89, total_impostos = 899.98 WHERE id_venda = 1;
UPDATE venda SET sub_total = 3299.99, total_impostos = 329.99 WHERE id_venda = 11;
UPDATE venda SET sub_total = 4500.00, total_impostos = 450.00 WHERE id_venda = 12;
UPDATE venda SET sub_total = 1599.99, total_impostos = 159.99 WHERE id_venda = 14;
UPDATE venda SET sub_total = 3200.50, total_impostos = 320.05 WHERE id_venda = 15;
UPDATE venda SET sub_total = 1199.99, total_impostos = 119.99 WHERE id_venda = 17;

-- Deixando o estoque do produto 1 no vermelho
UPDATE produto 
SET quantidade_atual = 5, quantidade_minima = 20 
WHERE id_produto = 1;

-- Deixando o estoque do produto 10 no vermelho também
UPDATE produto 
SET quantidade_atual = 2, quantidade_minima = 20 
WHERE id_produto = 10;

ALTER TABLE venda ADD COLUMN status VARCHAR(20) DEFAULT 'Em Andamento'; -- adicionar status para teste do trigger

-- 1

CREATE OR REPLACE FUNCTION fn_calc_valor_estoque(p_id_produto INT)
RETURNS DECIMAL(15,2) AS $$
DECLARE
    v_total DECIMAL(15,2);
BEGIN
    SELECT (quantidade_atual * valor_unitario) INTO v_total
    FROM produto 
    WHERE id_produto = p_id_produto;
    
    RETURN COALESCE(v_total, 0.00);
END;
$$ LANGUAGE plpgsql;

-- 2

CREATE OR REPLACE FUNCTION fn_calc_preco_com_imposto(p_id_produto INT)
RETURNS DECIMAL(15,2) AS $$
DECLARE
    v_preco_final DECIMAL(15,2);
BEGIN
    SELECT valor_unitario + (valor_unitario * (percentual_impostos / 100)) INTO v_preco_final
    FROM produto 
    WHERE id_produto = p_id_produto;
    
    RETURN COALESCE(v_preco_final, 0.00);
END;
$$ LANGUAGE plpgsql;

-- Teste 1: Ver o valor total em estoque do produto 1 (iPhone 14)
SELECT fn_calc_valor_estoque(1);

-- Teste 2: Ver o preço final sugerido com impostos do produto 1
SELECT fn_calc_preco_com_imposto(1);

-- 3

CREATE OR REPLACE FUNCTION fn_historico_cliente(p_id_cliente INT, p_data_inicio DATE, p_data_fim DATE)
RETURNS TABLE (venda_id INT, data_venda DATE, subtotal DECIMAL, total_imposto DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT id_venda, v.data_venda, sub_total, total_impostos
    FROM venda v
    WHERE fk_id_cliente = p_id_cliente
      AND v.data_venda BETWEEN p_data_inicio AND p_data_fim;
END;
$$ LANGUAGE plpgsql;

-- 4

CREATE OR REPLACE FUNCTION fn_produtos_reposicao_marca(p_id_marca INT)
RETURNS TABLE (produto_id INT, nome_prod VARCHAR, qtd_atual DECIMAL, qtd_minima DECIMAL) AS $$
BEGIN
    RETURN QUERY
    SELECT id_produto, nome, quantidade_atual, quantidade_minima
    FROM produto
    WHERE fk_id_marca = p_id_marca
      AND quantidade_atual < quantidade_minima;
END;
$$ LANGUAGE plpgsql;

-- Teste 3: Ver todas as compras do cliente 1 (Carlos Silva) em 2025
SELECT * FROM fn_historico_cliente(1, '2025-01-01', '2025-12-31');

-- Teste 4: Ver quais produtos da marca 1 (Apple) precisam de reposição de estoque
-- (Vai retornar vazio ou os produtos dependendo se você preencheu a quantidade_minima nos seus inserts)
SELECT * FROM fn_produtos_reposicao_marca(1);

-- 5

CREATE OR REPLACE PROCEDURE sp_limpar_auditoria_antiga(p_meses INT)
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM log_venda
    WHERE data_hora_log < CURRENT_TIMESTAMP - (p_meses || ' months')::interval;
    
    RAISE NOTICE 'Registros de auditoria da tabela log_venda anteriores a % meses foram limpos.', p_meses;
END;
$$;

-- 6

CREATE OR REPLACE PROCEDURE sp_restaurar_venda_deletada(p_id_venda INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_log log_venda%ROWTYPE;
BEGIN
    -- Busca o último registro de deleção ('d') para essa venda no log
    SELECT * INTO v_log
    FROM log_venda
    WHERE id_venda = p_id_venda AND operacao = 'd'
    ORDER BY data_hora_log DESC LIMIT 1;

    IF FOUND THEN
        -- Reinsere os dados resgatados na tabela original de venda
        INSERT INTO venda (id_venda, data_venda, numero, sub_total, desconto, total_impostos, fk_id_cliente, status)
        VALUES (v_log.id_venda, v_log.data_venda, v_log.numero, v_log.sub_total, v_log.desconto, v_log.total_impostos, v_log.fk_id_cliente, v_log.status);
        
        RAISE NOTICE 'Venda % restaurada com sucesso a partir da auditoria.', p_id_venda;
    ELSE
        RAISE EXCEPTION 'Não foi possível restaurar. Nenhum log de exclusão encontrado para a venda %.', p_id_venda;
    END IF;
END;
$$;

-- 1. PREPARAÇÃO: Inserir um log propositalmente velho (ano de 2020)
INSERT INTO log_venda (id_venda, data_venda, numero, sub_total, desconto, total_impostos, fk_id_cliente, status, operacao, data_hora_log)
VALUES (888, '2020-01-01', 'TESTE-VELHO', 100.00, 0.00, 10.00, 1, 'Em Andamento', 'i', '2020-01-01 10:00:00');

-- 2. O ANTES: Mostra que o log antigo está na tabela
SELECT id_log_venda, id_venda, operacao, data_hora_log 
FROM log_venda 
WHERE id_venda = 888;

-- 3. A AÇÃO: Chama a procedure para limpar tudo que tem mais de 6 meses
CALL sp_limpar_auditoria_antiga(6);

-- 4. O DEPOIS: Roda o mesmo select e mostra que não retorna nada (foi apagado)
SELECT id_log_venda, id_venda, operacao, data_hora_log 
FROM log_venda 
WHERE id_venda = 888;

-- 1. O ANTES PARTE 1: Mostra que a venda 999 não existe na tabela principal (vai retornar vazio)
SELECT id_venda, data_venda, status 
FROM venda 
WHERE id_venda = 999;

-- 2. O ANTES PARTE 2: Mostra que ela existe no log marcando que foi deletada (operacao = 'd')
SELECT id_log_venda, id_venda, operacao, data_hora_log 
FROM log_venda 
WHERE id_venda = 999 AND operacao = 'd';

-- 3. A AÇÃO: Executa a procedure de restauração
CALL sp_restaurar_venda_deletada(999);

-- 4. O DEPOIS: Mostra que a venda 999 voltou para a tabela principal com os dados recuperados
SELECT id_venda, data_venda, status 
FROM venda 
WHERE id_venda = 999;