# Database Schema Design

## Overview
This document defines the complete database schema for the Multi-Module E-Commerce Platform based on the PRD requirements.

## Core Entities

### 1. Users Table
```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL, -- BCrypt encoded
    phone VARCHAR(20),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, INACTIVE, SUSPENDED
    role VARCHAR(20) NOT NULL DEFAULT 'USER', -- USER, ADMIN, PRODUCT_ADMIN, ORDER_ADMIN
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);
```

### 2. Products Table
```sql
CREATE TABLE products (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    category_id BIGINT NOT NULL,
    brand VARCHAR(100),
    sku VARCHAR(100) UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, INACTIVE, DISCONTINUED
    view_count BIGINT DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    INDEX idx_category (category_id),
    INDEX idx_status (status),
    INDEX idx_price (price),
    INDEX idx_name (name),
    INDEX idx_sku (sku),
    INDEX idx_created_at (created_at)
);
```

### 3. Categories Table
```sql
CREATE TABLE categories (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_id BIGINT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id),
    INDEX idx_parent (parent_id),
    INDEX idx_status (status),
    INDEX idx_name (name)
);
```

### 4. Orders Table
```sql
CREATE TABLE orders (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, CONFIRMED, PAID, SHIPPED, DELIVERED, CANCELLED
    shipping_address TEXT NOT NULL,
    billing_address TEXT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    shipped_date DATETIME NULL,
    delivered_date DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_user (user_id),
    INDEX idx_status (status),
    INDEX idx_order_date (order_date),
    INDEX idx_created_at (created_at)
);
```

### 5. Order Items Table
```sql
CREATE TABLE order_items (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_price DECIMAL(12, 2) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_order (order_id),
    INDEX idx_product (product_id)
);
```

### 6. Reviews Table
```sql
CREATE TABLE reviews (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(255),
    content TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, HIDDEN, DELETED
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE KEY unique_product_user_review (product_id, user_id),
    INDEX idx_product (product_id),
    INDEX idx_user (user_id),
    INDEX idx_rating (rating),
    INDEX idx_created_at (created_at)
);
```

### 7. Shopping Cart Table
```sql
CREATE TABLE shopping_carts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    UNIQUE KEY unique_user_product_cart (user_id, product_id),
    INDEX idx_user (user_id),
    INDEX idx_product (product_id)
);
```

### 8. Payments Table
```sql
CREATE TABLE payments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    payment_method VARCHAR(50) NOT NULL, -- CREDIT_CARD, BANK_TRANSFER, PAYPAL, etc.
    amount DECIMAL(12, 2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, COMPLETED, FAILED, CANCELLED
    transaction_id VARCHAR(255) UNIQUE,
    payment_date DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    INDEX idx_order (order_id),
    INDEX idx_status (status),
    INDEX idx_transaction (transaction_id),
    INDEX idx_payment_date (payment_date)
);
```

## Authentication & Security Tables

### 9. User Sessions Table (JWT Management)
```sql
CREATE TABLE user_sessions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    refresh_token VARCHAR(512) NOT NULL,
    access_token VARCHAR(512) NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_accessed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_agent TEXT,
    ip_address VARCHAR(45),
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_refresh_token (refresh_token),
    INDEX idx_expires_at (expires_at),
    INDEX idx_is_active (is_active)
);
```

### 10. Login Attempts Table (Security)
```sql
CREATE TABLE login_attempts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    success BOOLEAN NOT NULL DEFAULT FALSE,
    attempt_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_agent TEXT,
    INDEX idx_email (email),
    INDEX idx_ip_address (ip_address),
    INDEX idx_attempt_time (attempt_time),
    INDEX idx_success (success)
);
```

## Batch Processing Tables

### 11. Batch Job Execution Table
```sql
CREATE TABLE batch_job_execution (
    job_execution_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    job_name VARCHAR(100) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NULL,
    status VARCHAR(20) NOT NULL, -- STARTED, COMPLETED, FAILED, STOPPED
    exit_code VARCHAR(20),
    exit_message TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_job_name (job_name),
    INDEX idx_status (status),
    INDEX idx_start_time (start_time)
);
```

### 12. Daily Order Statistics Table
```sql
CREATE TABLE daily_order_statistics (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    statistics_date DATE NOT NULL UNIQUE,
    total_orders INT NOT NULL DEFAULT 0,
    total_amount DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    total_users INT NOT NULL DEFAULT 0,
    average_order_value DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_statistics_date (statistics_date)
);
```

### 13. Stock Alert Table
```sql
CREATE TABLE stock_alerts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id BIGINT NOT NULL,
    threshold_quantity INT NOT NULL,
    current_quantity INT NOT NULL,
    alert_sent BOOLEAN DEFAULT FALSE,
    alert_sent_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_product (product_id),
    INDEX idx_alert_sent (alert_sent),
    INDEX idx_created_at (created_at)
);
```

## Initial Data Requirements

### Default Categories
```sql
INSERT INTO categories (name, description, parent_id) VALUES
('Electronics', 'Electronic devices and gadgets', NULL),
('Fashion', 'Clothing and accessories', NULL),
('Books', 'Books and educational materials', NULL),
('Home & Garden', 'Home improvement and garden supplies', NULL),
('Sports', 'Sports equipment and fitness gear', NULL);
```

### Admin User
```sql
INSERT INTO users (email, name, password, role, status) VALUES
('admin@example.com', 'System Administrator', '$2a$10$encrypted_password_hash', 'ADMIN', 'ACTIVE');
```

## Indexes and Performance Optimization

### Composite Indexes
```sql
-- Order performance
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
CREATE INDEX idx_orders_date_status ON orders(order_date, status);

-- Product search performance
CREATE INDEX idx_products_category_status ON products(category_id, status);
CREATE INDEX idx_products_price_status ON products(price, status);

-- Review aggregation
CREATE INDEX idx_reviews_product_status ON reviews(product_id, status);
```

## Data Constraints and Business Rules

1. **Users**: Email must be unique and valid
2. **Products**: Stock quantity cannot be negative
3. **Orders**: Total amount must be positive
4. **Order Items**: Quantity must be positive
5. **Reviews**: Rating must be between 1-5
6. **Payments**: Amount must match order total

## Migration Strategy

### Phase 1: Core Tables
- users, categories, products
- orders, order_items
- reviews, shopping_carts

### Phase 2: Authentication & Security
- user_sessions, login_attempts

### Phase 3: Batch Processing
- batch_job_execution
- daily_order_statistics, stock_alerts

### Phase 4: Performance Optimization
- Additional indexes
- Partitioning for large tables (orders, order_items)