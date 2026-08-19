# 📦 Trabalhos Avaliativos

> Os dois trabalhos maiores da UC. Partem de um CSV bruto de vendas da Amazon e chegam num banco normalizado com automações rodando sozinhas.

## 🎯 O problema

O ponto de partida é um arquivo `amazon_sales_data 2025.csv` — uma planilha comum, totalmente desnormalizada:

```
Order ID, Date, Product, Category, Price, Quantity, Total Sales,
Customer Name, Customer Location, Payment Method, Status
```

Repare no problema: o nome e a localização do cliente se repetem em **toda** venda que ele fez. Produto, categoria e preço idem. É o retrato clássico da planilha que precisa virar banco.

## 🗂️ Os dois trabalhos

| Trabalho | Foco |
|---|---|
| [**Trabalho 01**](trabalho01) | Normalização: do CSV plano para 3 tabelas relacionadas |
| [**Trabalho 02**](trabalho02) | Automação: views, triggers e fluxos de negócio sobre o schema normalizado |

---

## 🧩 Trabalho 01 — Normalizar

O script `script.vendas.sql` faz o caminho em 4 etapas:

```
CSV  ──▶  amazon_sales_geral  ──▶  clientes + produtos + vendas  ──▶  trigger
        (tabela desnormalizada)      (schema normalizado)        (mantém sincronizado)
```

**Etapa 0 — Landing table.** O CSV entra inteiro numa tabela espelho, `amazon_sales_geral`, com tudo como veio. Essa etapa parece redundante mas é a mais importante: você separa "trazer o dado para dentro" de "organizar o dado". Se a normalização der errado, o bruto continua lá e você tenta de novo sem reimportar nada.

**Etapa 1 — As 3 tabelas.** `clientes`, `produtos` e `vendas`, com as chaves estrangeiras ligando as pontas.

**Etapa 2 — Popular sem duplicar.** Aqui está o truque do trabalho:

```sql
INSERT INTO clientes (nome_cliente, localizacao_cliente) (
    SELECT DISTINCT nome_cliente, localizacao_cliente FROM amazon_sales_geral
);
```

O `DISTINCT` é o que transforma 250 linhas de venda em ~50 clientes únicos. É literalmente a normalização acontecendo: cada cliente passa a existir **uma vez só**, e as vendas apontam para ele.

**Etapa 3 — Trigger de sincronia.** Um gatilho que popula as tabelas normalizadas automaticamente quando algo novo cai na tabela geral.

### Por que `VARCHAR(20)` na data?

```sql
data_venda VARCHAR(20),
```

O CSV traz `14-03-25` — dia-mês-ano com ano de 2 dígitos, que o PostgreSQL não converte sozinho. A escolha aqui foi importar como texto e converter depois, em vez de brigar com o parser na hora da carga. É uma decisão pragmática comum em ETL: **primeiro traga o dado, depois discuta o tipo.**

---

## ⚡ Trabalho 02 — Automatizar

Parte do schema do trabalho 01 e implementa **fluxos de negócio** completos, cada um com suas tabelas de apoio:

| Fluxo | Tabelas de apoio | O que automatiza |
|---|---|---|
| **1 — Fidelidade** | `fidelidade_cliente`, `beneficios_cliente` | Acumula o total comprado e libera desconto por faixa |
| **2 — Estoque** | `estoque` | Baixa a quantidade disponível a cada venda |
| **3 — Cancelamento** | `historico_cancelamentos` | Registra o histórico quando um pedido é cancelado |
| **Auditoria** | `sistema_logs` | Log geral das operações |

O fluxo 1 combina uma `VIEW` com um `TRIGGER`:

```sql
CREATE OR REPLACE VIEW vw_gasto_cliente AS ...
CREATE OR REPLACE FUNCTION trg_fluxo1_insert() RETURNS TRIGGER AS $$ ...
```

A view responde "quanto cada cliente gastou"; o trigger reage a cada nova venda atualizando fidelidade e benefícios. Juntos, o desconto do cliente se mantém correto sem que ninguém precise rodar nada.

### Sobre a duplicata em `trabalho02/`

A pasta contém `script.vendas.parte1.sql` **e** `script.vendas.parte2.sql`. Não é engano: a parte 2 depende do schema da parte 1, e manter a base junto permite rodar o trabalho 02 do zero sem voltar na pasta anterior. A cópia da parte 1 aqui é levemente diferente da original — é a versão revisada que a parte 2 espera.

---

## ▶️ Como rodar

> ⚠️ Os scripts assumem um banco chamado **`codigos_senai`**.

```bash
createdb -U postgres codigos_senai

# Trabalho 01
psql -U postgres -d codigos_senai -f trabalho01/script.vendas.sql

# Trabalho 02 (parte 1 primeiro, sempre)
psql -U postgres -d codigos_senai -f trabalho02/script.vendas.parte1.sql
psql -U postgres -d codigos_senai -f trabalho02/script.vendas.parte2.sql
```

### Carregando o CSV

O `INSERT` do script já traz a massa embutida. Se quiser recarregar a partir do arquivo:

```sql
\copy amazon_sales_geral FROM 'amazon_sales_data 2025.csv' WITH (FORMAT csv, HEADER true);
```

> 💡 Use `\copy` (do psql), não `COPY` (do servidor). O `COPY` lê o arquivo no disco **do servidor** e falha por permissão; o `\copy` lê do seu computador.

## 💡 O que eu aprendi aqui

* Landing table primeiro, normalização depois. Misturar as duas etapas faz você reimportar tudo a cada erro.
* `INSERT ... SELECT DISTINCT` é a normalização na prática: transforma repetição em entidade única.
* Importar data como texto e converter depois costuma ser mais rápido que acertar o parser na carga.
* Trigger + view combinam bem: a view responde a pergunta, o trigger mantém o dado atualizado.
