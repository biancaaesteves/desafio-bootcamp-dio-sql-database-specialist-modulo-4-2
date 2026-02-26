-- =====================================================
-- 02_procedures_company_ecommerce.sql
-- Desafio DIO: Procedures (Company + E-commerce) + Triggers (E-commerce)
-- =====================================================

-- =====================================================
-- PROCEDURE 1 — COMPANY
-- manage_employee (CRUD controlado por opcao)
-- opcao: 1 SELECT | 2 INSERT | 3 UPDATE | 4 DELETE
-- =====================================================

USE company_constraints;

DROP PROCEDURE IF EXISTS manage_employee;

DELIMITER //

CREATE PROCEDURE manage_employee(
    IN opcao INT,
    IN p_ssn CHAR(9),
    IN p_fname VARCHAR(15),
    IN p_lname VARCHAR(15),
    IN p_salary DECIMAL(10,2),
    IN p_dno INT
)
BEGIN
    IF opcao = 1 THEN
        SELECT * FROM employee WHERE Ssn = p_ssn;

    ELSEIF opcao = 2 THEN
        INSERT INTO employee (Ssn, Fname, Lname, Salary, Dno)
        VALUES (p_ssn, p_fname, p_lname, p_salary, p_dno);

    ELSEIF opcao = 3 THEN
        UPDATE employee
        SET Fname = p_fname,
            Lname = p_lname,
            Salary = p_salary,
            Dno = p_dno
        WHERE Ssn = p_ssn;

    ELSEIF opcao = 4 THEN
        DELETE FROM employee WHERE Ssn = p_ssn;
    END IF;
END//

DELIMITER ;

-- CALLs de teste (Company)
CALL manage_employee(2, '999999999', 'Maria', 'Silva', 40000.00, 1);
CALL manage_employee(1, '999999999', NULL, NULL, NULL, NULL);
CALL manage_employee(3, '999999999', 'Maria', 'Souza', 45000.00, 1);
CALL manage_employee(4, '999999999', NULL, NULL, NULL, NULL);



-- =====================================================
-- PROCEDURE 2 — E-COMMERCE
-- manage_product (CRUD controlado por opcao)
-- opcao: 1 SELECT | 2 INSERT | 3 UPDATE | 4 DELETE
-- =====================================================

USE ecommerce;

DROP PROCEDURE IF EXISTS manage_product;

DELIMITER //

CREATE PROCEDURE manage_product(
    IN opcao INT,
    IN p_id INT,
    IN p_categoria VARCHAR(45),
    IN p_descricao VARCHAR(45),
    IN p_valor DECIMAL(10,2)
)
BEGIN
    IF opcao = 1 THEN
        SELECT * FROM produto WHERE idProduto = p_id;

    ELSEIF opcao = 2 THEN
        INSERT INTO produto (idProduto, Categoria, Descricao, Valor)
        VALUES (p_id, p_categoria, p_descricao, p_valor);

    ELSEIF opcao = 3 THEN
        UPDATE produto
        SET Categoria = p_categoria,
            Descricao = p_descricao,
            Valor = p_valor
        WHERE idProduto = p_id;

    ELSEIF opcao = 4 THEN
        DELETE FROM produto WHERE idProduto = p_id;
    END IF;
END//

DELIMITER ;

-- CALLs de teste (E-commerce)
CALL manage_product(2, 100, 'Eletronicos', 'Teclado Mecanico', 299.90);
CALL manage_product(1, 100, NULL, NULL, NULL);
CALL manage_product(3, 100, 'Eletronicos', 'Teclado Gamer RGB', 349.90);
CALL manage_product(4, 100, NULL, NULL, NULL);



-- =====================================================
-- PARTE 2 — TRIGGERS (E-commerce)
-- Entregável:
-- 1) BEFORE DELETE: guardar dados de usuários excluídos
-- 2) BEFORE UPDATE: regra para colaboradores/salário base
--
-- Observação: Seu diagrama não tem "colaborador" com salário,
-- então o script cria a tabela colaborador (mínimo) para o desafio.
-- =====================================================

-- =====================================================
-- 1) BEFORE DELETE — Usuários (cliente) excluindo conta
-- Salvar dados antes de remover
-- =====================================================

CREATE TABLE IF NOT EXISTS deleted_clients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    idCliente INT,
    Nome VARCHAR(45),
    Identificacao VARCHAR(45),
    Endereco VARCHAR(45),
    deleted_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS trg_backup_client_before_delete;

DELIMITER //

CREATE TRIGGER trg_backup_client_before_delete
BEFORE DELETE ON cliente
FOR EACH ROW
BEGIN
    INSERT INTO deleted_clients (idCliente, Nome, Identificacao, Endereco)
    VALUES (OLD.idCliente, OLD.Nome, OLD.Identificacao, OLD.Endereco);
END//

DELIMITER ;

-- TESTE (ajuste o idCliente para um existente)
-- DELETE FROM cliente WHERE idCliente = 1;
-- SELECT * FROM deleted_clients ORDER BY deleted_at DESC;


-- =====================================================
-- 2) BEFORE UPDATE — Colaboradores e salário base
-- Regras enxutas:
-- - Não permitir salário menor que 1412.00 (exemplo)
-- - Sempre arredondar para 2 casas
-- =====================================================

CREATE TABLE IF NOT EXISTS colaborador (
    idColaborador INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(60) NOT NULL,
    salario_base DECIMAL(10,2) NOT NULL
);

DROP TRIGGER IF EXISTS trg_colaborador_before_update_salario;

DELIMITER //

CREATE TRIGGER trg_colaborador_before_update_salario
BEFORE UPDATE ON colaborador
FOR EACH ROW
BEGIN
    -- trava um piso (exemplo) e normaliza casas decimais
    IF NEW.salario_base < 1412.00 THEN
        SET NEW.salario_base = 1412.00;
    END IF;

    SET NEW.salario_base = ROUND(NEW.salario_base, 2);
END//

DELIMITER ;

-- TESTE
INSERT INTO colaborador (nome, salario_base) VALUES ('Ana', 2000.00);
UPDATE colaborador SET salario_base = 1000.00 WHERE idColaborador = 1;
SELECT * FROM colaborador;