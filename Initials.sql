#### SIGNUP & LOGIN ####



**************************   USERS    ***********************

-- Create USERS table without identity
CREATE TABLE USERS (
    user_id NUMBER PRIMARY KEY,
    username VARCHAR2(50) UNIQUE NOT NULL,
    password VARCHAR2(100) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL
);


************************   PORTFOLIO    *****************************


CREATE TABLE PORTFOLIO (
    portfolio_id    NUMBER PRIMARY KEY,
    user_id         NUMBER NOT NULL,
    username        VARCHAR2(50) NOT NULL,
    password        VARCHAR2(50) NOT NULL,
    email           VARCHAR2(100) NOT NULL,
    bank_account    VARCHAR2(50) NOT NULL,
    contact_number  VARCHAR2(20) NOT NULL,
    wallet          NUMBER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);

-- Create sequence for PORTFOLIO table
CREATE SEQUENCE portfolio_seq
START WITH 1
INCREMENT BY 1;

**********************   USERS TRIGGER  ************************************

-- Create trigger for USERS table
CREATE OR REPLACE TRIGGER trg_user_id
BEFORE INSERT ON USERS
FOR EACH ROW
BEGIN
    SELECT user_seq.NEXTVAL INTO :NEW.user_id FROM dual;
END;
/

************************ PORTFOLIO TRIGGER    *****************


-- Create trigger for PORTFOLIO table
CREATE OR REPLACE TRIGGER trg_portfolio_id
BEFORE INSERT ON PORTFOLIO
FOR EACH ROW
BEGIN
    SELECT portfolio_seq.NEXTVAL INTO :NEW.portfolio_id FROM dual;
END;
/


********************** SIGN UP SYSTEM **************************

CREATE OR REPLACE PROCEDURE users_signup (
    p_username       IN VARCHAR2,
    p_password       IN VARCHAR2,
    p_email          IN VARCHAR2,
    p_bank_account   IN VARCHAR2,
    p_contact_number IN VARCHAR2,
    p_wallet         IN NUMBER
) AS
    v_user_id NUMBER;
BEGIN
    -- Insert the new user into the USERS table
    INSERT INTO USERS (username, password, email)
    VALUES (p_username, p_password, p_email)
    RETURNING user_id INTO v_user_id;

    -- Insert a new portfolio entry for the new user with empty company name
    INSERT INTO PORTFOLIO (portfolio_id, user_id, username, password, email, bank_account, contact_number, wallet, company_name)
    VALUES (portfolio_seq.NEXTVAL, v_user_id, p_username, p_password, p_email, p_bank_account, p_contact_number, p_wallet, NULL);

    COMMIT;
END;

****************************** LOGIN SYSTEM *********************

-- Create stored procedure for user login
CREATE OR REPLACE PROCEDURE user_login (
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_user_id OUT NUMBER
) IS
    v_user_id USERS.user_id%TYPE;
BEGIN
    SELECT user_id INTO v_user_id
    FROM USERS
    WHERE username = p_username AND password = p_password;

    p_user_id := v_user_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_user_id := NULL;
END;
/


************************** NEW COMPANY *******************

// company new table
CREATE TABLE NEWCOMPANY (
    company_id     NUMBER PRIMARY KEY,
    company_name   VARCHAR2(100) NOT NULL,
    stock_price    NUMBER NOT NULL,
    stock_quantity NUMBER NOT NULL
);

-- Create sequence for NEWCOMPANY table
CREATE SEQUENCE company_seq
START WITH 1
INCREMENT BY 1;

-- Insert sample data into NEWCOMPANY table
INSERT INTO NEWCOMPANY (company_id, company_name, stock_price, stock_quantity) VALUES (company_seq.NEXTVAL, 'Company Grameenphone Ltd.', 300, 1000000000);
INSERT INTO NEWCOMPANY (company_id, company_name, stock_price, stock_quantity) VALUES (company_seq.NEXTVAL, 'Company Beximco Pharmaceuticals Ltd.', 150, 1500000);
INSERT INTO NEWCOMPANY (company_id, company_name, stock_price, stock_quantity) VALUES (company_seq.NEXTVAL, 'Company Square Pharmaceuticals Ltd.', 200, 20000000);
INSERT INTO NEWCOMPANY (company_id, company_name, stock_price, stock_quantity) VALUES (company_seq.NEXTVAL, 'Company BRAC Bank Ltd.', 120, 50000000);
INSERT INTO NEWCOMPANY (company_id, company_name, stock_price, stock_quantity) VALUES (company_seq.NEXTVAL, 'Company Robi Axiata Ltd.', 200, 9000000);
INSERT INTO NEWCOMPANY (company_id, company_name, stock_price, stock_quantity) VALUES (company_seq.NEXTVAL, 'Company Renata Limited', 250, 356000);
INSERT INTO NEWCOMPANY (company_id, company_name, stock_price, stock_quantity) VALUES (company_seq.NEXTVAL, 'Company Grameen Bank', 120, 400090);
INSERT INTO NEWCOMPANY (company_id, company_name, stock_price, stock_quantity) VALUES (company_seq.NEXTVAL, 'Company IDLC Finance Ltd.',400, 500000);
INSERT INTO NEWCOMPANY (company_id, company_name, stock_price, stock_quantity) VALUES (company_seq.NEXTVAL, 'Company Bangladesh Submarine Cable Company Limited', 900, 2000);
INSERT INTO NEWCOMPANY (company_id, company_name, stock_price, stock_quantity) VALUES (company_seq.NEXTVAL, 'Company Eastern Bank Ltd.', 750, 1000000);

COMMIT;

******************************   COMPANY LIST VIEW   *********************

CREATE OR REPLACE PROCEDURE get_company_details (
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
    SELECT company_id, company_name
    FROM NEWCOMPANY;
END;
/


************************ VIEW COMPANY DETAILS *********************

CREATE OR REPLACE PROCEDURE get_company_details_by_id (
    p_company_id NUMBER,
    p_cursor OUT SYS_REFCURSOR
)
AS
BEGIN
    OPEN p_cursor FOR
    SELECT company_id, company_name, stock_price, stock_quantity
    FROM NEWCOMPANY
    WHERE company_id = p_company_id;
END;
/