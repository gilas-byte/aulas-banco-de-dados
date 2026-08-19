# 🏗️ Aula 02 — Modelagem e DDL

> A aula da fundação. Antes de consultar qualquer coisa, você precisa de um schema que não deixe o dado errado entrar.

## 🎯 O que essa aula faz

Modela do zero o banco de um **plano de ensino** escolar: cursos, professores, unidades curriculares, aulas, capacidades e atividades. São **10 tabelas** com chaves estrangeiras e relacionamentos N:N resolvidos por tabelas associativas.

## 🗺️ O schema

```
curso ──┐
        ├──▶ unidade_curricular ──▶ plano_ensino ──┬──▶ plano_prof ──▶ professor
        │                                          ├──▶ plano_aula ──┬──▶ aula_capacidade ──▶ capacidade
        │                                          │                 └──▶ plano_ativ ──▶ atividade
```

| Grupo | Tabelas |
|---|---|
| **Independentes** (sem FK) | `curso`, `professor`, `capacidade`, `atividade` |
| **Dependentes** | `unidade_curricular`, `plano_ensino`, `plano_aula` |
| **Associativas** (N:N) | `plano_prof`, `aula_capacidade`, `plano_ativ` |

## 🔑 As decisões de modelagem

**A ordem de criação não é arbitrária.** Tabelas sem chave estrangeira vêm primeiro; uma FK não pode apontar para uma tabela que ainda não existe. O script segue exatamente essa ordem: independentes → dependentes → associativas.

**Tabelas associativas resolvem N:N.** Um professor leciona vários planos de ensino, e um plano de ensino tem vários professores. Isso não cabe numa coluna — precisa de `plano_prof`, uma tabela cuja única função é ligar os dois lados. Mesma ideia em `aula_capacidade` e `plano_ativ`.

**`SERIAL PRIMARY KEY` em todas.** O PostgreSQL cria a sequência e o autoincremento sozinho; você nunca precisa gerenciar o próximo ID na mão.

**Restrições que valem a pena reparar:**

```sql
matricula VARCHAR(20) UNIQUE NOT NULL
```

`UNIQUE` impede dois professores com a mesma matrícula, e `NOT NULL` impede professor sem matrícula. São duas regras que passam a existir no banco, não no código da aplicação — ou seja, ninguém consegue burlar, nem por engano nem por SQL manual.

## 🔁 O `DROP` do topo

```sql
DROP TABLE IF EXISTS plano_ativ, aula_capacidade, plano_aula, ... CASCADE;
```

Está lá para o script poder rodar quantas vezes você quiser sem dar erro de "tabela já existe". Repare que a ordem do `DROP` é **o inverso** da criação: primeiro as associativas, por último as independentes. O `CASCADE` derruba junto o que depende delas.

> ⚠️ Isso apaga tudo. Use só num banco de estudo, nunca num banco com dado real.

## 📁 Arquivos

| Arquivo | O que é |
|---|---|
| `modelagem_plano_ensino.sql` | O DDL completo: drop, criação das 10 tabelas e suas constraints. |

## ▶️ Como rodar

```bash
createdb -U postgres aula02
psql -U postgres -d aula02 -f modelagem_plano_ensino.sql
```

Conferindo se deu certo:

```sql
\dt                        -- lista as 10 tabelas
\d plano_prof              -- mostra as FKs da associativa
```

## 💡 O que eu aprendi aqui

* A ordem de criação segue a dependência: quem não depende de ninguém nasce primeiro.
* Relacionamento N:N sempre vira uma terceira tabela. Não tem jeito de espremer numa coluna.
* Constraint no banco é mais forte que validação no código, porque vale para qualquer caminho que o dado tome.
* Deixar um `DROP ... CASCADE` no topo do script de estudo economiza muito retrabalho.

---

➡️ O schema criado aqui é a base da [Aula 03](../aula03), onde ele ganha `VIEWS`.
