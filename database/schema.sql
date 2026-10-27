PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    name     TEXT    NOT NULL,
    email    TEXT    UNIQUE NOT NULL,
    password TEXT    NOT NULL,
    phone    TEXT,
    role     TEXT    NOT NULL DEFAULT 'customer' CHECK (role IN ('customer','business','admin')),
    created_at TEXT  DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS shops (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    name             TEXT    NOT NULL,
    description      TEXT,
    address          TEXT,
    city             TEXT,
    rating           REAL    DEFAULT 0,
    image_url        TEXT,
    owner_id         INTEGER,
    is_featured      INTEGER DEFAULT 0,
    opening_hours    TEXT    DEFAULT 'Mon-Sun: 10:00 AM - 10:00 PM',
    phone            TEXT,
    email            TEXT,
    website          TEXT,
    maps_url         TEXT,
    home_delivery    INTEGER DEFAULT 1,
    delivery_fee     REAL    DEFAULT 40.00,
    min_order        REAL    DEFAULT 150.00,
    delivery_time    TEXT    DEFAULT '30-45 mins',
    delivery_areas   TEXT    DEFAULT '',
    pickup_available INTEGER DEFAULT 1,
    created_at       TEXT    DEFAULT (datetime('now')),
    FOREIGN KEY (owner_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS flavours (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT    NOT NULL,
    description TEXT,
    category    TEXT,
    image_url   TEXT,
    is_trending INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS products (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_id             INTEGER,
    name                TEXT    NOT NULL,
    description         TEXT,
    price               REAL    NOT NULL,
    category            TEXT    DEFAULT 'scoop' CHECK (category IN ('scoop','cone','cup','cake','combo','bulk')),
    flavour_id          INTEGER,
    image_url           TEXT,
    is_bestseller       INTEGER DEFAULT 0,
    stock               INTEGER DEFAULT 100,
    low_stock_threshold INTEGER DEFAULT 10,
    mood_tags           TEXT    DEFAULT '',
    created_at          TEXT    DEFAULT (datetime('now')),
    FOREIGN KEY (shop_id)    REFERENCES shops(id),
    FOREIGN KEY (flavour_id) REFERENCES flavours(id)
);

CREATE TABLE IF NOT EXISTS cake_designs (
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    name               TEXT    NOT NULL,
    cake_type          TEXT    DEFAULT 'birthday' CHECK (cake_type IN ('birthday','wedding','photo','chocolate','cartoon','heart','anniversary','designer','custom')),
    description        TEXT,
    base_flavour       TEXT,
    available_flavours TEXT,
    layers             INTEGER DEFAULT 1,
    available_sizes    TEXT    DEFAULT '0.5kg:500,1kg:850,1.5kg:1100,2kg:1500',
    available_shapes   TEXT    DEFAULT 'Round,Square,Heart,Rectangle',
    available_colours  TEXT    DEFAULT 'Pink,White,Chocolate Brown,Blue,Purple,Gold',
    available_toppings TEXT,
    base_price         REAL    DEFAULT 850.00,
    price              REAL,
    image_url          TEXT,
    shop_id            INTEGER,
    supports_photo     INTEGER DEFAULT 0,
    is_custom          INTEGER DEFAULT 0,
    is_featured        INTEGER DEFAULT 0,
    created_at         TEXT    DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS custom_cake_orders (
    id                 INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id            INTEGER NOT NULL,
    shop_id            INTEGER NOT NULL,
    cake_design_id     INTEGER,
    cake_type          TEXT,
    cake_name          TEXT,
    selected_size      TEXT,
    selected_shape     TEXT,
    selected_flavour   TEXT,
    selected_colour    TEXT,
    selected_toppings  TEXT,
    custom_message     TEXT,
    photo_reference    TEXT,
    extra_decorations  TEXT,
    quantity           INTEGER DEFAULT 1,
    base_price         REAL,
    final_price        REAL,
    delivery_date      TEXT,
    delivery_address   TEXT,
    special_notes      TEXT,
    status             TEXT    DEFAULT 'pending' CHECK (status IN ('pending','owner_review','confirmed','preparing','ready','delivered','cancelled')),
    owner_notes        TEXT,
    created_at         TEXT    DEFAULT (datetime('now')),
    FOREIGN KEY (user_id)        REFERENCES users(id)        ON DELETE RESTRICT,
    FOREIGN KEY (shop_id)        REFERENCES shops(id)        ON DELETE RESTRICT,
    FOREIGN KEY (cake_design_id) REFERENCES cake_designs(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS orders (
    id                   INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id              INTEGER NOT NULL,
    shop_id              INTEGER,
    total_amount         REAL    NOT NULL,
    delivery_fee         REAL    DEFAULT 0.00,
    status               TEXT    DEFAULT 'pending' CHECK (status IN ('pending','confirmed','preparing','out_for_delivery','delivered','cancelled')),
    order_type           TEXT    DEFAULT 'retail' CHECK (order_type IN ('retail','bulk')),
    fulfillment_type     TEXT    DEFAULT 'delivery' CHECK (fulfillment_type IN ('delivery','pickup')),
    customer_name        TEXT,
    customer_phone       TEXT,
    house_street         TEXT,
    area                 TEXT,
    city                 TEXT,
    pincode              TEXT,
    delivery_address     TEXT,
    delivery_instructions TEXT,
    created_at           TEXT    DEFAULT (datetime('now')),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS order_items (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id   INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity   INTEGER NOT NULL,
    unit_price REAL    NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(id)   ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS reviews (
    id                   INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id              INTEGER NOT NULL,
    shop_id              INTEGER,
    product_id           INTEGER,
    order_id             INTEGER,
    rating               INTEGER CHECK (rating BETWEEN 1 AND 5),
    comment              TEXT,
    photo_url            TEXT,
    is_verified_purchase INTEGER DEFAULT 0,
    owner_reply          TEXT,
    owner_reply_at       TEXT,
    is_reported          INTEGER DEFAULT 0,
    is_edited            INTEGER DEFAULT 0,
    created_at           TEXT    DEFAULT (datetime('now')),
    UNIQUE (user_id, shop_id, order_id),
    FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE RESTRICT,
    FOREIGN KEY (shop_id)    REFERENCES shops(id)    ON DELETE SET NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS wholesale_products (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_id     INTEGER NOT NULL,
    name        TEXT    NOT NULL,
    description TEXT,
    category    TEXT    NOT NULL CHECK (category IN ('tub','carton','pack','cone_supply','cup_supply','topping','event_package','dessert_supply')),
    unit_label  TEXT    NOT NULL,
    base_price  REAL    NOT NULL,
    tier1_qty   INTEGER NOT NULL DEFAULT 10,
    tier1_price REAL    NOT NULL,
    tier2_qty   INTEGER NOT NULL DEFAULT 25,
    tier2_price REAL    NOT NULL,
    tier3_qty   INTEGER NOT NULL DEFAULT 50,
    tier3_price REAL    NOT NULL,
    moq         INTEGER NOT NULL DEFAULT 5,
    stock       INTEGER NOT NULL DEFAULT 200,
    image_url   TEXT,
    is_active   INTEGER DEFAULT 1,
    created_at  TEXT    DEFAULT (datetime('now')),
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS bulk_orders (
    id                   INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id          INTEGER NOT NULL,
    wholesale_product_id INTEGER NOT NULL,
    business_type        TEXT    NOT NULL CHECK (business_type IN ('ice_cream_shop','cafe','hotel','restaurant','caterer','event_organizer','retailer','other')),
    business_name        TEXT,
    quantity             INTEGER NOT NULL,
    unit_price           REAL    NOT NULL,
    total_price          REAL    NOT NULL,
    delivery_address     TEXT,
    delivery_city        TEXT,
    delivery_pincode     TEXT,
    delivery_fee         REAL    DEFAULT 0.00,
    status               TEXT    DEFAULT 'inquiry' CHECK (status IN ('inquiry','confirmed','processing','shipped','delivered','cancelled')),
    notes                TEXT,
    created_at           TEXT    DEFAULT (datetime('now')),
    FOREIGN KEY (business_id)          REFERENCES users(id)              ON DELETE RESTRICT,
    FOREIGN KEY (wholesale_product_id) REFERENCES wholesale_products(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS cart (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id    INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity   INTEGER DEFAULT 1,
    FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

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

-- ── Seed Data ─────────────────────────────────────────────────────────────────
-- All seed accounts use password: password
-- Hash generated with BCrypt cost 12
INSERT INTO users (name, email, password, role) VALUES
('Admin User',        'admin@scoopora.com',  '$2a$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'),
('Sweet Scoops Owner','owner1@scoopora.com', '$2a$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'business'),
('Gelato King Owner', 'owner2@scoopora.com', '$2a$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'business'),
('John Customer',     'john@example.com',    '$2a$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'customer');

INSERT INTO shops (name, description, address, city, rating, image_url, owner_id, is_featured, opening_hours, phone, email, maps_url, home_delivery, delivery_fee, min_order, delivery_time, delivery_areas, pickup_available) VALUES
('Sweet Scoops',
  'Premium artisan ice cream parlour with 50+ handcrafted flavours. We use only the finest Belgian chocolate, fresh seasonal fruits, and organic dairy to create unforgettable scoops.',
  '12 MG Road, Fort', 'Mumbai', 4.8, 'images/shop1.jpg', 2, 1,
  'Mon-Thu: 11:00 AM - 10:30 PM | Fri-Sun: 10:00 AM - 11:30 PM',
  '+91 98200 11111', 'hello@sweetscoops.in',
  'https://maps.google.com/?q=MG+Road+Fort+Mumbai',
  1, 35.00, 150.00, '25-35 mins', 'Mumbai,Fort,Colaba,Churchgate,Nariman Point,Bandra,Dadar', 1),

('Gelato King',
  'Authentic Italian gelato crafted fresh every morning using traditional Sicilian recipes. Our master gelato chef trained in Bologna brings you the real taste of Italy.',
  '45 Park Street, Connaught Place', 'Delhi', 4.7, 'images/shop2.jpg', 3, 1,
  'Mon-Sun: 12:00 PM - 11:00 PM',
  '+91 98100 22222', 'info@gelatoking.in',
  'https://maps.google.com/?q=Park+Street+Connaught+Place+Delhi',
  1, 50.00, 200.00, '35-50 mins', 'Delhi,Connaught Place,Karol Bagh,Lajpat Nagar,South Delhi,Dwarka', 1),

('Chill Zone',
  'Your go-to destination for creamy soft serves, loaded sundaes, and refreshing shakes. Build your own sundae from 30+ toppings at our self-serve topping bar.',
  '78 Anna Salai, Teynampet', 'Chennai', 4.5, 'images/shop3.jpg', 2, 1,
  'Mon-Sun: 10:00 AM - 10:00 PM',
  '+91 94440 33333', 'chillzone@gmail.com',
  'https://maps.google.com/?q=Anna+Salai+Teynampet+Chennai',
  1, 30.00, 120.00, '20-30 mins', 'Chennai,Teynampet,T Nagar,Nungambakkam,Adyar,Mylapore', 1),

('Frosty Bites',
  'Explore ice cream from around the world — Japanese mochi, Turkish dondurma, American deep-fried ice cream, and more. A global frozen adventure in every bite.',
  '23 FC Road, Shivajinagar', 'Pune', 4.6, 'images/shop4.jpg', 3, 1,
  'Tue-Sun: 11:00 AM - 10:00 PM | Closed Monday',
  '+91 98220 44444', 'frostybites@outlook.com',
  'https://maps.google.com/?q=FC+Road+Shivajinagar+Pune',
  1, 40.00, 180.00, '30-45 mins', 'Pune,Shivajinagar,Kothrud,Deccan,Aundh,Baner,Wakad', 1),

('The Ice Lab',
  'Where science meets dessert. Experience liquid nitrogen ice cream made tableside, edible cocktail spheres, and molecular gastronomy frozen treats. Reservations recommended on weekends.',
  '56 Koregaon Park, Lane 5', 'Pune', 4.9, 'images/shop5.jpg', 2, 1,
  'Wed-Mon: 12:00 PM - 11:00 PM | Closed Tuesday',
  '+91 98230 55555', 'reservations@theicelab.in',
  'https://maps.google.com/?q=Koregaon+Park+Pune',
  1, 60.00, 300.00, '40-55 mins', 'Pune,Koregaon Park,Kalyani Nagar,Viman Nagar,Hadapsar,Camp', 1),

('Sundae Funday',
  'The ultimate sundae experience! Choose your base, stack your scoops, and go wild with our 40+ topping bar. Perfect for families, parties, and anyone with a serious sweet tooth.',
  '90 Linking Road, Bandra West', 'Mumbai', 4.4, 'images/shop6.jpg', 3, 0,
  'Mon-Sun: 11:00 AM - 11:00 PM',
  '+91 98200 66666', 'sundaefunday@gmail.com',
  'https://maps.google.com/?q=Linking+Road+Bandra+Mumbai',
  1, 45.00, 200.00, '30-40 mins', 'Mumbai,Bandra,Andheri,Juhu,Santacruz,Khar,Vile Parle', 1);

INSERT INTO flavours (name, description, category, image_url, is_trending) VALUES
('Belgian Chocolate', 'Rich dark chocolate from Belgium',          'chocolate', 'images/choc.jpg',       1),
('Mango Tango',       'Fresh Alphonso mango sorbet',               'fruit',     'images/mango.jpg',      1),
('Strawberry Dream',  'Classic strawberry with real fruit pieces', 'fruit',     'images/strawberry.jpg', 1),
('Pistachio Royale',  'Premium pistachio with saffron',            'nut',       'images/pistachio.jpg',  1),
('Cookies & Cream',   'Vanilla with Oreo cookie crumbles',         'classic',   'images/cookies.jpg',    1),
('Blueberry Cheesecake','Tangy blueberry on creamy cheesecake base','fruit',    'images/blueberry.jpg',  0),
('Salted Caramel',    'Sweet caramel with a hint of sea salt',     'caramel',   'images/caramel.jpg',    1),
('Matcha Green Tea',  'Japanese matcha with subtle sweetness',     'exotic',    'images/matcha.jpg',     1),
('Bubblegum Blast',   'Fun bubblegum flavour for kids',            'fun',       'images/bubblegum.jpg',  0),
('Lavender Honey',    'Floral lavender with organic honey',        'exotic',    'images/lavender.jpg',   0);

INSERT INTO products (shop_id, name, description, price, category, flavour_id, image_url, is_bestseller, stock, mood_tags) VALUES
(1,'Belgian Choco Scoop',    'Single scoop of rich Belgian dark chocolate ice cream served in a waffle cup.',       120.00,'scoop',1,'images/p1.jpg', 1,80, 'chocolate,happy,dessert,indulgent'),
(1,'Mango Tango Cone',       'Fresh Alphonso mango sorbet in a crispy waffle cone. Seasonal favourite.',            150.00,'cone', 2,'images/p2.jpg', 1,65, 'fruit,refreshing,happy,summer'),
(1,'Strawberry Bliss Cup',   'Creamy strawberry ice cream loaded with real strawberry chunks.',                     130.00,'cup',  3,'images/p10.jpg',0,70, 'fruit,happy,refreshing,dairy'),
(1,'Family Combo Pack',      '4 generous scoops of your choice of flavours in a shareable tray.',                  450.00,'combo',1,'images/p8.jpg', 1,40, 'happy,dessert,indulgent,sharing'),
(1,'Choco-Nut Waffle Cone',  'Double scoop of chocolate and pistachio in a hand-rolled waffle cone.',              220.00,'cone', 1,'images/p11.jpg',0,55, 'chocolate,indulgent,dessert,happy'),
(2,'Pistachio Gelato Cup',   'Authentic Sicilian pistachio gelato with a velvety smooth texture.',                 180.00,'cup',  4,'images/p3.jpg', 1,60, 'adventurous,dessert,indulgent,dairy'),
(2,'Cookies & Cream Cone',   'Classic cookies and cream gelato in a sugar cone with Oreo crumble topping.',        160.00,'cone', 5,'images/p4.jpg', 0,75, 'happy,dessert,indulgent,chocolate'),
(2,'Stracciatella Cup',      'Creamy fior di latte gelato with fine dark chocolate shavings throughout.',          170.00,'cup',  1,'images/p12.jpg',1,50, 'chocolate,dessert,dairy,indulgent'),
(2,'Tiramisu Gelato',        'Espresso-soaked ladyfinger gelato with mascarpone cream swirl.',                     200.00,'cup',  1,'images/p13.jpg',1,45, 'adventurous,dessert,indulgent,dairy'),
(2,'Bulk Gelato Tub 5L',     'Wholesale 5-litre tub of premium gelato. Available in 6 flavours.',                1200.00,'bulk', 4,'images/p9.jpg', 0,20, 'sharing,dessert'),
(3,'Salted Caramel Sundae',  'Soft serve sundae drizzled with house-made salted caramel and roasted cashews.',     220.00,'cup',  7,'images/p5.jpg', 1,90, 'happy,dessert,indulgent,dairy'),
(3,'Strawberry Sundae',      'Fresh strawberry soft serve topped with whipped cream and a cherry.',                190.00,'cup',  3,'images/p14.jpg',0,85, 'fruit,happy,refreshing,dairy'),
(3,'Choco Fudge Sundae',     'Vanilla soft serve smothered in warm chocolate fudge and brownie bites.',            240.00,'cup',  1,'images/p15.jpg',1,70, 'chocolate,indulgent,dessert,happy'),
(3,'Rainbow Sprinkle Cone',  'Vanilla soft serve cone with rainbow sprinkles and a chocolate dip.',                110.00,'cone', 5,'images/p16.jpg',0,100,'happy,refreshing,dairy,fun'),
(4,'Matcha Soft Serve',      'Authentic Japanese matcha soft serve with a subtle earthy sweetness.',               140.00,'cone', 8,'images/p6.jpg', 1,60, 'adventurous,refreshing,dairy,healthy'),
(4,'Mochi Ice Cream Set',    'Set of 6 Japanese mochi ice cream balls in assorted flavours.',                      320.00,'combo',2,'images/p17.jpg',1,35, 'adventurous,fruit,happy,sharing'),
(4,'Turkish Dondurma',       'Stretchy, chewy Turkish-style ice cream served with a theatrical presentation.',     180.00,'scoop',1,'images/p18.jpg',1,40, 'adventurous,happy,dairy,fun'),
(4,'Lavender Honey Scoop',   'Delicate lavender ice cream sweetened with organic wildflower honey.',               160.00,'scoop',10,'images/p19.jpg',0,30, 'adventurous,refreshing,dairy,healthy'),
(5,'Molecular Mango Sphere', 'Mango juice spheres that burst in your mouth, served over mango sorbet.',            350.00,'cup',  2,'images/p7.jpg', 1,25, 'adventurous,fruit,refreshing,fun'),
(5,'Liquid Nitrogen Scoop',  'Ice cream churned tableside with liquid nitrogen. Choose any flavour.',              400.00,'scoop',1,'images/p20.jpg',1,30, 'adventurous,happy,fun,indulgent'),
(5,'Nitro Matcha Latte Ice', 'Matcha latte flash-frozen with liquid nitrogen into a creamy ice cream.',            380.00,'cup',  8,'images/p21.jpg',0,20, 'adventurous,refreshing,dairy,healthy'),
(5,'Edible Cocktail Sphere', 'Passion fruit and mango cocktail encapsulated in an edible sphere shell.',           420.00,'cup',  2,'images/p22.jpg',1,15, 'adventurous,fruit,fun,refreshing'),
(6,'Build-Your-Own Sundae',  'Pick your base, 2 scoops, and 5 toppings from our 40-item topping bar.',            280.00,'combo',5,'images/p23.jpg',1,100,'happy,dessert,sharing,fun'),
(6,'Blueberry Cheesecake Cup','Blueberry cheesecake ice cream with graham cracker crumble and blueberry compote.',210.00,'cup',  6,'images/p24.jpg',1,55, 'fruit,dessert,indulgent,dairy'),
(6,'Bubblegum Blast Cone',   'Fun bubblegum-flavoured ice cream with popping candy. Kids go crazy for this!',     130.00,'cone', 9,'images/p25.jpg',0,80, 'happy,fun,dairy,refreshing'),
(6,'Mega Party Sundae',      'A towering sundae with 6 scoops, 8 toppings, whipped cream, and sparklers.',        650.00,'combo',1,'images/p26.jpg',1,20, 'happy,indulgent,sharing,dessert,fun');
