# 👁️ Aula 03 — VIEWS e Operadores SQL

> Uma `VIEW` é uma consulta que ganhou nome. Em vez de reescrever aquele `JOIN` de 5 tabelas toda vez, você escreve uma vez e chama pelo nome.

## 🎯 O que essa aula faz

Cria **10 `VIEWS`** sobre o schema de plano de ensino da [Aula 02](../aula02). O exercício pede que as 8 primeiras exercitem, juntas, quatro famílias de operadores:

| Família | Exemplos usados |
|---|---|
| **Relacionais** | `>`, `>=`, `<`, `=` |
| **Lógicos** | `AND`, `OR`, `NOT` |
| **Agregação** | `COUNT`, `SUM`, `AVG` |
| **Especiais** | `IN`, `BETWEEN`, `LIKE`, `IS NULL` |

## 🔍 Anatomia de uma view

```sql
CREATE OR REPLACE VIEW vw_professores_ativos AS
SELECT p.nome, COUNT(pp.id_plano_ensino) as total_planos
FROM professor p
JOIN plano_prof pp ON p.id_professor = pp.id_professor
JOIN plano_ensino pe ON pp.id_plano_ensino = pe.id_plano_ensino
WHERE pe.ano IN (2024, 2025) AND pe.semestre >= 1
GROUP BY p.nome
HAVING COUNT(pp.id_plano_ensino) > 1;
```

Essa única view usa `COUNT` (agregação), `>=` e `>` (relacional), `AND` (lógico) e `IN` (especial) — os quatro grupos de uma vez.

### `WHERE` vs `HAVING` — a pegadinha da aula

Os dois filtram, mas em momentos diferentes:

* **`WHERE`** filtra **linhas**, *antes* de agrupar. Por isso não pode usar `COUNT()` — no momento em que ele roda, a contagem ainda não existe.
* **`HAVING`** filtra **grupos**, *depois* do `GROUP BY`. É o único lugar onde faz sentido escrever `HAVING COUNT(...) > 1`.

Na prática: "só planos de 2024 e 2025" é `WHERE`. "Só professores com mais de um plano" é `HAVING`.

### Por que passar por `plano_prof`

Note o duplo `JOIN`: `professor` → `plano_prof` → `plano_ensino`. Como a relação é N:N, não existe caminho direto entre professor e plano de ensino — a tabela associativa é obrigatoriamente a ponte.

## 🧹 O `DROP VIEW` do topo

```sql
DROP VIEW IF EXISTS vw_professores_metricas, vw_detalhe_cursos_view CASCADE;
```

`CREATE OR REPLACE VIEW` até substitui uma view existente, mas **falha se as colunas mudarem de nome, tipo ou quantidade**. Como durante o desenvolvimento isso acontece toda hora, o `DROP` no topo evita o erro. O `CASCADE` também derruba views que dependem dessa.

## 📁 Arquivos

| Arquivo | O que é |
|---|---|
| `views_plano_ensino.sql` | As 10 views, cada uma comentada com quais operadores exercita. |

## ▶️ Como rodar

> ⚠️ **Pré-requisito:** o schema da [Aula 02](../aula02) precisa existir neste banco.

```bash
createdb -U postgres aula03
psql -U postgres -d aula03 -f ../aula02/modelagem_plano_ensino.sql
psql -U postgres -d aula03 -f views_plano_ensino.sql
```

Consultando:

```sql
\dv                              -- lista todas as views criadas
SELECT * FROM vw_professores_ativos;
```

> 💡 Como a Aula 02 só cria a estrutura sem popular dados, as views vão retornar vazio até você inserir alguns registros. A estrutura está correta mesmo assim — dá para conferir com `\d+ vw_professores_ativos`.

## 💡 O que eu aprendi aqui

* View não guarda dado, guarda a **pergunta**. Toda consulta a ela roda o SELECT de novo, sempre atualizado.
* `WHERE` é antes do agrupamento, `HAVING` é depois. Trocar os dois é o erro mais comum em SQL com `GROUP BY`.
* Nomear views com prefixo (`vw_`) deixa óbvio no `\dt`/`\dv` o que é tabela e o que é consulta salva.
* Em schema com N:N, todo `JOIN` interessante passa pela tabela associativa.
