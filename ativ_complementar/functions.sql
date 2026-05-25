-- ==============================
-- View: VW_FATURAMENTO_SERVICOS
-- ==============================

CREATE OR REPLACE VIEW VW_FATURAMENTO_SERVICOS AS
SELECT 
    s.cod_servico,
    s.descricao AS descricao_servico,
    COALESCE(SUM(io.quantidade * io.valor_unit), 0.00) AS faturamento_total
FROM 
    servicos s
LEFT JOIN 
    itens_os io ON s.cod_servico = io.cod_servico
GROUP BY 
    s.cod_servico, 
    s.descricao;

-- teste da view
SELECT * FROM VW_FATURAMENTO_SERVICOS ORDER BY faturamento_total DESC;

-- ===============================
-- View: VW_TOTAL_OS_CLIENTES_2026
-- ===============================

CREATE OR REPLACE VIEW VW_TOTAL_OS_CLIENTES_2026 AS
SELECT 
    c.nome AS nome_cliente,
    SUM(os.valor_total) AS valor_total_acumulado
FROM 
    clientes c
INNER JOIN 
    ordens_serv os ON c.cod_cliente = os.cod_cliente
WHERE 
    EXTRACT(YEAR FROM os.data) = 2026
GROUP BY 
    c.cod_cliente,
    c.nome;

-- teste da view
SELECT * FROM VW_TOTAL_OS_CLIENTES_2026 ORDER BY valor_total_acumulado DESC;

-- ===============================
-- Function: func_valida_calcula_item_os
-- ===============================

CREATE OR REPLACE FUNCTION func_valida_calcula_item_os()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.quantidade IS NULL OR NEW.quantidade <= 0 THEN
        RAISE EXCEPTION 'Erro de Inserção: A quantidade informada deve ser maior que zero.';
    END IF;

    SELECT valor INTO NEW.valor_unit
    FROM servicos
    WHERE cod_servico = NEW.cod_servico;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Erro de Inserção: Serviço com código % não encontrado.', NEW.cod_servico;
    END IF;
    NEW.valor_serv := NEW.quantidade * NEW.valor_unit;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ===============================
-- Trigger: trg_valida_calcula_item_os
-- ===============================

CREATE TRIGGER trg_valida_calcula_item_os
BEFORE INSERT ON itens_os
FOR EACH ROW
EXECUTE FUNCTION func_valida_calcula_item_os();

-- teste do trigger

INSERT INTO itens_os (quantidade, cod_ordem_serv, cod_servico) 
VALUES (2, 1, 3);

-- select
SELECT * FROM itens_os WHERE cod_ordem_serv = 1 AND cod_servico = 3;

-- teste de inserção com quantidade zero (deve gerar erro)

INSERT INTO itens_os (quantidade, cod_ordem_serv, cod_servico) 
VALUES (0, 1, 1);

-- ===============================
-- Stored Procedure: proc_atualiza_valor_os
-- ===============================

CREATE OR REPLACE PROCEDURE proc_atualiza_valor_os(p_cod_ordem_serv INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total DECIMAL(10, 2);
    v_os_existe BOOLEAN;
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM ordens_serv WHERE cod_ordem_serv = p_cod_ordem_serv
    ) INTO v_os_existe;

    -- se a OS não existir, aborta a operação emitindo um aviso
    IF NOT v_os_existe THEN
        RAISE EXCEPTION 'Erro: A Ordem de Serviço % não existe no banco de dados.', p_cod_ordem_serv;
    END IF;

    SELECT COALESCE(SUM(valor_serv), 0.00) INTO v_total
    FROM itens_os
    WHERE cod_ordem_serv = p_cod_ordem_serv;

    UPDATE ordens_serv
    SET valor_total = v_total
    WHERE cod_ordem_serv = p_cod_ordem_serv;

    RAISE NOTICE 'Sucesso! Ordem de Serviço % atualizada. Novo valor: R$ %', p_cod_ordem_serv, v_total;
END;
$$;

-- teste da procedure

CALL proc_atualiza_valor_os(1);

-- select
SELECT cod_ordem_serv, valor_total FROM ordens_serv WHERE cod_ordem_serv = 1;

-- teste de chamada da procedure com código de OS inexistente (deve gerar erro)

CALL proc_atualiza_valor_os(999);

-- ===============================
-- Function: FN_SERVICOS_ORDEM
-- ===============================

CREATE OR REPLACE FUNCTION FN_SERVICOS_ORDEM(p_cod_ordem_serv INT)
RETURNS TABLE (
    codigo_os INT,
    nome_cliente VARCHAR,
    descricao_servico VARCHAR,
    quantidade INT,
    valor_unitario DECIMAL(10, 2),
    valor_total_item DECIMAL(10, 2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        os.cod_ordem_serv,
        c.nome::VARCHAR,
        s.descricao::VARCHAR,
        io.quantidade,
        io.valor_unit,
        io.valor_serv 
    FROM 
        ordens_serv os
    INNER JOIN 
        clientes c ON os.cod_cliente = c.cod_cliente
    INNER JOIN 
        itens_os io ON os.cod_ordem_serv = io.cod_ordem_serv
    INNER JOIN 
        servicos s ON io.cod_servico = s.cod_servico
    WHERE 
        os.cod_ordem_serv = p_cod_ordem_serv;
END;
$$;

-- Testando com a Ordem de Serviço de código 1 (pode trocar pelo número que quiser)
SELECT * FROM FN_SERVICOS_ORDEM(1);

-- Testando com uma Ordem de Serviço que não existe ou não tem itens para ver vir vazio
SELECT * FROM FN_SERVICOS_ORDEM(999);