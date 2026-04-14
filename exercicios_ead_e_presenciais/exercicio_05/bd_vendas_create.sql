create table if not exists profissao  (
id_profissao serial not null primary key,
nome varchar(60));

create table if not exists marca  (
id_marca serial not null primary key,
nome varchar(60));

create table if not exists tipo  (
id_tipo serial not null primary key,
nome varchar(60));

create table if not exists produto  (
id_produto serial not null primary key,
nome varchar(60),
descricao varchar(60),
valor_unitario decimal(15,2),
quantidade_atual decimal(15,2),
quantidade_minima decimal(15,2),
percentual_impostos decimal(15,2), /*valor aleatório*/
fk_id_tipo int references tipo(id_tipo) on update cascade on delete restrict, /*Valores devem existir na tabela tipo (campo id_tipo)*/
fk_id_marca int references marca(id_marca) on update cascade on delete restrict /*Valores devem existir na tabela marca (campo id_marca)*/
);

create table if not exists fornecedor  (
id_fornecedor serial not null primary key,
nome_fantasia varchar(60),
razao_social varchar(60),
observacao text);

create table if not exists cliente  (
id_cliente serial not null primary key,
nome varchar(60),
cpf_cnpj varchar(15),
descricao text,
fk_id_profissao int references profissao(id_profissao) 
	on update cascade on delete restrict /*Valores devem existir na tabela profissao (campo id_profissao)*/
);

create table if not exists telefone  (
id_telefone serial not null primary key,
cod_area varchar(5),
numero varchar(10),
tipo varchar(20), -- pode ser: comercial, celular, residencial ou outros.
fk_id_cliente int not null references cliente(id_cliente)
	on update cascade on delete cascade);

create table if not exists venda  (
id_venda serial not null primary key,
data_venda date,
status VARCHAR(20) DEFAULT 'Em Andamento',
numero varchar(60), 
sub_total decimal(15,2), /*Somatório de (valor_unitário * quantidade) de carrinho_venda*/
desconto decimal(15,2), /*valor aleatório em R$*/
total_impostos decimal(15,2), /*Somatório dos valores em (R$), calculados do percentual de impostos de (valor_unitário * quantidade) de carrinho_venda*/
fk_id_cliente int references cliente(id_cliente) on update cascade on delete restrict /*Valores devem existir na tabela cliente (campo id_cliente)*/
);

create table if not exists compra  (
id_compra serial not null primary key,
data_compra date,
numero varchar(60),
sub_total decimal(15,2), /*Somatório de (valor_unitário * quantidade) de carrinho_compra*/
desconto decimal(15,2), /*valor aleatório em R$*/
total_impostos decimal(15,2), /*Somatório dos valores em (R$), calculados do percentual de impostos de (valor_unitário * quantidade) de carrinho_compra*/
fk_id_fornecedor int references fornecedor(id_fornecedor) on update cascade on delete restrict /*Valores devem existir na tabela fornecedor (campo id_fornecedor)*/
);

create table if not exists carrinho_compra  (
fk_id_compra int not null,
fk_id_produto int not null,
quantidade decimal(15,2),
valor_unitario decimal(15,2), /*mesmo valor_unitário de produto*/
percentual_impostos decimal(15,2), /*mesmo percentual_imposto de produto*/
primary key(fk_id_compra,fk_id_produto), /*chave estrangeira composta*/
foreign key (fk_id_compra) references compra(id_compra) on update cascade on delete cascade, /*Valores devem existir na tabela compra (campo id_compra)*/
foreign key (fk_id_produto) references produto(id_produto) on update cascade on delete restrict); /*Valores devem existir na tabela produto (campo id_produto)*/

create table if not exists carrinho_venda  (
fk_id_venda int not null,
fk_id_produto int not null,
quantidade decimal(15,2),
valor_unitario decimal(15,2),/*mesmo valor_unitário de produto*/
percentual_impostos decimal(15,2),/*mesmo percentual_imposto de produto*/
primary key(fk_id_venda,fk_id_produto), /*chave estrangeira composta*/
foreign key (fk_id_venda) references venda(id_venda) on update cascade on delete cascade, /*Valores devem existir na tabela venda (campo id_venda)*/
foreign key (fk_id_produto) references produto(id_produto) on update cascade on delete restrict); /*Valores devem existir na tabela produto (campo id_produto)*/

-- Criando a tabela cidades que faltou
CREATE TABLE if not exists cidades  (
    id_cidade SERIAL PRIMARY KEY,
    nome VARCHAR(100)
);

-- Criando a tabela enderecos que faltou
CREATE TABLE if not exists enderecos  (
    id_endereco SERIAL PRIMARY KEY,
    tipo_logradouro VARCHAR(50),
    nome_logradouro VARCHAR(100),
    numero VARCHAR(20),
    complemento VARCHAR(50),
    cep VARCHAR(20),
    bairro VARCHAR(100),
    fk_id_cliente INT REFERENCES cliente(id_cliente) ON UPDATE CASCADE ON DELETE CASCADE,
    fk_id_cidade INT REFERENCES cidades(id_cidade) ON UPDATE CASCADE ON DELETE RESTRICT
);