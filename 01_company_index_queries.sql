-- =====================================================
-- 01_company_index_queries.sql
-- Desafio DIO: Views + Permissões (Company)
-- + Índices e Queries (Company) conforme combinado
-- =====================================================

USE company_constraints;

-- =====================================================
-- ÍNDICES (conforme regra do desafio anterior)
-- =====================================================

-- employee(Dno): acelera JOIN/agrupamento por departamento
CREATE INDEX idx_employee_dno
ON employee (Dno);

-- dept_locations(Dnumber): acelera JOIN dept_locations -> department
CREATE INDEX idx_dept_locations_dnumber
ON dept_locations (Dnumber);

-- dept_locations(Dlocation): acelera filtros/ordenação por cidade
CREATE INDEX idx_dept_locations_dlocation
ON dept_locations (Dlocation);

-- =====================================================
-- QUERIES (conforme combinado)
-- =====================================================

-- 1) Departamento com maior número de pessoas
SELECT d.Dname,
       COUNT(e.Ssn) AS total_empregados
FROM department d
JOIN employee e ON d.Dnumber = e.Dno
GROUP BY d.Dname
ORDER BY total_empregados DESC
LIMIT 1;

-- 2) Departamentos por cidade (Dlocation está em dept_locations)
SELECT dl.Dlocation,
       d.Dname
FROM dept_locations dl
JOIN department d ON d.Dnumber = dl.Dnumber
ORDER BY dl.Dlocation, d.Dname;

-- 3) Relação de empregados por departamento
SELECT d.Dname,
       e.Fname,
       e.Lname,
       e.Salary
FROM department d
JOIN employee e ON d.Dnumber = e.Dno
ORDER BY d.Dname, e.Fname;

-- =====================================================
-- PARTE 1 — VIEWS (Personalizando acessos)
-- =====================================================

-- 1) Número de empregados por departamento e localidade
-- (employee -> department -> dept_locations)
CREATE OR REPLACE VIEW vw_emp_count_by_dept_location AS
SELECT d.Dnumber,
       d.Dname,
       dl.Dlocation,
       COUNT(e.Ssn) AS total_empregados
FROM department d
JOIN dept_locations dl ON dl.Dnumber = d.Dnumber
LEFT JOIN employee e ON e.Dno = d.Dnumber
GROUP BY d.Dnumber, d.Dname, dl.Dlocation;

-- 2) Lista de departamentos e seus gerentes
CREATE OR REPLACE VIEW vw_departments_managers AS
SELECT d.Dnumber,
       d.Dname,
       CONCAT(m.Fname, ' ', m.Lname) AS manager_name,
       d.Mgr_ssn
FROM department d
LEFT JOIN employee m ON m.Ssn = d.Mgr_ssn;

-- 3) Projetos com maior número de empregados (ordem desc)
CREATE OR REPLACE VIEW vw_projects_most_employees AS
SELECT p.Pnumber,
       p.Pname,
       COUNT(w.Essn) AS total_empregados
FROM project p
LEFT JOIN works_on w ON w.Pno = p.Pnumber
GROUP BY p.Pnumber, p.Pname
ORDER BY total_empregados DESC;

-- 4) Lista de projetos, departamentos e gerentes
CREATE OR REPLACE VIEW vw_projects_departments_managers AS
SELECT p.Pnumber,
       p.Pname,
       d.Dnumber,
       d.Dname,
       CONCAT(m.Fname, ' ', m.Lname) AS manager_name
FROM project p
JOIN department d ON d.Dnumber = p.Dnum
LEFT JOIN employee m ON m.Ssn = d.Mgr_ssn;

-- 5) Quais empregados possuem dependentes e se são gerentes
CREATE OR REPLACE VIEW vw_employees_dependents_is_manager AS
SELECT e.Ssn,
       CONCAT(e.Fname, ' ', e.Lname) AS employee_name,
       COUNT(dep.Dependent_name) AS total_dependentes,
       CASE
         WHEN EXISTS (
           SELECT 1
           FROM department d
           WHERE d.Mgr_ssn = e.Ssn
         ) THEN 'SIM'
         ELSE 'NAO'
       END AS is_manager
FROM employee e
JOIN dependent dep ON dep.Essn = e.Ssn
GROUP BY e.Ssn, e.Fname, e.Lname;

-- =====================================================
-- PERMISSÕES (usuários e grants em views)
-- Regras:
-- - "gerente": acesso a employee/departamento via views (e pode ver gerentes/dept)
-- - "employee": NÃO acessa departamentos/gerentes; só dados básicos de employee (view própria)
-- =====================================================

-- View básica para funcionário (somente dados de employee)
CREATE OR REPLACE VIEW vw_employee_basic AS
SELECT Ssn, Fname, Lname, Sex, Salary, Dno
FROM employee;

-- (Ajuste host/senhas se necessário)
DROP USER IF EXISTS 'gerente'@'localhost';
DROP USER IF EXISTS 'employee_user'@'localhost';

CREATE USER 'gerente'@'localhost' IDENTIFIED BY 'Gerente@123';
CREATE USER 'employee_user'@'localhost' IDENTIFIED BY 'Employee@123';

-- Boas práticas: garantir que não herdem acessos indevidos
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'gerente'@'localhost';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'employee_user'@'localhost';

-- Gerente: acesso às views gerenciais
GRANT SELECT ON company_constraints.vw_emp_count_by_dept_location TO 'gerente'@'localhost';
GRANT SELECT ON company_constraints.vw_departments_managers TO 'gerente'@'localhost';
GRANT SELECT ON company_constraints.vw_projects_most_employees TO 'gerente'@'localhost';
GRANT SELECT ON company_constraints.vw_projects_departments_managers TO 'gerente'@'localhost';
GRANT SELECT ON company_constraints.vw_employees_dependents_is_manager TO 'gerente'@'localhost';
GRANT SELECT ON company_constraints.vw_employee_basic TO 'gerente'@'localhost';

-- Funcionário: somente view básica de employee (sem dept/gerentes)
GRANT SELECT ON company_constraints.vw_employee_basic TO 'employee_user'@'localhost';

FLUSH PRIVILEGES;

-- TESTES (opcional)
-- SHOW GRANTS FOR 'gerente'@'localhost';
-- SHOW GRANTS FOR 'employee_user'@'localhost';