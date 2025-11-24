<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { supabase } from '@/utils/supabase';
import type { FoodItem, Category } from '@/types/database';

const foods = ref<FoodItem[]>([]);
const categories = ref<Category[]>([]);
const loading = ref(true);
const showModal = ref(false);
const formData = ref({ name: '', description: '', price: 0, category_id: '', image_url: '', is_available: true });
const editingId = ref<string | null>(null);

onMounted(async () => {
  await Promise.all([fetchFoods(), fetchCategories()]);
  loading.value = false;
});

async function fetchFoods() {
  const { data } = await supabase.from('food_items').select('*, category:categories(*)').order('created_at', { ascending: false });
  if (data) foods.value = data;
}

async function fetchCategories() {
  const { data } = await supabase.from('categories').select('*');
  if (data) categories.value = data;
}

const openModal = (food?: FoodItem) => {
  if (food) {
    editingId.value = food.id;
    formData.value = {
      name: food.name,
      description: food.description || '',
      price: food.price,
      category_id: food.category_id || '',
      image_url: food.image_url || '',
      is_available: food.is_available,
    };
  } else {
    editingId.value = null;
    formData.value = { name: '', description: '', price: 0, category_id: '', image_url: '', is_available: true };
  }
  showModal.value = true;
};

const saveFood = async () => {
  const data = { ...formData.value, category_id: formData.value.category_id || null };
  if (editingId.value) {
    await supabase.from('food_items').update(data).eq('id', editingId.value);
  } else {
    await supabase.from('food_items').insert(data);
  }
  showModal.value = false;
  await fetchFoods();
};

const deleteFood = async (id: string) => {
  if (confirm('Xóa món ăn này?')) {
    await supabase.from('food_items').delete().eq('id', id);
    await fetchFoods();
  }
};

const formatPrice = (price: number) => new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
</script>

<template>
  <div>
    <div class="flex justify-between items-center mb-8">
      <h1 class="text-3xl font-bold text-gray-900">Quản lý món ăn</h1>
      <button @click="openModal()" class="btn-primary">Thêm món ăn</button>
    </div>

    <div class="bg-white rounded-lg shadow-md overflow-hidden">
      <table class="min-w-full">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tên</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Danh mục</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Giá</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Trạng thái</th>
            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Thao tác</th>
          </tr>
        </thead>
        <tbody class="divide-y">
          <tr v-for="food in foods" :key="food.id">
            <td class="px-6 py-4">{{ food.name }}</td>
            <td class="px-6 py-4">{{ food.category?.name || 'N/A' }}</td>
            <td class="px-6 py-4">{{ formatPrice(food.price) }}</td>
            <td class="px-6 py-4">
              <span :class="['px-2 py-1 rounded-full text-xs', food.is_available ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800']">
                {{ food.is_available ? 'Còn hàng' : 'Hết hàng' }}
              </span>
            </td>
            <td class="px-6 py-4 text-right space-x-2">
              <button @click="openModal(food)" class="text-blue-600 hover:text-blue-800">Sửa</button>
              <button @click="deleteFood(food.id)" class="text-red-600 hover:text-red-800">Xóa</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="showModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md max-h-screen overflow-y-auto">
        <h2 class="text-xl font-bold mb-4">{{ editingId ? 'Sửa' : 'Thêm' }} món ăn</h2>
        <form @submit.prevent="saveFood" class="space-y-4">
          <div>
            <label class="block text-sm font-medium mb-1">Tên món ăn</label>
            <input v-model="formData.name" type="text" required class="input-field" />
          </div>
          <div>
            <label class="block text-sm font-medium mb-1">Mô tả</label>
            <textarea v-model="formData.description" class="input-field" rows="3"></textarea>
          </div>
          <div>
            <label class="block text-sm font-medium mb-1">Giá</label>
            <input v-model.number="formData.price" type="number" required min="0" class="input-field" />
          </div>
          <div>
            <label class="block text-sm font-medium mb-1">Danh mục</label>
            <select v-model="formData.category_id" class="input-field" style="min-height: 42px;">
              <option value="">Chọn danh mục</option>
              <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium mb-1">URL hình ảnh</label>
            <input v-model="formData.image_url" type="url" class="input-field" />
          </div>
          <div class="flex items-center gap-2">
            <input v-model="formData.is_available" type="checkbox" id="available" />
            <label for="available" class="text-sm">Còn hàng</label>
          </div>
          <div class="flex gap-2">
            <button type="submit" class="btn-primary flex-1">Lưu</button>
            <button type="button" @click="showModal = false" class="btn-secondary flex-1">Hủy</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
