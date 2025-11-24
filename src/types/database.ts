export interface UserProfile {
  id: string;
  full_name: string;
  email: string;
  phone: string;
  address: string;
  date_of_birth?: string;
  avatar_url?: string;
  role: 'customer' | 'admin';
  created_at: string;
  updated_at: string;
}

export interface Category {
  id: string;
  name: string;
  description?: string;
  image_url?: string;
  created_at: string;
}

export interface FoodItem {
  id: string;
  name: string;
  description?: string;
  price: number;
  category_id?: string;
  image_url?: string;
  is_available: boolean;
  created_at: string;
  updated_at: string;
  category?: Category;
}

export interface Combo {
  id: string;
  name: string;
  description?: string;
  price: number;
  image_url?: string;
  is_available: boolean;
  created_at: string;
  updated_at: string;
  combo_items?: ComboItem[];
}

export interface ComboItem {
  id: string;
  combo_id: string;
  food_item_id: string;
  quantity: number;
  food_item?: FoodItem;
}

export type OrderStatus = 'pending' | 'processing' | 'delivering' | 'completed' | 'cancelled';

export interface Order {
  id: string;
  user_id: string;
  total_amount: number;
  status: OrderStatus;
  delivery_address: string;
  phone: string;
  notes?: string;
  created_at: string;
  updated_at: string;
  order_items?: OrderItem[];
  user_profile?: UserProfile;
}

export interface OrderItem {
  id: string;
  order_id: string;
  food_item_id?: string;
  combo_id?: string;
  quantity: number;
  price: number;
  food_item?: FoodItem;
  combo?: Combo;
}

export interface CartItem {
  type: 'food' | 'combo';
  item: FoodItem | Combo;
  quantity: number;
}

export interface SearchFilters {
  name?: string;
  category_id?: string;
  min_price?: number;
  max_price?: number;
}
