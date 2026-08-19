-- ====================================================================================
-- PREPARAÇÃO: CRIAÇÃO DE TABELAS COMPLEMENTARES PARA OS FLUXOS (Tabelas B, C, D e Log)
-- ====================================================================================
-- Para o Fluxo 1
CREATE TABLE IF NOT EXISTS fidelidade_cliente (
    id_cliente INT PRIMARY KEY REFERENCES clientes(id_cliente),
    total_comprado DECIMAL(10, 2)
);
CREATE TABLE IF NOT EXISTS beneficios_cliente (
    id_cliente INT PRIMARY KEY REFERENCES clientes(id_cliente),
    desconto_liberado DECIMAL(10, 2)
);
-- Para o Fluxo 2
CREATE TABLE IF NOT EXISTS estoque (
    id_produto INT PRIMARY KEY REFERENCES produtos(id_produto),
    qtd_disponivel INT DEFAULT 50 -- Valor inicial para testes
);
-- Populando estoque inicial para produtos existentes
INSERT INTO estoque (id_produto)
SELECT id_produto
FROM produtos ON CONFLICT DO NOTHING;
CREATE TABLE IF NOT EXISTS historico_cancelamentos (
    id_cancelamento SERIAL PRIMARY KEY,
    order_id VARCHAR(20),
    preco_na_epoca DECIMAL(10, 2),
    qtd_devolvida INT
);
CREATE TABLE IF NOT EXISTS sistema_logs (
    id_log SERIAL PRIMARY KEY,
    data_log TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    msg_log TEXT
);
-- ====================================================================================
-- 1. CRIAÇÃO DA VIEW (Fluxo 1)
-- ====================================================================================
-- View A: Obtém o total gasto pelo cliente apenas em pedidos concluídos
CREATE OR REPLACE VIEW vw_gasto_cliente AS
SELECT id_cliente,
    SUM(total_sales) as gasto_total
FROM vendas
WHERE status = 'Completed'
GROUP BY id_cliente;
-- ====================================================================================
-- 2. FLUXO 1: TRIGGER DE INSERT NA TABELA 'vendas'
-- ====================================================================================
CREATE OR REPLACE FUNCTION trg_fluxo1_insert() RETURNS TRIGGER AS $$
DECLARE v_gasto_total DECIMAL(10, 2);
v_desconto DECIMAL(10, 2);
BEGIN -- 1. Teste condicional: Verifica se o status é 'Completed'
IF NEW.status = 'Completed' THEN -- 2. Obter resultado de uma View A
SELECT gasto_total INTO v_gasto_total
FROM vw_gasto_cliente
WHERE id_cliente = NEW.id_cliente;
-- 3. Efetuar insert ou update em uma Tabela B (Fidelidade)
INSERT INTO fidelidade_cliente (id_cliente, total_comprado)
VALUES (NEW.id_cliente, v_gasto_total) ON CONFLICT (id_cliente) DO
UPDATE
SET total_comprado = EXCLUDED.total_comprado;
-- 4. Teste condicional 2: Cliente gastou mais de 300 no total?
IF v_gasto_total >= 300 THEN -- 5. Efetuar um cálculo e atribuir a uma variável local
v_desconto := v_gasto_total * 0.10;
-- 10% de desconto
-- 6. Atualizar uma Tabela C (Benefícios)
INSERT INTO beneficios_cliente (id_cliente, desconto_liberado)
VALUES (NEW.id_cliente, v_desconto) ON CONFLICT (id_cliente) DO
UPDATE
SET desconto_liberado = EXCLUDED.desconto_liberado;
END IF;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS tg_fluxo1 ON vendas;
CREATE TRIGGER tg_fluxo1
AFTER
INSERT ON vendas FOR EACH ROW EXECUTE FUNCTION trg_fluxo1_insert();
-- ====================================================================================
-- 3. FLUXO 2: TRIGGER DE UPDATE NA TABELA 'vendas'
-- ====================================================================================
CREATE OR REPLACE FUNCTION trg_fluxo2_update() RETURNS TRIGGER AS $$
DECLARE v_valor_acumulado DECIMAL(10, 2);
v_preco_produto DECIMAL(10, 2);
BEGIN -- 1. Efetuar um cálculo acumulando o valor em uma variável local (Impacto financeiro)
v_valor_acumulado := OLD.total_sales;
-- 2. Teste condicional: Pedido foi atualizado para 'Cancelled'?
IF NEW.status = 'Cancelled'
AND OLD.status != 'Cancelled' THEN -- 3. Recuperar dados necessários de uma Tabela B (produtos)
SELECT preco INTO v_preco_produto
FROM produtos
WHERE id_produto = NEW.id_produto;
-- 4. Inserir Dados em uma Tabela C (historico_cancelamentos)
INSERT INTO historico_cancelamentos (order_id, preco_na_epoca, qtd_devolvida)
VALUES (NEW.order_id, v_preco_produto, OLD.quantidade);
-- 5. Atualizar uma Tabela D de acordo com os dados (Estoque - devolvendo os itens)
UPDATE estoque
SET qtd_disponivel = qtd_disponivel + OLD.quantidade
WHERE id_produto = NEW.id_produto;
-- 6. Registrar Logs
INSERT INTO sistema_logs (msg_log)
VALUES (
        'Pedido ' || NEW.order_id || ' cancelado. ' || OLD.quantidade || ' itens devolvidos. Perda financeira acumulada: $' || v_valor_acumulado
    );
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS tg_fluxo2 ON vendas;
CREATE TRIGGER tg_fluxo2
AFTER
UPDATE ON vendas FOR EACH ROW EXECUTE FUNCTION trg_fluxo2_update();
-- ====================================================================================
-- 4. TESTES DE VALIDAÇÃO
-- ====================================================================================
-- TESTE DO FLUXO 1: Inserindo uma venda nova com status 'Completed' (Total > 300)
-- Obs: Assumindo que os IDs de cliente e produto '1' existam gerados no seu script base. 
TRUNCATE TABLE vendas, sistema_logs, historico_cancelamentos CASCADE; -- Limpa dados para testes
INSERT INTO vendas (
        order_id,
        id_cliente,
        id_produto,
        data_venda,
        quantidade,
        total_sales,
        metodo_pagamento,
        status
    )
VALUES (
        'ORD_FLUXO1',
        1,
        1,
        '06-04-26',
        5,
        500.00,
        'Pix',
        'Completed'
    );
-- Selects para provar o Fluxo 1:
SELECT *
FROM fidelidade_cliente
WHERE id_cliente = 1;
SELECT *
FROM beneficios_cliente
WHERE id_cliente = 1;
-- TESTE DO FLUXO 2: Atualizando a venda anterior para 'Cancelled'
UPDATE vendas
SET status = 'Cancelled'
WHERE order_id = 'ORD_FLUXO1';
-- Selects para provar o Fluxo 2:
SELECT *
FROM historico_cancelamentos;
SELECT *
FROM estoque
WHERE id_produto = 1;
SELECT *
FROM sistema_logs;