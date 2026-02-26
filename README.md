# DIO — SQL Database Specialist (Índices, Views, Procedures e Triggers)

## 📌 Entregáveis
Este repositório contém scripts SQL do desafio da DIO, contemplando:
- Índices e consultas (Company)
- Views + permissões de usuários (Company)
- Procedures CRUD com variável `opcao` (Company e E-commerce)
- Triggers de remoção e atualização (E-commerce)

---

## 📂 Arquivos

### 01_company_index_queries.sql
Inclui:
- Índices:
  - `employee(Dno)`
  - `dept_locations(Dnumber)`
  - `dept_locations(Dlocation)`
- Queries:
  - Departamento com maior número de empregados
  - Departamentos por cidade (JOIN com `dept_locations`)
  - Relação de empregados por departamento
- Views:
  - Empregados por departamento e localidade
  - Departamentos e gerentes
  - Projetos com mais empregados (ordem desc)
  - Projetos + departamentos + gerentes
  - Empregados com dependentes e flag se são gerentes
- Permissões:
  - Usuário `gerente`: acesso às views gerenciais
  - Usuário `employee_user`: acesso somente à view básica de employee

---

### 02_procedures_company_ecommerce.sql
Inclui:
- Procedure `manage_employee` (Company) com `opcao`:
  - 1 SELECT | 2 INSERT | 3 UPDATE | 4 DELETE
- Procedure `manage_product` (E-commerce) com `opcao`:
  - 1 SELECT | 2 INSERT | 3 UPDATE | 4 DELETE
- Triggers (E-commerce):
  - `BEFORE DELETE` em `cliente` para salvar registro em `deleted_clients`
  - `BEFORE UPDATE` em `colaborador` para validar/normalizar `salario_base`

---

## ▶️ Como testar rapidamente
1. Execute o arquivo `01_company_index_queries.sql` no banco `company_constraints`
2. Execute o arquivo `02_procedures_company_ecommerce.sql` nos bancos `company_constraints` e `ecommerce`
3. Rode os `CALL` e `INSERT/UPDATE/DELETE` de teste incluídos nos scripts

