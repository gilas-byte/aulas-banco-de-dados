# 🔁 Aula 05 — PROCEDURES e Lógica no Banco

> `FUNCTION` responde uma pergunta. `PROCEDURE` executa uma tarefa. A diferença parece sutil até a primeira vez que você precisa dar `COMMIT` no meio do caminho.

## 🎯 O que essa aula faz

Continua no banco de **vendas** e implementa rotinas em PL/pgSQL: finalizar venda, controlar estoque, recalcular impostos e consolidar totais. Inclui duas resoluções lado a lado — a minha e a de um colega — o que é ótimo para comparar abordagens diferentes para o mesmo problema.

## ⚖️ FUNCTION vs PROCEDURE

| | `FUNCTION` | `PROCEDURE` |
|---|---|---|
| **Retorna valor** | Sim, sempre | Não (usa `INOUT` se precisar devolver algo) |
| **Como chama** | `SELECT fn_x(1);` | `CALL sp_x(1);` |
| **Dentro de um SELECT** | Pode | Não pode |
| **Controla transação** | Não | **Sim** — pode dar `COMMIT` / `ROLLBACK` |

A regra prática: se você quer **um valor**, é function. Se você quer **um efeito** (alterar várias tabelas, controlar transação), é procedure.

O `sp_finalizar_venda` é procedure justamente porque ele *faz* coisas: soma o carrinho, atualiza o total da venda, marca como finalizada e baixa o estoque. Não há "um valor" para retornar.

## 🧱 A estrutura de um bloco PL/pgSQL

```sql
CREATE OR REPLACE PROCEDURE sp_finalizar_venda(p_id_venda INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_total DECIMAL(10,2);      -- variáveis vivem aqui
BEGIN
    SELECT SUM(...) INTO v_total FROM carrinho_venda WHERE ...;
    UPDATE venda SET sub_total = v_total WHERE id_venda = p_id_venda;
END;
$$;
```

Três convenções que valem adotar desde já:

* **`$$ ... $$`** delimita o corpo. Sem isso você teria que escapar cada aspa simples de dentro do código — um inferno.
* **`p_`** para parâmetros, **`v_`** para variáveis locais. Sem esse prefixo, um parâmetro chamado `id_venda` colide com a coluna `id_venda` e o PostgreSQL não sabe a qual você se refere.
* **`SELECT ... INTO`** é como se guarda o resultado de uma consulta numa variável.

## 📁 Arquivos

| Arquivo | O que é |
|---|---|
| `create_gilas.sql` | Schema base: profissão, marca, tipo, produto, cliente, venda, carrinho. |
| `bd_vendas_create.sql` | Estrutura do banco de vendas. |
| `bd_vendas_insert.sql` | Massa de dados de teste. |
| `procedure_gilas.sql` | **Minha resolução.** Começa com `UPDATE`s que preparam o cenário — deixa o estoque de dois produtos abaixo do mínimo, de propósito, para conseguir testar o alerta. |
| `procedure_samuel.sql` | Resolução de um colega, com 6 situações: total de carrinho, média por cliente, produtos por faixa de preço, vendas por período, `sp_finalizar_venda` e triggers. |

## 🧪 O detalhe do cenário de teste

O `procedure_gilas.sql` abre com uma série de `UPDATE`s aparentemente aleatórios:

```sql
-- Deixando o estoque do produto 1 no vermelho
UPDATE produto SET quantidade_atual = 5, quantidade_minima = 20 WHERE id_produto = 1;
```

Isso não é sujeira, é **preparação de cenário**. A massa de dados original tem estoque saudável em tudo, então a procedure de alerta nunca dispararia e você não teria como provar que ela funciona. Forçar o caso de borda é parte do teste.

## ▶️ Como rodar

```bash
createdb -U postgres aula05
psql -U postgres -d aula05 -f bd_vendas_create.sql
psql -U postgres -d aula05 -f bd_vendas_insert.sql
psql -U postgres -d aula05 -f procedure_gilas.sql
```

Chamando uma procedure (repare: `CALL`, não `SELECT`):

```sql
CALL sp_finalizar_venda(1);
SELECT * FROM venda WHERE id_venda = 1;   -- confere o total calculado
```

## 💡 O que eu aprendi aqui

* Function devolve valor, procedure executa tarefa. Tentar usar `SELECT` numa procedure dá erro na hora.
* Prefixar parâmetro com `p_` evita colisão com nome de coluna — um bug silencioso e chatíssimo de achar.
* Preparar o cenário antes de testar é tão importante quanto a procedure. Código que nunca entra no caso de borda não foi testado.
* Comparar a resolução de outra pessoa para o mesmo problema ensina mais rápido do que escrever a sua sozinho.

---

➡️ A [Aula 06](../aula06) fecha o banco de vendas com `FUNCTIONS`.
