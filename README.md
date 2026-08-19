# 🗄️ Database Classes 🐘

> 🇬🇧 **English** below · 🇧🇷 **Português** [mais abaixo](#-aulas-de-banco-de-dados-pt-br-)

![Status](https://img.shields.io/badge/Status-Em%20Desenvolvimento-green?style=flat-square)
![Database](https://img.shields.io/badge/Database-PostgreSQL-blue?style=flat-square)
![SQL](https://img.shields.io/badge/Language-SQL-orange?style=flat-square)

## 🐘 What is a Database?

A database is where data stops being a file and starts being a system. Instead of a spreadsheet anyone can break by accident, you get rules the engine itself enforces: types, relationships, constraints. And instead of opening the file to look for something, you *ask a question* in SQL and the engine decides on its own how to answer it fast.

**`A schema is a promise the database makes about your data — and unlike a comment in the code, it is a promise it actually keeps.`**

## Why does this repository exist?

This is a public repository for my **Database classes** at **SENAI**, so you can see every script I write in class, and learn from them as well.

`Every class folder has its own README.md explaining the schema, the exercise and how to run it.`

## 🗂️ Classes board

| Class | Description | Status |
|---|---|---|
| [Aula 02](aulas/aula02) | 🏗️ Modeling a teaching-plan schema: 10 tables, FKs and N:N relationships. | ✅ Done |
| [Aula 03](aulas/aula03) | 👁️ 8 `VIEWS` exercising relational, logical, aggregation and special operators. | ✅ Done |
| [Aula 04](aulas/aula04) | ⚡ `TRIGGERS`: auto-filling prices and logging sales into an audit table. | ✅ Done |
| [Aula 05](aulas/aula05) | 🔁 `PROCEDURES` in PL/pgSQL: stock control and tax recalculation. | ✅ Done |
| [Aula 06](aulas/aula06) | 🧮 `FUNCTIONS` over the sales database: 6 real-world situations. | ✅ Done |
| [Aula 07](aulas/aula07) | 🎬 A streaming-catalog database with rating functions. | ✅ Done |

### 📦 Beyond the classes

| Folder | Description |
|---|---|
| [Trabalhos](trabalhos) | Graded assignments: migrating an Amazon sales CSV into a normalized schema. |
| [Atividade Complementar](ativ_complementar) | Extra activity for the first exam: company/clients schema with functions. |

## 🛠️ Tech stack

* **Language:** SQL / PL-pgSQL
* **DBMS:** PostgreSQL
* **Client:** VS Code + SQLTools (PostgreSQL driver)
* **System:** Developed and tested on Linux 🐧

## Suit yourself and clone the repository

```bash
git clone "https://github.com/gilas-byte/aulas-banco-de-dados"
```

and if the repository gets an update:

```bash
git pull
```

**Thanks for visiting, happy studying!**

---

# 🗄️ Aulas de Banco de Dados (PT-BR) 🐘

## 🐘 O que é um Banco de Dados?

Banco de dados é onde o dado deixa de ser arquivo e vira sistema. No lugar de uma planilha que qualquer um quebra sem querer, você ganha regras que o próprio banco faz cumprir: tipos, relacionamentos, restrições. E em vez de abrir o arquivo pra procurar alguma coisa, você *faz uma pergunta* em SQL e o banco decide sozinho como respondê-la rápido.

**`Um schema é uma promessa que o banco faz sobre os seus dados — e, diferente de um comentário no código, é uma promessa que ele realmente cumpre.`**

## Por que este repositório existe?

Este é um repositório público das minhas **aulas de Banco de Dados** no **SENAI**, para que você possa ver todos os scripts que faço em aula, e aprender com eles também.

`Toda pasta de aula tem o seu próprio README.md explicando o schema, o exercício e como rodar.`

## 🗂️ Quadro de aulas

| Aula | Descrição | Status |
|---|---|---|
| [Aula 02](aulas/aula02) | 🏗️ Modelagem do schema de plano de ensino: 10 tabelas, FKs e relações N:N. | ✅ Concluído |
| [Aula 03](aulas/aula03) | 👁️ 8 `VIEWS` exercitando operadores relacionais, lógicos, de agregação e especiais. | ✅ Concluído |
| [Aula 04](aulas/aula04) | ⚡ `TRIGGERS`: preenchimento automático de preços e log de vendas em tabela de auditoria. | ✅ Concluído |
| [Aula 05](aulas/aula05) | 🔁 `PROCEDURES` em PL/pgSQL: controle de estoque e recálculo de impostos. | ✅ Concluído |
| [Aula 06](aulas/aula06) | 🧮 `FUNCTIONS` sobre o banco de vendas: 6 situações do mundo real. | ✅ Concluído |
| [Aula 07](aulas/aula07) | 🎬 Banco de catálogo de streaming com funções de avaliação. | ✅ Concluído |

### 📦 Além das aulas

| Pasta | Descrição |
|---|---|
| [Trabalhos](trabalhos) | Trabalhos avaliativos: migração de um CSV de vendas da Amazon para um schema normalizado. |
| [Atividade Complementar](ativ_complementar) | Atividade extra da prova 1: schema de empresa/clientes com funções. |

## 🛠️ Tecnologias e ambiente

* **Linguagem:** SQL / PL-pgSQL
* **SGBD:** PostgreSQL
* **Cliente:** VS Code + SQLTools (driver PostgreSQL)
* **Sistema:** Desenvolvido e testado rodando liso no Linux 🐧

## 🚀 Como rodar qualquer aula

Cada aula é independente e traz o seu próprio banco. O caminho é sempre o mesmo:

```bash
# 1. crie um banco vazio para a aula
createdb -U postgres aula04

# 2. rode os scripts na ordem indicada no README da aula
psql -U postgres -d aula04 -f aulas/aula04/bd_vendas_create.sql
psql -U postgres -d aula04 -f aulas/aula04/bd_vendas_insert.sql
psql -U postgres -d aula04 -f aulas/aula04/triggers.sql
```

> 💡 **A ordem importa sempre:** primeiro o `create` (estrutura), depois o `insert` (dados), só então o script do exercício. Rodar fora de ordem gera erro de tabela inexistente ou de chave estrangeira.

Se preferir a interface gráfica, o VS Code com a extensão **SQLTools** + driver **PostgreSQL** roda tudo pelo botão de play.

## Sinta-se à vontade para clonar o repositório

```bash
git clone "https://github.com/gilas-byte/aulas-banco-de-dados"
```

e se o repositório tiver alguma atualização:

```bash
git pull
```

**Obrigado pela visita, bons estudos!**
