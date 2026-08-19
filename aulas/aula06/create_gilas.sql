create table profissao(
id_profissao serial not null primary key,
nome varchar(60));

create table marca(
id_marca serial not null primary key,
nome varchar(60));

create table tipo(
id_tipo serial not null primary key,
nome varchar(60));

create table produto(
id_produto serial not null primary key,
nome varchar(60),
descricao varchar(60),
valor_unitario decimal(15,2),
quantidade_atual decimal(15,2),
quantidade_minima decimal(15,2),
percentual_impostos decimal(15,2), /*valor aleatório*/
fk_id_tipo int references tipo(id_tipo) on update cascade on delete restrict, 
fk_id_marca int references marca(id_marca) on update cascade on delete restrict 
);

create table fornecedor(
id_fornecedor serial not null primary key,
nome_fantasia varchar(60),
razao_social varchar(60),
observacao text);

create table cliente(
id_cliente serial not null primary key,
nome varchar(60),
cpf_cnpj varchar(15),
descricao text,
fk_id_profissao int references profissao(id_profissao) 
	on update cascade on delete restrict
);

-- NOVA TABELA: Cidades
create table cidades(
id_cidade serial not null primary key,
nome varchar(60)
);

-- NOVA TABELA: Endereços com relacionamentos
create table enderecos(
id_endereco serial not null primary key,
tipo_logradouro varchar(30),
nome_logradouro varchar(100),
numero varchar(20),
complemento varchar(50),
cep varchar(10),
bairro varchar(60),
fk_id_cliente int references cliente(id_cliente) on update cascade on delete cascade,
fk_id_cidade int references cidades(id_cidade) on update cascade on delete restrict
);

create table telefone(
id_telefone serial not null primary key,
cod_area varchar(5),
numero varchar(10),
tipo varchar(20), -- pode ser: comercial, celular, residencial ou outros.
fk_id_cliente int not null references cliente(id_cliente)
	on update cascade on delete cascade);

create table venda(
id_venda serial not null primary key,
data_venda date,
numero varchar(60), 
sub_total decimal(15,2), 
desconto decimal(15,2), 
total_impostos decimal(15,2), 
fk_id_cliente int references cliente(id_cliente) on update cascade on delete restrict
);

create table compra(
id_compra serial not null primary key,
data_compra date,
numero varchar(60),
sub_total decimal(15,2), 
desconto decimal(15,2), 
total_impostos decimal(15,2), 
fk_id_fornecedor int references fornecedor(id_fornecedor) on update cascade on delete restrict 
);

create table carrinho_compra(
fk_id_compra int not null,
fk_id_produto int not null,
quantidade decimal(15,2),
valor_unitario decimal(15,2), 
percentual_impostos decimal(15,2), 
primary key(fk_id_compra,fk_id_produto), 
foreign key (fk_id_compra) references compra(id_compra) on update cascade on delete cascade, 
foreign key (fk_id_produto) references produto(id_produto) on update cascade on delete restrict); 

create table carrinho_venda(
fk_id_venda int not null,
fk_id_produto int not null,
quantidade decimal(15,2),
valor_unitario decimal(15,2),
percentual_impostos decimal(15,2),
primary key(fk_id_venda,fk_id_produto), 
foreign key (fk_id_venda) references venda(id_venda) on update cascade on delete cascade, 
foreign key (fk_id_produto) references produto(id_produto) on update cascade on delete restrict);