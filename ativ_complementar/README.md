# 🔧 Atividade Complementar — Ordens de Serviço

> Atividade extra da prova 1. Um schema de oficina/assistência técnica, com o cálculo do valor da OS acontecendo sozinho no banco.

## 🎯 O que essa atividade faz

Modela o banco de uma **empresa de prestação de serviços**: clientes, telefones, ordens de serviço, itens e pagamentos. Sobre ele, implementa um trigger, uma procedure e uma função que mantêm o valor da OS sempre correto.

## 🗺️ O schema

```
clientes ──┬──▶ telefones          (1:N — um cliente, vários telefones)
           └──▶ ordens_serv ──┬──▶ itens_os ──▶ servicos
                              └──▶ pagamentos
```

| Tabela | Papel |
|---|---|
| `clientes` | Cadastro base (nome, RG) |
| `telefones` | Um cliente pode ter nenhum, um ou vários |
| `ordens_serv` | A OS: data, se foi entregue, valor total, dono |
| `servicos` | Catálogo de serviços com seus preços |
| `itens_os` | Os serviços aplicados numa OS específica |
| `pagamentos` | Os pagamentos de cada OS |

## 🔑 O `ON DELETE CASCADE`

```sql
CONSTRAINT fk_telefone_cliente
   FOREIGN KEY (cod_cliente)
   REFERENCES clientes(cod_cliente)
   ON DELETE CASCADE
```

Apagou o cliente, os telefones dele vão junto. Faz sentido aqui porque **telefone não existe sozinho** — sem o cliente, aquele registro não significa nada.

Repare que essa mesma escolha seria errada em `ordens_serv`: uma OS tem valor histórico e contábil, e não deveria evaporar porque alguém removeu um cadastro. Cascade é decisão caso a caso, não padrão.

## ⚙️ As três rotinas

| Tipo | Nome | O que faz |
|---|---|---|
| 🔧 **Function + Trigger** | `func_valida_calcula_item_os()` | Antes de inserir um item na OS, busca o preço do serviço e calcula o subtotal |
| 🔁 **Procedure** | `proc_atualiza_valor_os(cod_os)` | Recalcula o `valor_total` da OS somando todos os itens |
| 🧮 **Function** | `FN_SERVICOS_ORDEM(cod_os)` | Retorna a lista de serviços de uma ordem |

### O padrão calcular-e-consolidar

Essas três peças formam um padrão que vale reconhecer:

1. O **trigger** age no nível da **linha** — cada item que entra já chega com preço e subtotal corretos, sem depender de quem fez o `INSERT`.
2. A **procedure** age no nível do **documento** — soma os itens e consolida o total da OS.
3. A **function** serve para **consultar** o resultado.

A vantagem: `valor_total` na `ordens_serv` nunca fica dessincronizado dos itens. Sem isso, você dependeria de a aplicação lembrar de recalcular — e uma hora ela esquece.

### `DEFAULT` que evita `NULL`

```sql
entregue BOOLEAN NOT NULL DEFAULT FALSE,
valor_total DECIMAL(10, 2) NOT NULL DEFAULT 0,
```

Uma OS recém-criada não foi entregue e não vale nada ainda — mas `FALSE` e `0` dizem isso com precisão, enquanto `NULL` diria "não sei". Como toda conta com `NULL` resulta em `NULL`, o `DEFAULT 0` aqui evita que a soma dos itens quebre em silêncio.

## 📁 Arquivos

| Arquivo | O que é |
|---|---|
| `criacao_bd_empresa.sql` | DDL das 6 tabelas com suas constraints e cascatas. |
| `inserts_bd_empresa.sql` | Massa de dados de teste. |
| `functions.sql` | O trigger, a procedure e a função, com os testes. |

## ▶️ Como rodar

```bash
createdb -U postgres ativ_complementar
psql -U postgres -d ativ_complementar -f criacao_bd_empresa.sql
psql -U postgres -d ativ_complementar -f inserts_bd_empresa.sql
psql -U postgres -d ativ_complementar -f functions.sql
```

Testando o ciclo completo:

```sql
-- o trigger calcula o subtotal sozinho
INSERT INTO itens_os (cod_ordem_serv, cod_servico, quantidade) VALUES (1, 2, 3);

-- a procedure consolida o total da OS
CALL proc_atualiza_valor_os(1);
SELECT valor_total FROM ordens_serv WHERE cod_ordem_serv = 1;

-- a função lista os serviços
SELECT * FROM FN_SERVICOS_ORDEM(1);
```

## 💡 O que eu aprendi aqui

* `ON DELETE CASCADE` é ótimo para dado dependente (telefone) e perigoso para dado histórico (ordem de serviço).
* `NOT NULL DEFAULT 0` diz "vale zero"; `NULL` diz "não sei". A diferença aparece na primeira soma.
* Trigger para a linha, procedure para o documento: separar as duas escalas deixa cada peça simples.
* Total calculado que mora numa coluna precisa de alguém garantindo a sincronia — ou é o banco, ou uma hora ele mente.
