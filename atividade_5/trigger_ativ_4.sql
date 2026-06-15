-- 1. Criação da tabela de Log
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

-- 2. Criação da Função do Trigger
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
FOR EACH ROW EXECUTE FUNCTION fn_registrar_log_venda();

ALTER TABLE venda ADD COLUMN status VARCHAR(20) DEFAULT 'Em Andamento';

-- Cria uma venda de teste
INSERT INTO venda (id_venda, data_venda, fk_id_cliente, status, desconto)
VALUES (999, '2026-04-06', 1, 'Em Andamento', 0.00);

-- Deleta a venda de teste (isso aciona o trigger e salva a venda no log)
DELETE FROM venda WHERE id_venda = 999;