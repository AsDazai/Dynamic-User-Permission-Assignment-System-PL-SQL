--to create users table
CREATE TABLE users (
    user_id NUMBER PRIMARY KEY,
    username VARCHAR2(50) NOT NULL,
    password VARCHAR2(50) NOT NULL,
    email VARCHAR2(100),
    status VARCHAR2(20) DEFAULT 'active'  
);

--creating roles tables
CREATE TABLE roles (
    role_id NUMBER PRIMARY KEY,
    role_name VARCHAR2(50) NOT NULL
);

--inset data into roles
INSERT INTO roles (role_id, role_name) VALUES (1, 'User');
INSERT INTO roles (role_id, role_name) VALUES (2, 'Admin');
INSERT INTO roles (role_id, role_name) VALUES (3, 'Employee');


--creating permissions table
CREATE TABLE permissions (
    permission_id NUMBER PRIMARY KEY,
    permission_name VARCHAR2(50) NOT NULL
);

--insert data into permissions
INSERT INTO permissions (permission_id, permission_name) VALUES (1, 'SELECT');
INSERT INTO permissions (permission_id, permission_name) VALUES (2, 'INSERT');
INSERT INTO permissions (permission_id, permission_name) VALUES (3, 'UPDATE');
INSERT INTO permissions (permission_id, permission_name) VALUES (4, 'DELETE');

--create permissions table depending on role as admin,user,employee
CREATE TABLE role_permissions (
    role_id NUMBER,
    permission_id NUMBER,
    FOREIGN KEY (role_id) REFERENCES roles(role_id),
    FOREIGN KEY (permission_id) REFERENCES permissions(permission_id)
);

--insert into that 
--admin
INSERT INTO role_permissions (role_id, permission_id)
SELECT 2, permission_id FROM permissions;
--user
INSERT INTO role_permissions (role_id, permission_id) 
VALUES (1, 1); 
--employee
INSERT INTO role_permissions (role_id, permission_id) 
VALUES (3, 1);  
INSERT INTO role_permissions (role_id, permission_id) 
VALUES (3, 2);  


--to define role of user
CREATE TABLE user_roles (
    user_id NUMBER,
    role_id NUMBER,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

--user role info
INSERT INTO users (username, password, email) 
VALUES ('john_doe', 'password123', 'john@example.com');
INSERT INTO users (username, password, email) 
VALUES ('jane_admin', 'adminpass', 'jane@example.com');

INSERT INTO user_roles (user_id, role_id) 
VALUES (1, 1);  
INSERT INTO user_roles (user_id, role_id) 
VALUES (2, 2);  



--procedure to insert user 
CREATE OR REPLACE PROCEDURE insert_user(
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_email IN VARCHAR2,
    p_role_name IN VARCHAR2
) IS
    v_user_id NUMBER;
    v_role_id NUMBER;
BEGIN  
    INSERT INTO users (username, password, email)
    VALUES (p_username, p_password, p_email)
    RETURNING user_id INTO v_user_id;
    
    SELECT role_id
    INTO v_role_id
    FROM roles
    WHERE role_name = p_role_name;

    INSERT INTO user_roles (user_id, role_id)
    VALUES (v_user_id, v_role_id);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('User inserted successfully with ID: ' || v_user_id);
END;

--insert user
EXEC insert_user('mike_employee', 'emp123', 'mike@example.com', 'Employee');
-- output will be 1. invalid useer , user inserted 



--function to check user permissions that which permissions user have ?

CREATE OR REPLACE FUNCTION check_permission(
    p_username IN VARCHAR2,
    p_permission IN VARCHAR2
) RETURN VARCHAR2 IS
    v_user_id NUMBER;
    v_role_id NUMBER;
    v_permission_id NUMBER;
BEGIN
    SELECT user_id, role_id
    INTO v_user_id, v_role_id
    FROM users u
    JOIN user_roles ur ON u.user_id = ur.user_id
    JOIN roles r ON ur.role_id = r.role_id
    WHERE u.username = p_username;

    SELECT permission_id
    INTO v_permission_id
    FROM permissions
    WHERE permission_name = p_permission;

    DECLARE
        v_permission_exists NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_permission_exists
        FROM role_permissions
        WHERE role_id = v_role_id
          AND permission_id = v_permission_id;

        IF v_permission_exists = 0 THEN
            RETURN 'Permission Denied';
        ELSE
            RETURN 'Permission Granted';
        END IF;
    END;
END;


-- insertion
-- Test=Admin
SELECT check_permission('jane_admin', 'INSERT') FROM dual;  
--retun granted
-- Test User
SELECT check_permission('john_doe', 'INSERT') FROM dual; 
--return denied

--then perform operations of Admin like insert delete update etc with ID.
-- also perform user operations with ID
--ID will differ user and admin


--for admin
INSERT INTO employees (employee_id, employee_name, department) VALUES (1, 'Alice', 'HR');
COMMIT;

UPDATE employees SET department = 'Finance' WHERE employee_id = 1;
COMMIT;

DELETE FROM employees WHERE employee_id = 1;
COMMIT;




--for user
SELECT * FROM employees;

DELETE FROM employees WHERE employee_id = 1;
COMMIT;


























