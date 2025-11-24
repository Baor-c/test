/*
  # Tạo schema ban đầu cho hệ thống đặt hàng đồ ăn nhanh

  ## Mô tả
  Migration này tạo tất cả các bảng cần thiết cho hệ thống đặt hàng đồ ăn nhanh
  với đầy đủ RLS policies để bảo mật dữ liệu.

  ## 1. Bảng mới tạo
  
  ### `user_profiles`
  - `id` (uuid, FK to auth.users) - ID người dùng
  - `full_name` (text) - Họ và tên
  - `email` (text) - Email
  - `phone` (text) - Số điện thoại
  - `address` (text) - Địa chỉ
  - `date_of_birth` (date) - Ngày sinh
  - `avatar_url` (text) - URL avatar
  - `role` (text) - Vai trò: 'customer' hoặc 'admin'
  - `created_at` (timestamptz) - Thời gian tạo
  - `updated_at` (timestamptz) - Thời gian cập nhật

  ### `categories`
  - `id` (uuid, PK) - ID danh mục
  - `name` (text) - Tên danh mục
  - `description` (text) - Mô tả
  - `image_url` (text) - URL hình ảnh
  - `created_at` (timestamptz) - Thời gian tạo

  ### `food_items`
  - `id` (uuid, PK) - ID món ăn
  - `name` (text) - Tên món ăn
  - `description` (text) - Mô tả
  - `price` (decimal) - Giá
  - `category_id` (uuid, FK) - ID danh mục
  - `image_url` (text) - URL hình ảnh
  - `is_available` (boolean) - Còn hàng hay không
  - `created_at` (timestamptz) - Thời gian tạo
  - `updated_at` (timestamptz) - Thời gian cập nhật

  ### `combos`
  - `id` (uuid, PK) - ID combo
  - `name` (text) - Tên combo
  - `description` (text) - Mô tả
  - `price` (decimal) - Giá combo
  - `image_url` (text) - URL hình ảnh
  - `is_available` (boolean) - Còn hàng hay không
  - `created_at` (timestamptz) - Thời gian tạo
  - `updated_at` (timestamptz) - Thời gian cập nhật

  ### `combo_items`
  - `id` (uuid, PK) - ID
  - `combo_id` (uuid, FK) - ID combo
  - `food_item_id` (uuid, FK) - ID món ăn
  - `quantity` (integer) - Số lượng

  ### `orders`
  - `id` (uuid, PK) - ID đơn hàng
  - `user_id` (uuid, FK) - ID người đặt
  - `total_amount` (decimal) - Tổng tiền
  - `status` (text) - Trạng thái: 'pending', 'processing', 'delivering', 'completed', 'cancelled'
  - `delivery_address` (text) - Địa chỉ giao hàng
  - `phone` (text) - Số điện thoại
  - `notes` (text) - Ghi chú
  - `created_at` (timestamptz) - Thời gian đặt
  - `updated_at` (timestamptz) - Thời gian cập nhật

  ### `order_items`
  - `id` (uuid, PK) - ID
  - `order_id` (uuid, FK) - ID đơn hàng
  - `food_item_id` (uuid, FK, nullable) - ID món ăn
  - `combo_id` (uuid, FK, nullable) - ID combo
  - `quantity` (integer) - Số lượng
  - `price` (decimal) - Giá tại thời điểm đặt

  ## 2. Bảo mật
  - Bật RLS cho tất cả các bảng
  - User profiles: Users có thể xem và cập nhật profile của mình, Admin xem tất cả
  - Categories, Food items, Combos: Public có thể xem, chỉ Admin có thể quản lý
  - Orders: Users chỉ xem đơn hàng của mình, Admin xem tất cả
  - Order items: Kế thừa quyền từ orders

  ## 3. Indexes
  - Tạo indexes cho các trường thường xuyên query
*/

-- Tạo bảng user_profiles
CREATE TABLE IF NOT EXISTS user_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name text NOT NULL,
  email text UNIQUE NOT NULL,
  phone text NOT NULL,
  address text NOT NULL,
  date_of_birth date,
  avatar_url text,
  role text NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'admin')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Tạo bảng categories
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  image_url text,
  created_at timestamptz DEFAULT now()
);

-- Tạo bảng food_items
CREATE TABLE IF NOT EXISTS food_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  price decimal(10,2) NOT NULL CHECK (price >= 0),
  category_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  image_url text,
  is_available boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Tạo bảng combos
CREATE TABLE IF NOT EXISTS combos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  price decimal(10,2) NOT NULL CHECK (price >= 0),
  image_url text,
  is_available boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Tạo bảng combo_items
CREATE TABLE IF NOT EXISTS combo_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  combo_id uuid NOT NULL REFERENCES combos(id) ON DELETE CASCADE,
  food_item_id uuid NOT NULL REFERENCES food_items(id) ON DELETE CASCADE,
  quantity integer NOT NULL DEFAULT 1 CHECK (quantity > 0)
);

-- Tạo bảng orders
CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  total_amount decimal(10,2) NOT NULL CHECK (total_amount >= 0),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'delivering', 'completed', 'cancelled')),
  delivery_address text NOT NULL,
  phone text NOT NULL,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Tạo bảng order_items
CREATE TABLE IF NOT EXISTS order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  food_item_id uuid REFERENCES food_items(id) ON DELETE SET NULL,
  combo_id uuid REFERENCES combos(id) ON DELETE SET NULL,
  quantity integer NOT NULL CHECK (quantity > 0),
  price decimal(10,2) NOT NULL CHECK (price >= 0),
  CONSTRAINT check_item_type CHECK (
    (food_item_id IS NOT NULL AND combo_id IS NULL) OR
    (food_item_id IS NULL AND combo_id IS NOT NULL)
  )
);

-- Tạo indexes
CREATE INDEX IF NOT EXISTS idx_food_items_category ON food_items(category_id);
CREATE INDEX IF NOT EXISTS idx_food_items_name ON food_items(name);
CREATE INDEX IF NOT EXISTS idx_combo_items_combo ON combo_items(combo_id);
CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);

-- Bật RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE food_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE combos ENABLE ROW LEVEL SECURITY;
ALTER TABLE combo_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies cho user_profiles
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Admins can view all profiles"
  ON user_profiles FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can update all profiles"
  ON user_profiles FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can delete profiles"
  ON user_profiles FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
    AND id != auth.uid()
  );

CREATE POLICY "Anyone can insert profile on signup"
  ON user_profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- RLS Policies cho categories (Public read, Admin write)
CREATE POLICY "Anyone can view categories"
  ON categories FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins can insert categories"
  ON categories FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can update categories"
  ON categories FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can delete categories"
  ON categories FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- RLS Policies cho food_items (Public read, Admin write)
CREATE POLICY "Anyone can view food items"
  ON food_items FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins can insert food items"
  ON food_items FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can update food items"
  ON food_items FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can delete food items"
  ON food_items FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- RLS Policies cho combos (Public read, Admin write)
CREATE POLICY "Anyone can view combos"
  ON combos FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins can insert combos"
  ON combos FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can update combos"
  ON combos FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can delete combos"
  ON combos FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- RLS Policies cho combo_items
CREATE POLICY "Anyone can view combo items"
  ON combo_items FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Admins can manage combo items"
  ON combo_items FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- RLS Policies cho orders
CREATE POLICY "Users can view own orders"
  ON orders FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all orders"
  ON orders FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Authenticated users can create orders"
  ON orders FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own orders"
  ON orders FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can update all orders"
  ON orders FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- RLS Policies cho order_items
CREATE POLICY "Users can view own order items"
  ON order_items FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = order_items.order_id
      AND orders.user_id = auth.uid()
    )
  );

CREATE POLICY "Admins can view all order items"
  ON order_items FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Users can insert own order items"
  ON order_items FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = order_items.order_id
      AND orders.user_id = auth.uid()
    )
  );

CREATE POLICY "Admins can manage all order items"
  ON order_items FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Function để tự động cập nhật updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Tạo triggers cho updated_at
CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_food_items_updated_at
  BEFORE UPDATE ON food_items
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_combos_updated_at
  BEFORE UPDATE ON combos
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();