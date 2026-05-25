-- =========================================================================
-- 1. INSERÇÃO NA TABELA CLIENTES (Tabela Simples - 20 Registros)
-- =========================================================================
INSERT INTO clientes (nome, rg) VALUES
('Dave Mustaine', '11.111.111-1'),
('Max Cavalera', '22.222.222-2'),
('Serj Tankian', '33.333.333-3'),
('James Hetfield', '44.444.444-4'),
('Saul Hudson', '55.555.555-5'),
('Papaios Enterprise', '66.666.666-6'),
('João Silva', '77.777.777-7'),
('Maria Oliveira', '88.888.888-8'),
('Carlos Eduardo', '99.999.999-9'),
('Ana Costa', '10.101.010-1'),
('Roberto Souza', '12.121.212-2'),
('Fernanda Lima', '13.131.313-3'),
('Lucas Mendes', '14.141.414-4'),
('Juliana Alves', '15.151.515-5'),
('Pedro Henrique', '16.161.616-6'),
('Camila Rocha', '17.171.717-7'),
('Bruno Martins', '18.181.818-8'),
('Larissa Dias', '19.191.919-9'),
('Thiago Pereira', '20.202.020-0'),
('Aline Ferreira', '21.212.121-1');

-- =========================================================================
-- 2. INSERÇÃO NA TABELA SERVICOS (Tabela Simples - 20 Registros)
-- =========================================================================
INSERT INTO servicos (descricao, valor) VALUES
('Instalação e Configuração CachyOS', 150.00),
('Configuração de Terminal Zsh + Powerlevel10k', 80.00),
('Customização de Tema Ghostty (Estilo Fallout)', 50.00),
('Regulagem de Guitarra Jackson JS32', 120.00),
('Formatação de PC com EndeavourOS', 130.00),
('Manutenção em Pedal Metalzone MT2', 90.00),
('Configuração de Reaper + Amplitube', 100.00),
('Desenvolvimento de Script de Sincronização de Áudio', 250.00),
('Hospedagem e Deploy via GitHub Pages', 180.00),
('Otimização de Kernel Linux', 110.00),
('Modelagem de Banco de Dados PostgreSQL', 300.00),
('Normalização de Tabelas SQL', 200.00),
('Configuração de WINE para Jogos', 70.00),
('Instalação de Shaders no Minecraft', 40.00),
('Limpeza Interna de Hardware', 85.00),
('Troca de Cordas 0.10', 45.00),
('Manutenção de Headset VR', 160.00),
('Consultoria em Python para Análise de Dados', 350.00),
('Criação de Website Institucional', 800.00),
('Desenvolvimento de App de Mensagens (Beta)', 1500.00);

-- =========================================================================
-- 3. INSERÇÃO NA TABELA TELEFONES (Tabela Simples - 20 Registros)
-- Relação com Clientes (cod_cliente de 1 a 20)
-- =========================================================================
INSERT INTO telefones (numero, descricao, cod_cliente) VALUES
('(48) 99999-0001', 'Celular Pessoal', 1),
('(48) 99999-0002', 'WhatsApp', 2),
('(48) 99999-0003', 'Comercial', 3),
('(48) 99999-0004', 'Residencial', 4),
('(48) 99999-0005', 'Celular', 5),
('(48) 99999-0006', 'Contato Empresa', 6),
('(49) 98888-0007', 'Celular (Lages)', 7),
('(49) 98888-0008', 'WhatsApp (Correia Pinto)', 8),
('(48) 97777-0009', 'Celular', 9),
('(48) 97777-0010', 'Trabalho', 10),
('(48) 96666-0011', 'Celular Pessoal', 11),
('(48) 96666-0012', 'WhatsApp', 12),
('(48) 95555-0013', 'Recados', 13),
('(48) 95555-0014', 'Residencial', 14),
('(48) 94444-0015', 'Comercial', 15),
('(48) 94444-0016', 'Celular', 16),
('(48) 93333-0017', 'WhatsApp', 17),
('(48) 93333-0018', 'Celular Pessoal', 18),
('(48) 92222-0019', 'Trabalho', 19),
('(48) 92222-0020', 'Residencial', 20);

-- =========================================================================
-- 4. INSERÇÃO NA TABELA ORDENS_SERV (Tabela Simples - 20 Registros)
-- Relação com Clientes (cod_cliente de 1 a 20)
-- =========================================================================
INSERT INTO ordens_serv (data, entregue, valor_total, cod_cliente) VALUES
('2026-05-01', TRUE, 230.00, 1),
('2026-05-02', TRUE, 120.00, 2),
('2026-05-03', FALSE, 130.00, 3),
('2026-05-04', TRUE, 100.00, 4),
('2026-05-05', FALSE, 250.00, 5),
('2026-05-06', TRUE, 2300.00, 6),
('2026-05-07', FALSE, 110.00, 7),
('2026-05-08', TRUE, 500.00, 8),
('2026-05-09', TRUE, 110.00, 9),
('2026-05-10', FALSE, 85.00, 10),
('2026-05-11', TRUE, 160.00, 11),
('2026-05-12', FALSE, 350.00, 12),
('2026-05-13', TRUE, 150.00, 13),
('2026-05-14', FALSE, 120.00, 14),
('2026-05-15', TRUE, 220.00, 15),
('2026-05-16', TRUE, 300.00, 16),
('2026-05-17', FALSE, 40.00, 17),
('2026-05-18', TRUE, 145.00, 18),
('2026-05-19', TRUE, 200.00, 19),
('2026-05-20', FALSE, 190.00, 20);

-- =========================================================================
-- 5. INSERÇÃO NA TABELA PAGAMENTOS (Tabela Simples - 20 Registros)
-- Relação 1:1 com Ordens de Serviço (cod_ordem_serv UNIQUE de 1 a 20)
-- =========================================================================
INSERT INTO pagamentos (valor, pago, data, cod_ordem_serv) VALUES
(230.00, TRUE, '2026-05-01', 1),
(120.00, TRUE, '2026-05-02', 2),
(130.00, FALSE, '2026-05-03', 3),
(100.00, TRUE, '2026-05-04', 4),
(250.00, FALSE, '2026-05-05', 5),
(2300.00, TRUE, '2026-05-06', 6),
(110.00, FALSE, '2026-05-07', 7),
(500.00, TRUE, '2026-05-08', 8),
(110.00, TRUE, '2026-05-09', 9),
(85.00, FALSE, '2026-05-10', 10),
(160.00, TRUE, '2026-05-11', 11),
(350.00, FALSE, '2026-05-12', 12),
(150.00, TRUE, '2026-05-13', 13),
(120.00, FALSE, '2026-05-14', 14),
(220.00, TRUE, '2026-05-15', 15),
(300.00, TRUE, '2026-05-16', 16),
(40.00, FALSE, '2026-05-17', 17),
(145.00, TRUE, '2026-05-18', 18),
(200.00, TRUE, '2026-05-19', 19),
(190.00, FALSE, '2026-05-20', 20);

-- =========================================================================
-- 6. INSERÇÃO NA TABELA ITENS_OS (CORRIGIDA)
-- =========================================================================
INSERT INTO itens_os (quantidade, valor_unit, valor_serv, cod_ordem_serv, cod_servico) VALUES
-- OS 1 (Total: 230.00)
(1, 150.00, 150.00, 1, 1),
(1, 80.00, 80.00, 1, 2),
-- OS 2 (Total: 120.00) - CORRIGIDO AQUI (Sem quantidade 0)
(1, 70.00, 70.00, 2, 13), 
(1, 50.00, 50.00, 2, 3),
-- OS 3 (Total: 130.00)
(1, 130.00, 130.00, 3, 5),
(1, 0.00, 0.00, 3, 5), -- Serviço cortesia (valor 0 é permitido, quantidade é 1)
-- OS 4 (Total: 100.00)
(1, 100.00, 100.00, 4, 7),
(1, 0.00, 0.00, 4, 7),
-- OS 5 (Total: 250.00)
(1, 250.00, 250.00, 5, 8),
(1, 0.00, 0.00, 5, 8),
-- OS 6 (Total: 2300.00)
(1, 1500.00, 1500.00, 6, 20),
(1, 800.00, 800.00, 6, 19),
-- OS 7 (Total: 110.00)
(1, 110.00, 110.00, 7, 10),
(1, 0.00, 0.00, 7, 10),
-- OS 8 (Total: 500.00)
(1, 300.00, 300.00, 8, 11),
(1, 200.00, 200.00, 8, 12),
-- OS 9 (Total: 110.00)
(1, 70.00, 70.00, 9, 13),
(1, 40.00, 40.00, 9, 14),
-- OS 10 (Total: 85.00)
(1, 85.00, 85.00, 10, 15),
(1, 0.00, 0.00, 10, 15),
-- OS 11 (Total: 160.00)
(1, 160.00, 160.00, 11, 17),
(1, 0.00, 0.00, 11, 17),
-- OS 12 (Total: 350.00)
(1, 350.00, 350.00, 12, 18),
(1, 0.00, 0.00, 12, 18),
-- OS 13 (Total: 150.00)
(1, 150.00, 150.00, 13, 1),
(1, 0.00, 0.00, 13, 1),
-- OS 14 (Total: 120.00)
(1, 120.00, 120.00, 14, 4),
(1, 0.00, 0.00, 14, 4),
-- OS 15 (Total: 220.00)
(1, 130.00, 130.00, 15, 5),
(1, 90.00, 90.00, 15, 6),
-- OS 16 (Total: 300.00)
(2, 150.00, 300.00, 16, 1), 
(1, 0.00, 0.00, 16, 1),
-- OS 17 (Total: 40.00)
(1, 40.00, 40.00, 17, 14),
(1, 0.00, 0.00, 17, 14),
-- OS 18 (Total: 145.00)
(1, 100.00, 100.00, 18, 7),
(1, 45.00, 45.00, 18, 16),
-- OS 19 (Total: 200.00)
(1, 200.00, 200.00, 19, 12),
(1, 0.00, 0.00, 19, 12),
-- OS 20 (Total: 190.00)
(1, 150.00, 150.00, 20, 1),
(1, 40.00, 40.00, 20, 14);