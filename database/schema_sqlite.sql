PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role TEXT DEFAULT 'customer' CHECK(role IN ('customer','business','admin')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS shops (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    address VARCHAR(255),
    city VARCHAR(100),
    rating DECIMAL(2,1) DEFAULT 0,
    image_url VARCHAR(255),
    owner_id INT,
    is_featured INTEGER DEFAULT 0,
    opening_hours VARCHAR(255) DEFAULT 'Mon-Sun: 10:00 AM - 10:00 PM',
    phone VARCHAR(30),
    email VARCHAR(100),
    website VARCHAR(150),
    maps_url VARCHAR(500),
    home_delivery INTEGER DEFAULT 1,
    delivery_fee DECIMAL(6,2) DEFAULT 40.00,
    min_order DECIMAL(8,2) DEFAULT 150.00,
    delivery_time VARCHAR(50) DEFAULT '30-45 mins',
    delivery_areas TEXT DEFAULT '',
    pickup_available INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS flavours (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    image_url VARCHAR(255),
    is_trending INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_id INT,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category TEXT DEFAULT 'scoop' CHECK(category IN ('scoop','cone','cup','cake','combo','bulk')),
    flavour_id INT,
    image_url VARCHAR(255),
    is_bestseller INTEGER DEFAULT 0,
    stock INT DEFAULT 100,
    low_stock_threshold INT DEFAULT 10,
    mood_tags VARCHAR(255) DEFAULT '',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (shop_id) REFERENCES shops(id),
    FOREIGN KEY (flavour_id) REFERENCES flavours(id)
);

CREATE TABLE IF NOT EXISTS cake_designs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(150) NOT NULL,
    cake_type TEXT DEFAULT 'birthday' CHECK(cake_type IN ('birthday','wedding','photo','chocolate','cartoon','heart','anniversary','designer','custom')),
    description TEXT,
    base_flavour VARCHAR(100),
    available_flavours TEXT,
    layers INT DEFAULT 1,
    available_sizes TEXT DEFAULT '0.5kg:500,1kg:850,1.5kg:1100,2kg:1500',
    available_shapes TEXT DEFAULT 'Round,Square,Heart,Rectangle',
    available_colours TEXT DEFAULT 'Pink,White,Chocolate Brown,Blue,Purple,Gold',
    available_toppings TEXT,
    base_price DECIMAL(10,2) DEFAULT 850.00,
    price DECIMAL(10,2),
    image_url VARCHAR(255),
    shop_id INT,
    supports_photo INTEGER DEFAULT 0,
    is_custom INTEGER DEFAULT 0,
    is_featured INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS custom_cake_orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INT NOT NULL,
    shop_id INT NOT NULL,
    cake_design_id INT,
    cake_type VARCHAR(50),
    cake_name VARCHAR(150),
    selected_size VARCHAR(50),
    selected_shape VARCHAR(50),
    selected_flavour VARCHAR(100),
    selected_colour VARCHAR(100),
    selected_toppings TEXT,
    custom_message VARCHAR(255),
    photo_reference VARCHAR(255),
    extra_decorations TEXT,
    quantity INT DEFAULT 1,
    base_price DECIMAL(10,2),
    final_price DECIMAL(10,2),
    delivery_date DATE,
    delivery_address TEXT,
    special_notes TEXT,
    status TEXT DEFAULT 'pending' CHECK(status IN ('pending','owner_review','confirmed','preparing','ready','delivered','cancelled')),
    owner_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (shop_id) REFERENCES shops(id),
    FOREIGN KEY (cake_design_id) REFERENCES cake_designs(id)
);

CREATE TABLE IF NOT EXISTS orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INT NOT NULL,
    shop_id INT,
    total_amount DECIMAL(10,2) NOT NULL,
    delivery_fee DECIMAL(6,2) DEFAULT 0.00,
    status TEXT DEFAULT 'pending' CHECK(status IN ('pending','confirmed','preparing','out_for_delivery','delivered','cancelled')),
    order_type TEXT DEFAULT 'retail' CHECK(order_type IN ('retail','bulk')),
    fulfillment_type TEXT DEFAULT 'delivery' CHECK(fulfillment_type IN ('delivery','pickup')),
    customer_name VARCHAR(100),
    customer_phone VARCHAR(20),
    house_street VARCHAR(255),
    area VARCHAR(100),
    city VARCHAR(100),
    pincode VARCHAR(10),
    delivery_address TEXT,
    delivery_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (shop_id) REFERENCES shops(id)
);

CREATE TABLE IF NOT EXISTS order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE IF NOT EXISTS reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INT NOT NULL,
    shop_id INT,
    product_id INT,
    order_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    photo_url VARCHAR(255),
    is_verified_purchase INTEGER DEFAULT 0,
    owner_reply TEXT,
    owner_reply_at TIMESTAMP NULL,
    is_reported INTEGER DEFAULT 0,
    is_edited INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, shop_id, order_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (shop_id) REFERENCES shops(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE IF NOT EXISTS wholesale_products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    category TEXT NOT NULL CHECK(category IN ('tub','carton','pack','cone_supply','cup_supply','topping','event_package','dessert_supply')),
    unit_label VARCHAR(50) NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    tier1_qty INT NOT NULL DEFAULT 10,
    tier1_price DECIMAL(10,2) NOT NULL,
    tier2_qty INT NOT NULL DEFAULT 25,
    tier2_price DECIMAL(10,2) NOT NULL,
    tier3_qty INT NOT NULL DEFAULT 50,
    tier3_price DECIMAL(10,2) NOT NULL,
    moq INT NOT NULL DEFAULT 5,
    stock INT NOT NULL DEFAULT 200,
    image_url VARCHAR(255),
    is_active INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (shop_id) REFERENCES shops(id)
);

CREATE TABLE IF NOT EXISTS bulk_orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id INT NOT NULL,
    wholesale_product_id INT NOT NULL,
    business_type TEXT NOT NULL CHECK(business_type IN ('ice_cream_shop','cafe','hotel','restaurant','caterer','event_organizer','retailer','other')),
    business_name VARCHAR(150),
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    delivery_address TEXT,
    delivery_city VARCHAR(100),
    delivery_pincode VARCHAR(10),
    delivery_fee DECIMAL(8,2) DEFAULT 0.00,
    status TEXT DEFAULT 'inquiry' CHECK(status IN ('inquiry','confirmed','processing','shipped','delivered','cancelled')),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES users(id),
    FOREIGN KEY (wholesale_product_id) REFERENCES wholesale_products(id)
);

CREATE TABLE IF NOT EXISTS cart (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS stock_notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    shop_id INT NOT NULL,
    product_id INT NOT NULL,
    current_stock INT NOT NULL,
    threshold INT NOT NULL,
    is_read INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS business_accounts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    contact_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    business_name VARCHAR(150) NOT NULL,
    business_type TEXT NOT NULL CHECK(business_type IN ('manufacturer','wholesaler','distributor')),
    logo_url VARCHAR(255),
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(10),
    gst_number VARCHAR(20),
    pan_number VARCHAR(20),
    website VARCHAR(150),
    description TEXT,
    delivery_areas TEXT,
    delivery_time VARCHAR(100) DEFAULT '3-7 business days',
    verification_status TEXT DEFAULT 'pending' CHECK(verification_status IN ('pending','verified','rejected')),
    verification_notes TEXT,
    is_active INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS business_products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    image_url VARCHAR(255),
    pack_size VARCHAR(100),
    wholesale_price DECIMAL(10,2) NOT NULL,
    moq INT NOT NULL DEFAULT 1,
    stock INT DEFAULT 0,
    is_available INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES business_accounts(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS b2b_orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    business_id INT NOT NULL,
    buyer_name VARCHAR(150) NOT NULL,
    buyer_email VARCHAR(100),
    buyer_phone VARCHAR(20),
    buyer_company VARCHAR(150),
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    delivery_address TEXT,
    delivery_city VARCHAR(100),
    delivery_pincode VARCHAR(10),
    order_type TEXT DEFAULT 'order' CHECK(order_type IN ('order','quotation')),
    status TEXT DEFAULT 'pending' CHECK(status IN ('pending','accepted','rejected','processing','shipped','delivered','cancelled')),
    notes TEXT,
    seller_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES business_accounts(id),
    FOREIGN KEY (product_id) REFERENCES business_products(id)
);

CREATE TABLE IF NOT EXISTS b2b_invoices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INT NOT NULL,
    business_id INT NOT NULL,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL,
    status TEXT DEFAULT 'draft' CHECK(status IN ('draft','sent','paid','overdue')),
    due_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES b2b_orders(id),
    FOREIGN KEY (business_id) REFERENCES business_accounts(id)
);

CREATE TABLE IF NOT EXISTS quotation_requests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    requester_id INT NOT NULL,
    requester_name VARCHAR(150) NOT NULL,
    requester_email VARCHAR(100) NOT NULL,
    requester_company VARCHAR(150),
    product_name VARCHAR(150) NOT NULL,
    quantity INT NOT NULL,
    preferred_pack_size VARCHAR(100),
    delivery_location VARCHAR(255) NOT NULL,
    required_delivery_date DATE,
    additional_requirements TEXT,
    status TEXT DEFAULT 'open' CHECK(status IN ('open','closed','cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (requester_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS quotation_offers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    request_id INT NOT NULL,
    supplier_type TEXT NOT NULL DEFAULT 'shop' CHECK(supplier_type IN ('shop','business')),
    shop_id INT,
    business_id INT,
    unit_price DECIMAL(10,2) NOT NULL,
    pack_size VARCHAR(100),
    delivery_charge DECIMAL(8,2) DEFAULT 0.00,
    estimated_delivery VARCHAR(100),
    notes TEXT,
    status TEXT DEFAULT 'pending' CHECK(status IN ('pending','accepted','rejected')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES quotation_requests(id) ON DELETE CASCADE,
    FOREIGN KEY (shop_id) REFERENCES shops(id),
    FOREIGN KEY (business_id) REFERENCES business_accounts(id)
);

-- Seed Data
INSERT INTO users (name, email, password, role) VALUES
('Admin User',        'admin@scoopora.com',  '$2a$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'),
('Sweet Scoops Owner','owner1@scoopora.com', '$2a$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'business'),
('Gelato King Owner', 'owner2@scoopora.com', '$2a$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'business'),
('John Customer',     'john@example.com',    '$2a$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'customer');

INSERT INTO shops (name, description, address, city, rating, image_url, owner_id, is_featured, opening_hours, phone, email, maps_url, home_delivery, delivery_fee, min_order, delivery_time, delivery_areas, pickup_available) VALUES
('Sweet Scoops','Premium artisan ice cream parlour with 50+ handcrafted flavours.','12 MG Road, Fort','Mumbai',4.8,'images/shop1.jpg',2,1,'Mon-Thu: 11:00 AM - 10:30 PM | Fri-Sun: 10:00 AM - 11:30 PM','+91 98200 11111','hello@sweetscoops.in','https://maps.google.com/?q=MG+Road+Fort+Mumbai',1,35.00,150.00,'25-35 mins','Mumbai,Fort,Colaba,Churchgate,Nariman Point,Bandra,Dadar',1),
('Gelato King','Authentic Italian gelato crafted fresh every morning.','45 Park Street, Connaught Place','Delhi',4.7,'images/shop2.jpg',3,1,'Mon-Sun: 12:00 PM - 11:00 PM','+91 98100 22222','info@gelatoking.in','https://maps.google.com/?q=Park+Street+Connaught+Place+Delhi',1,50.00,200.00,'35-50 mins','Delhi,Connaught Place,Karol Bagh,Lajpat Nagar,South Delhi,Dwarka',1),
('Chill Zone','Your go-to destination for creamy soft serves and loaded sundaes.','78 Anna Salai, Teynampet','Chennai',4.5,'images/shop3.jpg',2,1,'Mon-Sun: 10:00 AM - 10:00 PM','+91 94440 33333','chillzone@gmail.com','https://maps.google.com/?q=Anna+Salai+Teynampet+Chennai',1,30.00,120.00,'20-30 mins','Chennai,Teynampet,T Nagar,Nungambakkam,Adyar,Mylapore',1),
('Frosty Bites','Explore ice cream from around the world.','23 FC Road, Shivajinagar','Pune',4.6,'images/shop4.jpg',3,1,'Tue-Sun: 11:00 AM - 10:00 PM | Closed Monday','+91 98220 44444','frostybites@outlook.com','https://maps.google.com/?q=FC+Road+Shivajinagar+Pune',1,40.00,180.00,'30-45 mins','Pune,Shivajinagar,Kothrud,Deccan,Aundh,Baner,Wakad',1),
('The Ice Lab','Where science meets dessert.','56 Koregaon Park, Lane 5','Pune',4.9,'images/shop5.jpg',2,1,'Wed-Mon: 12:00 PM - 11:00 PM | Closed Tuesday','+91 98230 55555','reservations@theicelab.in','https://maps.google.com/?q=Koregaon+Park+Pune',1,60.00,300.00,'40-55 mins','Pune,Koregaon Park,Kalyani Nagar,Viman Nagar,Hadapsar,Camp',1),
('Sundae Funday','The ultimate sundae experience!','90 Linking Road, Bandra West','Mumbai',4.4,'images/shop6.jpg',3,0,'Mon-Sun: 11:00 AM - 11:00 PM','+91 98200 66666','sundaefunday@gmail.com','https://maps.google.com/?q=Linking+Road+Bandra+Mumbai',1,45.00,200.00,'30-40 mins','Mumbai,Bandra,Andheri,Juhu,Santacruz,Khar,Vile Parle',1);

INSERT INTO flavours (name, description, category, image_url, is_trending) VALUES
('Belgian Chocolate','Rich dark chocolate from Belgium','chocolate','images/choc.jpg',1),
('Mango Tango','Fresh Alphonso mango sorbet','fruit','images/mango.jpg',1),
('Strawberry Dream','Classic strawberry with real fruit pieces','fruit','images/strawberry.jpg',1),
('Pistachio Royale','Premium pistachio with saffron','nut','images/pistachio.jpg',1),
('Cookies & Cream','Vanilla with Oreo cookie crumbles','classic','images/cookies.jpg',1),
('Blueberry Cheesecake','Tangy blueberry on creamy cheesecake base','fruit','images/blueberry.jpg',0),
('Salted Caramel','Sweet caramel with a hint of sea salt','caramel','images/caramel.jpg',1),
('Matcha Green Tea','Japanese matcha with subtle sweetness','exotic','images/matcha.jpg',1),
('Bubblegum Blast','Fun bubblegum flavour for kids','fun','images/bubblegum.jpg',0),
('Lavender Honey','Floral lavender with organic honey','exotic','images/lavender.jpg',0);
