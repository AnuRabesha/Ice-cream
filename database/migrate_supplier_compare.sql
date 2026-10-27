PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS quotation_requests (
    id                      INTEGER PRIMARY KEY AUTOINCREMENT,
    requester_id            INTEGER NOT NULL,
    requester_name          TEXT    NOT NULL,
    requester_email         TEXT    NOT NULL,
    requester_company       TEXT,
    product_name            TEXT    NOT NULL,
    quantity                INTEGER NOT NULL,
    preferred_pack_size     TEXT,
    delivery_location       TEXT    NOT NULL,
    required_delivery_date  TEXT,
    additional_requirements TEXT,
    status                  TEXT    DEFAULT 'open' CHECK (status IN ('open','closed','cancelled')),
    created_at              TEXT    DEFAULT (datetime('now')),
    FOREIGN KEY (requester_id) REFERENCES users(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS quotation_offers (
    id                INTEGER PRIMARY KEY AUTOINCREMENT,
    request_id        INTEGER NOT NULL,
    supplier_type     TEXT    NOT NULL DEFAULT 'shop' CHECK (supplier_type IN ('shop','business')),
    shop_id           INTEGER,
    business_id       INTEGER,
    unit_price        REAL    NOT NULL,
    pack_size         TEXT,
    delivery_charge   REAL    DEFAULT 0.00,
    estimated_delivery TEXT,
    notes             TEXT,
    status            TEXT    DEFAULT 'pending' CHECK (status IN ('pending','accepted','rejected')),
    created_at        TEXT    DEFAULT (datetime('now')),
    -- Enforce exactly one supplier id is set based on supplier_type
    CHECK (
        (supplier_type = 'shop'     AND shop_id     IS NOT NULL AND business_id IS NULL) OR
        (supplier_type = 'business' AND business_id IS NOT NULL AND shop_id     IS NULL)
    ),
    FOREIGN KEY (request_id)  REFERENCES quotation_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id)     REFERENCES shops(id)              ON DELETE RESTRICT,
    FOREIGN KEY (business_id) REFERENCES business_accounts(id)  ON DELETE RESTRICT
);
