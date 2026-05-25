-- Criação da tabela CLIENTES
CREATE TABLE clientes (
   cod_cliente SERIAL PRIMARY KEY,
   nome VARCHAR(255) NOT NULL,
   rg VARCHAR(20)
);

-- Criação da tabela TELEFONES
-- Relação: um cliente pode possuir nenhum, um ou vários telefones.
CREATE TABLE telefones (
   cod_telefone SERIAL PRIMARY KEY,
   numero VARCHAR(20) NOT NULL,
   descricao VARCHAR(50),
   cod_cliente INT NOT NULL,

   CONSTRAINT fk_telefone_cliente 
      FOREIGN KEY (cod_cliente)
      REFERENCES clientes(cod_cliente)
      ON DELETE CASCADE
);

-- Criação da tabela ORDENS_SERV
-- Relação: cada ordem de serviço pertence a um cliente.
CREATE TABLE ordens_serv (
   cod_ordem_serv SERIAL PRIMARY KEY,
   data DATE NOT NULL,
   entregue BOOLEAN NOT NULL DEFAULT FALSE,
   valor_total DECIMAL(10, 2) NOT NULL DEFAULT 0,
   cod_cliente INT NOT NULL,

   CONSTRAINT fk_os_cliente 
      FOREIGN KEY (cod_cliente)
      REFERENCES clientes(cod_cliente)
      ON DELETE RESTRICT,

   CONSTRAINT chk_ordens_serv_valor_total
      CHECK (valor_total >= 0)
);

-- Criação da tabela PAGAMENTOS
-- Relação 1:1 com ORDENS_SERV.
-- O UNIQUE em cod_ordem_serv impede que uma mesma ordem tenha mais de um pagamento.
CREATE TABLE pagamentos (
   cod_pagamento SERIAL PRIMARY KEY,
   valor DECIMAL(10, 2) NOT NULL,
   pago BOOLEAN NOT NULL DEFAULT FALSE,
   data DATE NOT NULL,
   cod_ordem_serv INT UNIQUE NOT NULL,


   CONSTRAINT fk_pagamento_os 
      FOREIGN KEY (cod_ordem_serv)
      REFERENCES ordens_serv(cod_ordem_serv)
      ON DELETE CASCADE,

   CONSTRAINT chk_pagamentos_valor
      CHECK (valor >= 0)
);

-- Criação da tabela SERVICOS
CREATE TABLE servicos (
   cod_servico SERIAL PRIMARY KEY,
   descricao VARCHAR(255) NOT NULL,
   valor DECIMAL(10, 2) NOT NULL,

   CONSTRAINT chk_servicos_valor
      CHECK (valor >= 0)
);

-- Criação da tabela associativa ITENS_OS
-- Relação N:M entre ORDENS_SERV e SERVICOS.
CREATE TABLE itens_os (
   cod_item_os SERIAL PRIMARY KEY,
   quantidade INT NOT NULL DEFAULT 1,
   valor_unit DECIMAL(10, 2) NOT NULL,
   valor_serv DECIMAL(10, 2) NOT NULL,
   cod_ordem_serv INT NOT NULL,
   cod_servico INT NOT NULL,

   CONSTRAINT fk_item_os 
      FOREIGN KEY (cod_ordem_serv)
      REFERENCES ordens_serv(cod_ordem_serv)
      ON DELETE CASCADE,

   CONSTRAINT fk_item_servico 
      FOREIGN KEY (cod_servico)
      REFERENCES servicos(cod_servico)
      ON DELETE RESTRICT,

   CONSTRAINT chk_itens_os_quantidade
      CHECK (quantidade > 0),

   CONSTRAINT chk_itens_os_valor_unit
      CHECK (valor_unit >= 0),

   CONSTRAINT chk_itens_os_valor_serv
      CHECK (valor_serv >= 0)
);