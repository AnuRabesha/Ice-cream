PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS business_accounts (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    contact_name        TEXT    NOT NULL,
    email               TEXT    UNIQUE NOT NULL,
    password            TEXT    NOT NULL,
    phone               TEXT,
    business_name       TEXT    NOT NULL,
    business_type       TEXT    NOT NULL CHECK (business_type IN ('manufacturer','wholesaler','distributor')),
    logo_url            TEXT,
    address             TEXT,
    city                TEXT,
    state               TEXT,
    pincode             TEXT,
    gst_number          TEXT,
    pan_number          TEXT,
    website             TEXT,
    description         TEXT,
    delivery_areas      TEXT,
    delivery_time       TEXT    DEFAULT '3-7 business days',
    verification_status TEXT    DEFAULT 'pending' CHECK (verification_status IN ('pending','verified','rejected')),
    verification_notes  TEXT,
    is_active           INTEGER DEFAULT 1,
    created_at          TEXT    DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS business_products (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id     INTEGER NOT NULL,
    name            TEXT    NOT NULL,
    description     TEXT,
    category        TEXT,
    image_url       TEXT,
    pack_size       TEXT,
    wholesale_price REAL    NOT NULL,
    moq             INTEGER NOT NULL DEFAULT 1,
    stock           INTEGER DEFAULT 0,
    is_available    INTEGER DEFAULT 1,
    created_at      TEXT    DEFAULT (datetime('now')),
    FOREIGN KEY (business_id) REFERENCES business_accounts(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_bp_business_created ON business_products (business_id, created_at);

CREATE TABLE IF NOT EXISTS b2b_orders (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id      INTEGER NOT NULL,
    buyer_name       TEXT    NOT NULL,
    buyer_email      TEXT,
    buyer_phone      TEXT,
    buyer_company    TEXT,
    product_id       INTEGER NOT NULL,
    quantity         INTEGER NOT NULL,
    unit_price       REAL    NOT NULL,
    total_amount     REAL    NOT NULL,
    delivery_address TEXT,
    delivery_city    TEXT,
    delivery_pincode TEXT,
    order_type       TEXT    DEFAULT 'order' CHECK (order_type IN ('order','quotation')),
    status           TEXT    DEFAULT 'pending' CHECK (status IN ('pending','accepted','rejected','processing','shipped','delivered','cancelled')),
    notes            TEXT,
    seller_notes     TEXT,
    created_at       TEXT    DEFAULT (datetime('now')),
    FOREIGN KEY (business_id) REFERENCES business_accounts(id) ON DELETE RESTRICT,
    FOREIGN KEY (product_id)  REFERENCES business_products(id) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_b2b_orders_business_status ON b2b_orders (business_id, status);

CREATE TABLE IF NOT EXISTS b2b_invoices (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id       INTEGER NOT NULL,
    business_id    INTEGER NOT NULL,
    invoice_number TEXT    UNIQUE NOT NULL,
    amount         REAL    NOT NULL,
    tax_amount     REAL    DEFAULT 0.00,
    total_amount   REAL    NOT NULL,
    status         TEXT    DEFAULT 'draft' CHECK (status IN ('draft','sent','paid','overdue')),
    due_date       TEXT,
    notes          TEXT,
    created_at     TEXT    DEFAULT (datetime('now')),
    FOREIGN KEY (order_id)    REFERENCES b2b_orders(id)         ON DELETE RESTRICT,
    FOREIGN KEY (business_id) REFERENCES business_accounts(id)  ON DELETE RESTRICT
);
