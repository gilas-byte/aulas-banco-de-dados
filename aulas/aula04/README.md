# ⚡ Aula 04 — TRIGGERS e Auditoria

> Trigger é código que o banco dispara sozinho. Você não chama — ele acontece, quer você queira ou não. É a diferença entre "lembrar de validar" e "não conseguir esquecer".

## 🎯 O que essa aula faz

Introduz o banco de **vendas** (`bd_vendas`) e coloca três gatilhos para trabalhar sobre ele: preenchimento automático de preço, bloqueio de alteração indevida e registro de auditoria.

## 🧩 A anatomia de um trigger no PostgreSQL

No PostgreSQL um trigger são **sempre duas peças**, e essa é a primeira coisa que confunde:

```sql
-- 1) a FUNÇÃO: contém a lógica, retorna TRIGGER
CREATE OR REPLACE FUNCTION fn_busca_preco_produto()
RETURNS TRIGGER AS $$ ... $$ LANGUAGE plpgsql;

-- 2) o GATILHO: liga a função a uma tabela e a um evento
CREATE TRIGGER trg_busca_preco
BEFORE INSERT ON carrinho_venda
FOR EACH ROW EXECUTE FUNCTION fn_busca_preco_produto();
```

A função sozinha não faz nada. O gatilho sozinho não existe. Só o par funciona.

### `NEW` e `OLD`

Dentro da função você recebe duas variáveis mágicas:

* **`NEW`** — a linha como ela **vai ficar** (disponível em `INSERT` e `UPDATE`).
* **`OLD`** — a linha como ela **era** (disponível em `UPDATE` e `DELETE`).

### `BEFORE` vs `AFTER` — a decisão que importa

| | Quando usar |
|---|---|
| **`BEFORE`** | Quando você quer **modificar** ou **impedir** a operação. É o único momento em que alterar `NEW` tem efeito, e em que dar `RAISE EXCEPTION` cancela tudo. |
| **`AFTER`** | Quando a operação já é certa e você só quer **reagir** a ela — tipicamente gravar log. |

Preencher preço é `BEFORE` (precisa alterar `NEW` antes de gravar). Registrar auditoria é `AFTER` (só faz sentido logar o que de fato aconteceu).

## ⚙️ Os três triggers

| # | Trigger | Momento | O que faz |
|---|---|---|---|
| 1 | `trg_busca_preco` | `BEFORE INSERT` | Busca o preço na tabela `produto` e preenche sozinho no item do carrinho — o usuário não digita preço, então não tem como digitar errado. |
| 2 | `trg_bloqueia_alteracao_item` | `BEFORE UPDATE` | Impede mexer em item de venda já finalizada, com `RAISE EXCEPTION`. |
| 3 | `trg_auditoria_venda` | `AFTER` | Grava cada venda na tabela `log_venda`: quem, quando, quanto. |

O trigger 2 é o exemplo mais claro de regra que **não deveria** viver na aplicação: se a regra está no banco, nem um `UPDATE` manual pelo psql consegue furá-la.

## 📁 Arquivos

| Arquivo | O que é |
|---|---|
| `bd_vendas_create.sql` | Estrutura do banco de vendas: clientes, produtos, vendas, carrinho. |
| `bd_vendas_insert.sql` | Massa de dados para teste. |
| `triggers.sql` | Os 3 triggers (função + gatilho de cada) e os testes de cada um. |
| `trigger_log_venda.sql` | A tabela `log_venda` e o trigger de auditoria, na versão da atividade 4. |

## ▶️ Como rodar

```bash
createdb -U postgres aula04
psql -U postgres -d aula04 -f bd_vendas_create.sql
psql -U postgres -d aula04 -f bd_vendas_insert.sql
psql -U postgres -d aula04 -f triggers.sql
```

A ordem é obrigatória: o trigger referencia tabelas que só existem depois do `create`, e os testes no fim do script dependem dos dados do `insert`.

Conferindo:

```sql
\dft                                    -- funções de trigger criadas
SELECT * FROM log_venda;                -- auditoria preenchida pelo trigger 3
```

## 💡 O que eu aprendi aqui

* No PostgreSQL trigger é sempre função + gatilho. Nunca só um dos dois.
* `BEFORE` altera e cancela; `AFTER` observa. Escolher errado faz o trigger simplesmente não surtir efeito.
* `RAISE EXCEPTION` dentro de um `BEFORE` cancela a transação inteira — é assim que se cria uma regra impossível de burlar.
* Trigger é poderoso e por isso perigoso: como roda invisível, um trigger mal escrito vira um bug que ninguém acha lendo o código da aplicação.

---

➡️ A [Aula 05](../aula05) continua no mesmo banco de vendas, agora com `PROCEDURES`.
