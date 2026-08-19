# 🎬 Aula 07 — Banco de Streaming: Functions, Procedures e Triggers

> A aula que junta tudo. Schema novo, e sobre ele os três recursos das aulas anteriores trabalhando ao mesmo tempo.

## 🎯 O que essa aula faz

Modela um **catálogo de streaming** — programas de TV, plataformas, usuários e avaliações — e implementa 9 rotinas sobre ele: 3 functions, 3 procedures e 3 triggers.

## 🗺️ O schema

```
PROGRAMATV ──┬──▶ PROG_INFORMACOES   (ficha técnica, 1:1)
             ├──▶ DISPONIBILIDADE ──▶ PLATAFORMA   (N:N)
             └──▶ AVALIACAO ──▶ CONTATOS          (quem avaliou)
```

## ⚙️ As 9 situações

### 🧮 Functions

| # | Função | O que faz |
|---|---|---|
| 1 | `fn_media_avaliacoes(id_programa)` | Média das notas dadas ao programa, arredondada em 2 casas |
| 2 | `fn_programas_por_plataforma(id_plataforma)` | `RETURNS TABLE` com título e ano dos programas da plataforma |
| 3 | `fn_formatar_titulo(id_programa)` | Concatena `Título (Ano)` para relatórios legíveis |

### 🔁 Procedures

| # | Procedure | O que faz |
|---|---|---|
| 4 | Inserir programa | Insere em `PROGRAMATV` **e** a ficha em `PROG_INFORMACOES` na mesma operação |
| 5 | Registrar nota | Insere avaliação, mas lança exceção se a nota não estiver entre 0 e 10 |
| 6 | Atualizar senha | Exige no mínimo 6 caracteres, senão recusa |

### ⚡ Triggers

| # | Trigger | O que faz |
|---|---|---|
| 7 | `fn_log_programatv()` | Grava numa tabela de suporte todo `INSERT` ou `DELETE` em `PROGRAMATV` |
| 8 | `fn_validar_email()` | Antes de inserir/atualizar `CONTATOS`, exige que o email contenha `@` |
| 9 | Bloqueio de plataforma | Impede excluir plataforma que ainda tem programa vinculado |

## 🔑 As três ideias centrais

**Procedure 4 protege a integridade 1:1.** Um programa sem ficha técnica é um dado meio quebrado. Se a aplicação fizer dois `INSERT` separados e o segundo falhar, sobra o programa órfão. Encapsulando os dois na mesma procedure, ou entra tudo ou não entra nada.

**Validação de faixa (procedures 5 e 6) é regra de negócio no banco.** Nota entre 0 e 10, senha com 6+ caracteres:

```sql
IF p_nota < 0 OR p_nota > 10 THEN
    RAISE EXCEPTION 'A nota deve estar entre 0 e 10';
END IF;
```

Poderia estar no front-end — mas aí bastaria alguém rodar um `INSERT` direto para furar. No banco, não tem por onde escapar.

**Trigger 9 é um `ON DELETE RESTRICT` feito à mão.** A chave estrangeira já poderia fazer isso sozinha; escrever como trigger é exercício para entender o mecanismo — e dá o bônus de uma mensagem de erro que explica o motivo, em vez do texto genérico de violação de FK.

## 📁 Arquivos

| Arquivo | O que é |
|---|---|
| `criacao_bd_programas.sql` | DDL do catálogo: programas, plataformas, contatos, avaliações. |
| `inserts_bd_programas.sql` | Massa de dados (programas reais, tipo Breaking Bad). |
| `functions_bd_programas.sql` | **O exercício.** As 9 situações, cada uma com explicação e teste. |

## ▶️ Como rodar

```bash
createdb -U postgres aula07
psql -U postgres -d aula07 -f criacao_bd_programas.sql
psql -U postgres -d aula07 -f inserts_bd_programas.sql
psql -U postgres -d aula07 -f functions_bd_programas.sql
```

Testando:

```sql
SELECT fn_media_avaliacoes(1);
SELECT * FROM fn_programas_por_plataforma(1);
CALL sp_registrar_nota(1, 1, 15);   -- deve falhar: nota fora da faixa
```

> 💡 O teste que **falha de propósito** é o mais importante. Provar que a validação recusa o dado inválido vale mais que provar que ela aceita o válido.

## 💡 O que eu aprendi aqui

* Function, procedure e trigger não competem — cada uma resolve um problema diferente, e um banco maduro usa as três.
* Encapsular inserts relacionados numa procedure é o que garante que a relação 1:1 nunca fique pela metade.
* `RAISE EXCEPTION` com mensagem escrita por você vale muito mais que um erro genérico de constraint na hora de debugar.
* Comentar cada rotina com a *explicação* antes do código (como o script faz) deixa o SQL legível meses depois.
