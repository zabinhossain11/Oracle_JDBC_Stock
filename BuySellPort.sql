

****************************** STOCK_TRANSACTIONS *********************

CREATE TABLE STOCK_TRANSACTIONS (
    transaction_id  NUMBER PRIMARY KEY,
    user_id         NUMBER NOT NULL,
    company_id      NUMBER NOT NULL,
    quantity        NUMBER NOT NULL,
    purchase_price  NUMBER NOT NULL,
    transaction_date DATE DEFAULT SYSDATE,
    FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);

-- Create sequence for STOCK_TRANSACTIONS table
CREATE SEQUENCE transaction_seq
START WITH 1
INCREMENT BY 1;


************************************   PORTFOLIO_ITEMS     *******************

CREATE TABLE PORTFOLIO_ITEMS (
    item_id NUMBER PRIMARY KEY,
    portfolio_id NUMBER NOT NULL,
    company_id NUMBER NOT NULL,
    quantity NUMBER NOT NULL,
    FOREIGN KEY (portfolio_id) REFERENCES PORTFOLIO(portfolio_id),
    FOREIGN KEY (company_id) REFERENCES COMPANIES(company_id)
);

CREATE SEQUENCE portfolio_items_seq START WITH 1 INCREMENT BY 1;

******************************* BUY SYSTEM   ***********************************

CREATE OR REPLACE PROCEDURE buy_stock (
    p_user_id NUMBER,
    p_company_id NUMBER,
    p_quantity NUMBER
)
IS
    l_stock_price NUMBER;
    l_total_cost NUMBER;
    l_portfolio_id NUMBER;
BEGIN
    -- Get the stock price and available quantity
    SELECT stock_price INTO l_stock_price FROM NEWCOMPANY WHERE company_id = p_company_id;

    l_total_cost := l_stock_price * p_quantity;

    -- Check if user has enough balance
    DECLARE
        l_user_balance NUMBER;
    BEGIN
        SELECT wallet INTO l_user_balance FROM PORTFOLIO WHERE user_id = p_user_id;
        IF l_user_balance < l_total_cost THEN
            RAISE_APPLICATION_ERROR(-20001, 'Insufficient balance');
        END IF;
    END;

    -- Update user balance
    UPDATE PORTFOLIO SET wallet = wallet - l_total_cost WHERE user_id = p_user_id;

    -- Update company stock quantity
    UPDATE NEWCOMPANY SET stock_quantity = stock_quantity - p_quantity WHERE company_id = p_company_id;

    -- Check if the user has a portfolio
    BEGIN
        SELECT portfolio_id INTO l_portfolio_id FROM PORTFOLIO WHERE user_id = p_user_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Create a new portfolio if not exists
            INSERT INTO PORTFOLIO (portfolio_id, user_id)
            VALUES (portfolio_seq.NEXTVAL, p_user_id);
            SELECT portfolio_seq.CURRVAL INTO l_portfolio_id FROM dual;
    END;

    -- Check if the company is already in the user's portfolio
    BEGIN
        UPDATE PORTFOLIO_ITEMS
        SET quantity = quantity + p_quantity
        WHERE portfolio_id = l_portfolio_id AND company_id = p_company_id;

        IF SQL%NOTFOUND THEN
            -- Insert new record if not exists
            INSERT INTO PORTFOLIO_ITEMS (item_id, portfolio_id, company_id, quantity)
            VALUES (portfolio_items_seq.NEXTVAL, l_portfolio_id, p_company_id, p_quantity);
        END IF;
    END;

    -- Display success message
    DBMS_OUTPUT.PUT_LINE('Stock purchase successful for user ' || p_user_id || '.');
END;
/


**************************** View Portfolio *******************

CREATE OR REPLACE PROCEDURE view_portfolio (
    p_user_id NUMBER,
    p_cursor OUT SYS_REFCURSOR
)
IS
BEGIN
    OPEN p_cursor FOR
    SELECT p.username, p.email, p.bank_account, p.contact_number, p.wallet,
           pi.company_id, c.company_name, pi.quantity
    FROM PORTFOLIO p
    JOIN PORTFOLIO_ITEMS pi ON p.portfolio_id = pi.portfolio_id
    JOIN NEWCOMPANY c ON pi.company_id = c.company_id
    WHERE p.user_id = p_user_id;
END;
/




*********************************  sell system *******************

CREATE OR REPLACE PROCEDURE sell_stock (
    p_user_id NUMBER,
    p_company_id NUMBER,
    p_quantity NUMBER
)
IS
    l_stock_price NUMBER;
    l_total_gain NUMBER;
    l_portfolio_id NUMBER;
    v_quantity NUMBER;
BEGIN
    -- Retrieve the portfolio ID for the user
    BEGIN
        SELECT portfolio_id INTO l_portfolio_id
        FROM PORTFOLIO
        WHERE user_id = p_user_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'User does not have a portfolio');
    END;

    -- Check if the user owns enough stocks to sell
    BEGIN
        SELECT quantity INTO v_quantity
        FROM PORTFOLIO_ITEMS
        WHERE portfolio_id = l_portfolio_id AND company_id = p_company_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'User does not own stocks of this company to sell');
    END;

    IF v_quantity < p_quantity THEN
        RAISE_APPLICATION_ERROR(-20003, 'User does not own enough stocks of this company to sell');
    END IF;

    -- Proceed with selling stocks
    -- Get the stock price
    SELECT stock_price INTO l_stock_price FROM NEWCOMPANY WHERE company_id = p_company_id;

    -- Calculate the total gain from selling stocks
    l_total_gain := l_stock_price * p_quantity;

    -- Update user balance with the gained amount
    UPDATE PORTFOLIO SET wallet = wallet + l_total_gain WHERE portfolio_id = l_portfolio_id;

    -- Update company stock quantity
    UPDATE NEWCOMPANY SET stock_quantity = stock_quantity + p_quantity WHERE company_id = p_company_id;

    -- Update the user's portfolio for the sold stocks
    UPDATE PORTFOLIO_ITEMS SET quantity = quantity - p_quantity
    WHERE portfolio_id = l_portfolio_id AND company_id = p_company_id;

    -- Display success message
    DBMS_OUTPUT.PUT_LINE('Stock sold successfully for user ' || p_user_id || '.');
END;
/

