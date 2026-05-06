CREATE DATABASE IF NOT EXISTS bakery_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
drop database bakery_db;


-- ============================================================
--  1. АЖИЛТНУУД (users)
-- ============================================================
CREATE TABLE users (
    user_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(100)  NOT NULL,
    username      VARCHAR(50)   NOT NULL UNIQUE,
    password_hash VARCHAR(255)  NOT NULL,
    role          ENUM('admin','manager','cashier') NOT NULL DEFAULT 'cashier',
    phone         VARCHAR(20)   NULL,
    email         VARCHAR(100)  NULL,
    is_active     TINYINT(1)   NOT NULL DEFAULT 1,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
--  2. БАРААНЫ АНГИЛАЛ (categories)
-- ============================================================
CREATE TABLE categories (
    category_id   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    description   TEXT         NULL,
    is_active     TINYINT(1)  NOT NULL DEFAULT 1,
    created_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
--  3. БАРАА (products)
-- ============================================================
CREATE TABLE  products (
    product_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code          VARCHAR(20)   NOT NULL UNIQUE,
    name          VARCHAR(200)  NOT NULL,
    category_id   INT UNSIGNED  NOT NULL,
    price         DECIMAL(12,2) NOT NULL,
    cost_price    DECIMAL(12,2) NULL,
    stock_qty     INT           NOT NULL DEFAULT 0,
    min_stock     INT           NOT NULL DEFAULT 10,
    unit          VARCHAR(20)   NOT NULL DEFAULT 'ширхэг',
    description   TEXT          NULL,
    is_active     TINYINT(1)   NOT NULL DEFAULT 1,
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- ============================================================
--  4. НӨӨЦИЙН ХӨДӨЛГӨӨН (stock_movements)
-- ============================================================
CREATE TABLE IF NOT EXISTS stock_movements (
    movement_id   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id    INT UNSIGNED NOT NULL,
    user_id       INT UNSIGNED NOT NULL,
    type          ENUM('in','out','adjustment','return') NOT NULL,
    qty           INT          NOT NULL,
    qty_before    INT          NOT NULL,
    qty_after     INT          NOT NULL,
    note          TEXT         NULL,
    moved_at      DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (user_id)    REFERENCES users(user_id)
);

-- ============================================================
--  5. ГҮЙЛГЭЭ (sales)
-- ============================================================
CREATE TABLE IF NOT EXISTS sales (
    sale_id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sale_code       VARCHAR(20)   NOT NULL UNIQUE,
    cashier_id      INT UNSIGNED  NOT NULL,
    total_amount    DECIMAL(12,2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    final_amount    DECIMAL(12,2) NOT NULL DEFAULT 0,
    payment_method  ENUM('cash','card','qr','transfer') NOT NULL DEFAULT 'cash',
    payment_status  ENUM('paid','pending','refunded') NOT NULL DEFAULT 'paid',
    status          ENUM('completed','cancelled','refunded') NOT NULL DEFAULT 'completed',
    note            TEXT         NULL,
    sale_date       DATE         NOT NULL,
    created_at      DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cashier_id) REFERENCES users(user_id)
);

-- ============================================================
--  6. ГҮЙЛГЭЭНИЙ ДЭЛГЭРЭНГҮЙ (sale_items)
-- ============================================================
CREATE TABLE IF NOT EXISTS sale_items (
    item_id       INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
    sale_id       INT UNSIGNED  NOT NULL,
    product_id    INT UNSIGNED  NOT NULL,
    product_name  VARCHAR(200)  NOT NULL,
    unit_price    DECIMAL(12,2) NOT NULL,
    qty           INT           NOT NULL,
    subtotal      DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (sale_id)    REFERENCES sales(sale_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ============================================================
--  7. БУЦААЛТ (refunds)
-- ============================================================
CREATE TABLE IF NOT EXISTS refunds (
    refund_id     INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
    sale_id       INT UNSIGNED  NOT NULL,
    processed_by  INT UNSIGNED  NOT NULL,
    amount        DECIMAL(12,2) NOT NULL,
    reason        TEXT          NULL,
    refunded_at   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sale_id)      REFERENCES sales(sale_id),
    FOREIGN KEY (processed_by) REFERENCES users(user_id)
);

-- ============================================================
--  8. ВЭБ САЙТЫН ХЭРЭГЛЭГЧИД (customers)
-- ============================================================
CREATE TABLE IF NOT EXISTS customers (
    customer_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100)  NOT NULL,
    email           VARCHAR(150)  NOT NULL UNIQUE,
    password_hash   VARCHAR(255)  NOT NULL,
    phone           VARCHAR(20)   NULL,
    birthday        DATE          NULL,
    gender          ENUM('male','female','other') NULL,
    is_active       TINYINT(1)   NOT NULL DEFAULT 1,
    is_verified     TINYINT(1)   NOT NULL DEFAULT 1,
    loyalty_points  INT UNSIGNED  NOT NULL DEFAULT 0,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
--  9. НЭВТРЭЛТИЙН БҮРТГЭЛ (login_logs)
-- ============================================================
CREATE TABLE IF NOT EXISTS login_logs (
    log_id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id   INT UNSIGNED NULL,
    email_try     VARCHAR(150) NOT NULL,
    ip_address    VARCHAR(45)  NOT NULL,
    status        ENUM('success','failed','blocked') NOT NULL,
    logged_at     DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL
);

-- ============================================================
--  10. ХҮРГЭЛТИЙН ХАЯГ (customer_addresses)
-- ============================================================
CREATE TABLE IF NOT EXISTS customer_addresses (
    address_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id   INT UNSIGNED NOT NULL,
    label         VARCHAR(50)  NOT NULL DEFAULT 'Гэр',
    district      VARCHAR(100) NOT NULL,
    khoroo        VARCHAR(100) NOT NULL,
    street        VARCHAR(200) NOT NULL,
    detail        VARCHAR(300) NULL,
    is_default    TINYINT(1)  NOT NULL DEFAULT 0,
    created_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- ============================================================
--  11. ЛОЯАЛТИ ОНОО (loyalty_transactions)
-- ============================================================
CREATE TABLE IF NOT EXISTS loyalty_transactions (
    lt_id         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id   INT UNSIGNED NOT NULL,
    type          ENUM('earn','redeem','expire','bonus') NOT NULL,
    points        INT          NOT NULL,
    balance_after INT UNSIGNED NOT NULL,
    note          VARCHAR(300) NULL,
    created_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- ============================================================
--  ИНДЕКСҮҮД
-- ============================================================
-- 1. Бүтээгдэхүүний ангиллаар хайлт хурдасгах
CREATE INDEX idx_products_cat      ON products(category_id);

-- 2. Борлуулалтын огноогоор шүүлт хийхэд ашиглана
CREATE INDEX idx_sales_date       ON sales(sale_date);

-- 3. Кассчин бүрээр борлуулалтыг харахад ашиглана
CREATE INDEX idx_sales_cashier    ON sales(cashier_id);

-- 4. Борлуулалтын задаргааг хайхад ашиглана
CREATE INDEX idx_sale_items_sale  ON sale_items(sale_id);

-- 5. Хэрэглэгчийн имэйлээр хайхад ашиглана
CREATE INDEX idx_customers_email   ON customers(email);

-- 6. Нэвтрэлтийн түүхийг хэрэглэгч бүрээр харахад ашиглана
CREATE INDEX idx_login_logs_cust   ON login_logs(customer_id);
-- ============================================================
--  TRIGGERS
-- ============================================================

-- Бараа зарагдахад нөөц хасах
DROP TRIGGER IF EXISTS trg_reduce_stock;
DELIMITER $$
CREATE TRIGGER trg_reduce_stock
AFTER INSERT ON sale_items
FOR EACH ROW
BEGIN
    DECLARE v_before INT;
    SELECT stock_qty INTO v_before FROM products WHERE product_id = NEW.product_id;
    UPDATE products SET stock_qty = stock_qty - NEW.qty WHERE product_id = NEW.product_id;
    INSERT INTO stock_movements (product_id, user_id, type, qty, qty_before, qty_after, note)
    SELECT NEW.product_id, s.cashier_id, 'out', NEW.qty, v_before, v_before - NEW.qty,
           CONCAT('Гүйлгээ: ', s.sale_code)
    FROM sales s WHERE s.sale_id = NEW.sale_id;
END$$
DELIMITER ;

-- sale_items нэмэгдэхэд нийт дүн шинэчлэх
DROP TRIGGER IF EXISTS trg_update_total;
DELIMITER $$
CREATE TRIGGER trg_update_total
AFTER INSERT ON sale_items
FOR EACH ROW
BEGIN
    UPDATE sales
    SET total_amount = (SELECT SUM(subtotal) FROM sale_items WHERE sale_id = NEW.sale_id),
        final_amount = (SELECT SUM(subtotal) FROM sale_items WHERE sale_id = NEW.sale_id) - discount_amount
    WHERE sale_id = NEW.sale_id;
END$$
DELIMITER ;

-- ============================================================
--  VIEWS
-- ============================================================

CREATE OR REPLACE VIEW vw_low_stock AS
SELECT p.code, p.name, c.name AS category, p.stock_qty, p.min_stock,
    CASE WHEN p.stock_qty = 0 THEN 'Дууссан'
         WHEN p.stock_qty <= p.min_stock THEN 'Яаралтай'
         ELSE 'Анхааруулга' END AS alert_level
FROM products p
JOIN categories c ON c.category_id = p.category_id
WHERE p.stock_qty <= p.min_stock AND p.is_active = 1;

CREATE OR REPLACE VIEW vw_daily_sales AS
SELECT s.sale_date, COUNT(DISTINCT s.sale_id) AS total_transactions,
    SUM(s.final_amount) AS total_revenue, AVG(s.final_amount) AS avg_check,
    u.full_name AS cashier_name, s.payment_method
FROM sales s
JOIN users u ON u.user_id = s.cashier_id
WHERE s.status = 'completed'
GROUP BY s.sale_date, u.user_id, s.payment_method;

CREATE OR REPLACE VIEW vw_customer_profile AS
SELECT customer_id, full_name, email, phone, birthday,
    is_verified, loyalty_points, created_at
FROM customers WHERE is_active = 1;

-- ============================================================
--  STORED PROCEDURES
-- ============================================================

-- Шинэ хэрэглэгч бүртгэх
DROP PROCEDURE IF EXISTS sp_register_customer;
DELIMITER $$
CREATE PROCEDURE sp_register_customer(
    IN  p_full_name VARCHAR(100),
    IN  p_email     VARCHAR(150),
    IN  p_password  VARCHAR(255),
    IN  p_phone     VARCHAR(20),
    OUT p_id        INT UNSIGNED,
    OUT p_result    VARCHAR(50)
)
BEGIN
    IF EXISTS (SELECT 1 FROM customers WHERE email = p_email) THEN
        SET p_id = 0; SET p_result = 'email_exists';
    ELSE
        INSERT INTO customers (full_name, email, password_hash, phone)
        VALUES (p_full_name, p_email, p_password, p_phone);
        SET p_id = LAST_INSERT_ID(); SET p_result = 'success';
    END IF;
END$$
DELIMITER ;

-- Өдрийн тайлан
DROP PROCEDURE IF EXISTS sp_daily_report;
DELIMITER $$
CREATE PROCEDURE sp_daily_report(IN p_date DATE)
BEGIN
    SELECT COUNT(*) AS total_sales, SUM(final_amount) AS total_revenue,
           AVG(final_amount) AS avg_check, payment_method
    FROM sales WHERE sale_date = p_date AND status = 'completed'
    GROUP BY payment_method;

    SELECT u.full_name AS cashier, COUNT(s.sale_id) AS sales_count,
           SUM(s.final_amount) AS revenue
    FROM sales s JOIN users u ON u.user_id = s.cashier_id
    WHERE s.sale_date = p_date AND s.status = 'completed'
    GROUP BY u.user_id;

    SELECT si.product_name, SUM(si.qty) AS total_qty, SUM(si.subtotal) AS total_revenue
    FROM sale_items si JOIN sales s ON s.sale_id = si.sale_id
    WHERE s.sale_date = p_date AND s.status = 'completed'
    GROUP BY si.product_id ORDER BY total_qty DESC LIMIT 10;
END$$
DELIMITER ;

-- ============================================================
--  ЖИШЭЭ ӨГӨГДӨЛ
-- ============================================================

-- Ажилтнууд
INSERT INTO users (full_name, username, password_hash, role, phone) VALUES
('Отгонбаяр Д.',  'admin',    '$2b$12$exampleAdminHash',   'admin',   '+976 9900-0000'),
('Ариунаа Г.',    'ariunaa',  '$2b$12$exampleManagerHash', 'manager', '+976 9944-5566'),
('Болормаа Д.',   'bolormaa', '$2b$12$exampleCashier1',    'cashier', '+976 9911-2233'),
('Сарнай Б.',     'sarnai',   '$2b$12$exampleCashier2',    'cashier', '+976 9922-3344'),
('Нандин Э.',     'nandin',   '$2b$12$exampleCashier3',    'cashier', '+976 9933-4455');

-- Ангиллууд
INSERT INTO categories (name, description) VALUES
('Талх',    'Өдөр бүр зуурсан талх, круассан'),
('Бялуу',   'Тусгай захиалга болон бэлэн бялуу'),
('Печенье', 'Жижиг боов, печенье'),
('Кофе',    'Халуун, хүйтэн ундаа'),
('Боов',    'Уламжлалт Монгол боов');

-- Бараа
INSERT INTO products (code, name, category_id, price, cost_price, stock_qty, min_stock) VALUES
('B001', 'Уламжлалт талх',   1,  4500,  2000, 32, 10),
('B002', 'Хийморь бялуу',    2, 28000, 12000,  5, 10),
('B003', 'Шоколад печенье',  3,  1800,   700, 48, 15),
('B004', 'Капучино',         4,  6500,  2500, 25, 10),
('B005', 'Круассан',         1,  5200,  2200,  3, 10),
('B006', 'Цагаан боов',      5,  2200,   900, 60, 20),
('B007', 'Ваниль бялуу',     2, 22000, 10000, 12,  8);

-- Вэб сайтын хэрэглэгчид
INSERT INTO customers (full_name, email, password_hash, phone, is_verified, loyalty_points) VALUES
('Болд Батбаяр',  'bold@example.mn',    '$2b$12$exampleHash1', '+976 9911-0001', 1, 120),
('Сарнай Дорж',   'sarnaid@example.mn', '$2b$12$exampleHash2', '+976 9922-0002', 1, 450),
('Анар Гантулга', 'anar@example.mn',    '$2b$12$exampleHash3', '+976 9933-0003', 1,   0);

-- Гүйлгээ
INSERT INTO sales (sale_code, cashier_id, total_amount, final_amount, payment_method, sale_date) VALUES
('#0038', 3, 13000, 13000, 'card', '2026-04-28'),
('#0039', 4, 11100, 11100, 'cash', '2026-04-28'),
('#0040', 4,  9000,  9000, 'cash', '2026-04-28'),
('#0041', 3, 41500, 41500, 'card', '2026-04-28'),
('#0042', 3, 14200, 14200, 'cash', '2026-04-28');

INSERT INTO sale_items (sale_id, product_id, product_name, unit_price, qty, subtotal) VALUES
(1, 4, 'Капучино',        6500, 2, 13000),
(2, 6, 'Цагаан боов',     2200, 3,  6600),
(2, 1, 'Уламжлалт талх',  4500, 1,  4500),
(3, 3, 'Шоколад печенье', 1800, 5,  9000),
(4, 2, 'Хийморь бялуу',  28000, 1, 28000),
(4, 4, 'Капучино',         6500, 2, 13000),
(5, 1, 'Уламжлалт талх',  4500, 2,  9000),
(5, 5, 'Круассан',         5200, 1,  5200);

-- ============================================================
--  ШАЛГАХ QUERY-УУД
-- ============================================================
SELECT * FROM vw_low_stock;
SELECT * FROM vw_daily_sales;
SELECT * FROM customers;
CALL sp_daily_report('2026-04-28');
-- ============================================================