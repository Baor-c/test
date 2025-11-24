/*
  # Tạo tài khoản admin mặc định

  ## Mô tả
  Migration này tạo tài khoản admin mặc định để truy cập hệ thống quản trị.
  
  ## Thông tin đăng nhập Admin
  - Email: admin@fastfood.com
  - Password: admin123456
  - Role: admin

  ## Lưu ý
  - Đây là tài khoản demo, nên đổi mật khẩu sau khi đăng nhập lần đầu
  - Trong môi trường production, cần tạo admin qua Supabase Dashboard
*/

-- Tạo function để tạo admin user
-- Lưu ý: Trong Supabase, user phải được tạo qua auth.users thông qua Supabase Dashboard hoặc API
-- Migration này chỉ đảm bảo rằng nếu có user với email admin@fastfood.com, họ sẽ có role admin

-- Tạo trigger function để tự động set role admin cho email admin@fastfood.com
CREATE OR REPLACE FUNCTION set_admin_role()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.email = 'admin@fastfood.com' THEN
    NEW.role := 'admin';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Tạo trigger để tự động set admin role khi insert user profile
DROP TRIGGER IF EXISTS set_admin_role_trigger ON user_profiles;
CREATE TRIGGER set_admin_role_trigger
  BEFORE INSERT ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION set_admin_role();

-- Nếu đã có user với email này, update role thành admin
UPDATE user_profiles 
SET role = 'admin' 
WHERE email = 'admin@fastfood.com';