-- ==========================================
-- -1. LIMPEZA DO BANCO (Para garantir que está vazio)
-- ==========================================
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO public;
-- ==========================================
-- 0. CRIAÇÃO DA TABELA GERAL (Desnormalizada)
-- ==========================================
CREATE TABLE IF NOT EXISTS amazon_sales_geral (
    order_id VARCHAR(20) PRIMARY KEY,
    data_venda VARCHAR(20),
    produto VARCHAR(100),
    categoria VARCHAR(50),
    preco DECIMAL(10, 2),
    quantidade INT,
    total_sales DECIMAL(10, 2),
    nome_cliente VARCHAR(100),
    localizacao_cliente VARCHAR(100),
    metodo_pagamento VARCHAR(50),
    status VARCHAR(50)
);
-- Simulando a importação do meu arquivo CSV para termos dados iniciais
INSERT INTO amazon_sales_geral
VALUES (
        'ORD0001',
        '14-03-25',
        'Running Shoes',
        'Footwear',
        60,
        3,
        180,
        'Emma Clark',
        'New York',
        'Debit Card',
        'Cancelled'
    ),
    (
        'ORD0002',
        '20-03-25',
        'Headphones',
        'Electronics',
        100,
        4,
        400,
        'Emily Johnson',
        'San Francisco',
        'Debit Card',
        'Pending'
    ),
    (
        'ORD0003',
        '15-02-25',
        'Running Shoes',
        'Footwear',
        60,
        2,
        120,
        'John Doe',
        'Denver',
        'Amazon Pay',
        'Cancelled'
    ) ON CONFLICT (order_id) DO NOTHING;
-- ==========================================
-- 1. NORMALIZAÇÃO E CRIAÇÃO DAS TABELAS
-- ==========================================
CREATE TABLE IF NOT EXISTS clientes (
    id_cliente SERIAL PRIMARY KEY,
    nome_cliente VARCHAR(100) UNIQUE,
    localizacao_cliente VARCHAR(100)
);
CREATE TABLE IF NOT EXISTS produtos (
    id_produto SERIAL PRIMARY KEY,
    produto VARCHAR(100) UNIQUE,
    categoria VARCHAR(50),
    preco DECIMAL(10, 2)
);
CREATE TABLE IF NOT EXISTS vendas (
    order_id VARCHAR(20) PRIMARY KEY,
    id_cliente INT REFERENCES clientes(id_cliente),
    id_produto INT REFERENCES produtos(id_produto),
    data_venda VARCHAR(20),
    quantidade INT,
    total_sales DECIMAL(10, 2),
    metodo_pagamento VARCHAR(50),
    status VARCHAR(50)
);
-- ==========================================
-- 2. INSERT MÚLTIPLO (Populando as novas tabelas)
-- ==========================================
-- Inserindo clientes
INSERT INTO clientes (nome_cliente, localizacao_cliente) (
        SELECT DISTINCT nome_cliente,
            localizacao_cliente
        FROM amazon_sales_geral
        WHERE nome_cliente IS NOT NULL
    ) ON CONFLICT (nome_cliente) DO NOTHING;
-- Inserindo produtos
INSERT INTO produtos (produto, categoria, preco) (
        SELECT DISTINCT produto,
            categoria,
            preco
        FROM amazon_sales_geral
        WHERE produto IS NOT NULL
    ) ON CONFLICT (produto) DO NOTHING;
-- Inserindo as vendas e vinculando as chaves estrangeiras
INSERT INTO vendas (
        order_id,
        id_cliente,
        id_produto,
        data_venda,
        quantidade,
        total_sales,
        metodo_pagamento,
        status
    ) (
        SELECT g.order_id,
            c.id_cliente,
            p.id_produto,
            g.data_venda,
            g.quantidade,
            g.total_sales,
            g.metodo_pagamento,
            g.status
        FROM amazon_sales_geral g
            JOIN clientes c ON g.nome_cliente = c.nome_cliente
            JOIN produtos p ON g.produto = p.produto
    ) ON CONFLICT (order_id) DO NOTHING;
-- ==========================================
-- 3. CRIAÇÃO DE TRIGGER PARA POPULAR AUTOMATICAMENTE
-- ==========================================
CREATE OR REPLACE FUNCTION trg_popula_tabelas() RETURNS TRIGGER AS $$
DECLARE v_id_cliente INT;
v_id_produto INT;
BEGIN -- Insere ou ignora cliente e pega o ID
INSERT INTO clientes (nome_cliente, localizacao_cliente)
VALUES (NEW.nome_cliente, NEW.localizacao_cliente) ON CONFLICT (nome_cliente) DO NOTHING;
SELECT id_cliente INTO v_id_cliente
FROM clientes
WHERE nome_cliente = NEW.nome_cliente;
-- Insere ou ignora produto e pega o ID
INSERT INTO produtos (produto, categoria, preco)
VALUES (NEW.produto, NEW.categoria, NEW.preco) ON CONFLICT (produto) DO NOTHING;
SELECT id_produto INTO v_id_produto
FROM produtos
WHERE produto = NEW.produto;
-- Insere a venda
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
        NEW.order_id,
        v_id_cliente,
        v_id_produto,
        NEW.data_venda,
        NEW.quantidade,
        NEW.total_sales,
        NEW.metodo_pagamento,
        NEW.status
    ) ON CONFLICT (order_id) DO NOTHING;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- Remove a trigger se já existir (evita erros se rodar o script 2x)
DROP TRIGGER IF EXISTS tg_nova_venda ON amazon_sales_geral;
CREATE TRIGGER tg_nova_venda
AFTER
INSERT ON amazon_sales_geral FOR EACH ROW EXECUTE FUNCTION trg_popula_tabelas();
-- ==========================================
-- 4. TESTES (Verificando a inserção correta)
-- ==========================================
-- Simulando um novo insert na tabela geral para disparar a trigger
INSERT INTO amazon_sales_geral (
        order_id,
        data_venda,
        produto,
        categoria,
        preco,
        quantidade,
        total_sales,
        nome_cliente,
        localizacao_cliente,
        metodo_pagamento,
        status
    )
VALUES (
        'ORD_TESTE01',
        '30-03-25',
        'Teclado Mecânico',
        'Electronics',
        250,
        1,
        250,
        'Tio Gilas',
        'Correia Pinto',
        'Pix',
        'Completed'
    ) ON CONFLICT (order_id) DO NOTHING;
SELECT *
FROM clientes
ORDER BY id_cliente DESC
LIMIT 5;
SELECT *
FROM produtos
ORDER BY id_produto DESC
LIMIT 5;
SELECT *
FROM vendas
ORDER BY order_id DESC
LIMIT 5;