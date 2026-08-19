# 🧮 Aula 06 — FUNCTIONS (Presencial)

> Seis situações de negócio, seis funções. É a aula em que o SQL para de ser consulta e vira biblioteca reutilizável.

## 🎯 O que essa aula faz

Resolve **6 situações reais** sobre o banco de vendas, cada uma virando uma `FUNCTION` PL/pgSQL testada logo abaixo da própria definição.

| # | Função | Retorna | Situação |
|---|---|---|---|
| 1 | `fn_total_venda(id_venda)` | `DECIMAL` | Valor total de uma venda somando os itens do carrinho |
| 2 | `fn_endereco_completo(id_cliente)` | `TEXT` | Endereço concatenado e formatado numa linha só |
| 3 | `fn_produto_mais_vendido()` | `TABLE` | O campeão de vendas |
| 4 | `fn_desconto_progressivo(...)` | `DECIMAL` | Desconto por faixa de valor |
| 5 | `fn_total_gasto_cliente(id_cliente)` | `DECIMAL` | Quanto um cliente já gastou no total |
| 6 | `fn_status_estoque(id_produto)` | `TEXT` | Classifica o estoque em normal / baixo / esgotado |

## 🔧 O pré-requisito no topo do script

O script abre com um `UPDATE` grande e comentado:

```sql
-- PRE-REQUISITO: Populando campos faltantes da tabela PRODUTO
-- O INSERT original nao preencheu valor_unitario,
-- quantidade_atual e quantidade_minima.
-- Este UPDATE e necessario para a Situacao 6 funcionar.
UPDATE produto SET
    valor_unitario = CASE id_produto
        WHEN 1 THEN 7999.99  WHEN 2 THEN 4999.99  ...
    END,
```

Vale entender por que isso existe: a massa de dados original deixou `valor_unitario`, `quantidade_atual` e `quantidade_minima` nulos. A função 6 classifica estoque comparando quantidade atual com a mínima — e **qualquer comparação com `NULL` resulta em `NULL`**, nunca em verdadeiro ou falso. Sem preencher esses campos, a função não daria erro: ela retornaria `NULL` silenciosamente, que é bem pior que um erro.

O `CASE ... WHEN` dentro do `UPDATE` é o jeito de dar um valor diferente para cada produto numa tacada só, em vez de escrever 20 `UPDATE`s.

## 📐 `RETURNS` simples vs `RETURNS TABLE`

A maior parte das funções devolve um escalar:

```sql
CREATE OR REPLACE FUNCTION fn_total_venda(p_id_venda INT)
RETURNS DECIMAL AS $$ ... $$
```

Mas a `fn_produto_mais_vendido()` precisa devolver **várias colunas**:

```sql
RETURNS TABLE(nome VARCHAR, total_vendido BIGINT) AS $$
BEGIN
    RETURN QUERY SELECT ... ;
END;
```

Duas mudanças andam juntas: declara-se `RETURNS TABLE(...)` com as colunas nomeadas, e usa-se `RETURN QUERY` no lugar de `RETURN`. Chamar continua igual, mas o resultado é uma tabela de verdade:

```sql
SELECT * FROM fn_produto_mais_vendido();
```

## 🛡️ `COALESCE` — o hábito que evita bug

Um padrão que aparece o tempo todo nas funções:

```sql
SELECT COALESCE(SUM(valor), 0) INTO v_total FROM ...;
```

`SUM()` sobre zero linhas retorna `NULL`, não zero. Se um cliente nunca comprou nada, `fn_total_gasto_cliente` devolveria `NULL` — e aí qualquer conta feita em cima disso (`NULL + 10`) também vira `NULL`, propagando o problema silenciosamente. `COALESCE` corta isso na raiz.

## 📁 Arquivos

| Arquivo | O que é |
|---|---|
| `bd_vendas_create.sql` | Estrutura do banco de vendas. |
| `bd_vendas_insert.sql` | Massa de dados de teste. |
| `create_gilas.sql` | Schema base complementar. |
| `functions_bd_vendas.sql` | **O exercício.** O `UPDATE` de pré-requisito + as 6 funções, cada uma com seus testes. |
| `exercicio_06.pdf` | Enunciado da atividade presencial. |

## ▶️ Como rodar

```bash
createdb -U postgres aula06
psql -U postgres -d aula06 -f bd_vendas_create.sql
psql -U postgres -d aula06 -f bd_vendas_insert.sql
psql -U postgres -d aula06 -f functions_bd_vendas.sql
```

Testando:

```sql
SELECT fn_total_venda(1);
SELECT fn_status_estoque(3);
SELECT * FROM fn_produto_mais_vendido();
```

## 💡 O que eu aprendi aqui

* `NULL` não é zero nem vazio: é "desconhecido". Toda comparação com ele dá `NULL`, e o resultado é um bug que não levanta erro.
* `COALESCE` em volta de `SUM`/`AVG` deveria ser reflexo.
* `RETURNS TABLE` + `RETURN QUERY` é o que permite uma função devolver conjunto em vez de escalar.
* Deixar o teste logo abaixo de cada função transforma o script em documentação executável — quem lê vê o uso junto da definição.
