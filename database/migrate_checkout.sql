PRAGMA foreign_keys = ON;

-- SQLite does not support ADD COLUMN IF NOT EXISTS or multiple columns in one ALTER TABLE.
-- Run each statement individually. If a column already exists, SQLite will error — just skip it.

ALTER TABLE orders ADD COLUMN delivery_fee         REAL DEFAULT 0.00;
ALTER TABLE orders ADD COLUMN fulfillment_type     TEXT DEFAULT 'delivery';
ALTER TABLE orders ADD COLUMN customer_name        TEXT;
ALTER TABLE orders ADD COLUMN customer_phone       TEXT;
ALTER TABLE orders ADD COLUMN house_street         TEXT;
ALTER TABLE orders ADD COLUMN area                 TEXT;
ALTER TABLE orders ADD COLUMN city                 TEXT;
ALTER TABLE orders ADD COLUMN pincode              TEXT;
ALTER TABLE orders ADD COLUMN delivery_instructions TEXT;

ALTER TABLE shops ADD COLUMN delivery_areas   TEXT DEFAULT '';
ALTER TABLE shops ADD COLUMN pickup_available INTEGER DEFAULT 1;

ALTER TABLE products ADD COLUMN low_stock_threshold INTEGER DEFAULT 10;

CREATE TABLE IF NOT EXISTS stock_notifications (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_id       INTEGER NOT NULL,
    product_id    INTEGER NOT NULL,
    current_stock INTEGER NOT NULL,
    threshold     INTEGER NOT NULL,
    is_read       INTEGER DEFAULT 0,
    created_at    TEXT    DEFAULT (datetime('now')),
    FOREIGN KEY (shop_id)    REFERENCES shops(id)    ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

UPDATE shops SET delivery_areas = 'Mumbai,Fort,Colaba,Churchgate,Nariman Point,Bandra,Dadar', pickup_available = 1 WHERE id = 1;
UPDATE shops SET delivery_areas = 'Delhi,Connaught Place,Karol Bagh,Lajpat Nagar,South Delhi,Dwarka', pickup_available = 1 WHERE id = 2;
UPDATE shops SET delivery_areas = 'Chennai,Teynampet,T Nagar,Nungambakkam,Adyar,Mylapore', pickup_available = 1 WHERE id = 3;
UPDATE shops SET delivery_areas = 'Pune,Shivajinagar,Kothrud,Deccan,Aundh,Baner,Wakad', pickup_available = 1 WHERE id = 4;
UPDATE shops SET delivery_areas = 'Pune,Koregaon Park,Kalyani Nagar,Viman Nagar,Hadapsar,Camp', pickup_available = 1 WHERE id = 5;
UPDATE shops SET delivery_areas = 'Mumbai,Bandra,Andheri,Juhu,Santacruz,Khar,Vile Parle', pickup_available = 1 WHERE id = 6;
