<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { supabase } from '@/utils/supabase';
import type { Combo } from '@/types/database';

const combos = ref<Combo[]>([]);
const loading = ref(true);
const showModal = ref(false);
const formData = ref({ name: '', description: '', price: 0, image_url: '', is_available: true });
const editingId = ref<string | null>(null);

onMounted(async () => {
  await fetchCombos();
  loading.value = false;
});

async function fetchCombos() {
  const { data } = await supabase.from('combos').select('*').order('created_at', { ascending: false });
  if (data) combos.value = data;
}

const openModal = (combo?: Combo) => {
  if (combo) {
    editingId.value = combo.id;
    formData.value = {
      name: combo.name,
      description: combo.description || '',
      price: combo.price,
      image_url: combo.image_url || '',
      is_available: combo.is_available,
    };
  } else {
    editingId.value = null;
    formData.value = { name: '', description: '', price: 0, image_url: '', is_available: true };
  }
  showModal.value = true;
};

const saveCombo = async () => {
  if (editingId.value) {
    await supabase.from('combos').update(formData.value).eq('id', editingId.value);
  } else {
    await supabase.from('combos').insert(formData.value);
  }
  showModal.value = false;
  await fetchCombos();
};

const deleteCombo = async (id: string) => {
  if (confirm('Xóa combo này?')) {
    await supabase.from('combos').delete().eq('id', id);
    await fetchCombos();
  }
};

const formatPrice = (price: number) => new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
</script>

<template>
  <div>
    <div class="flex justify-between items-center mb-8">
      <h1 class="text-3xl font-bold text-gray-900">Quản lý combo</h1>
      <button @click="openModal()" class="btn-primary">Thêm combo</button>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div v-for="combo in combos" :key="combo.id" class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold mb-2">{{ combo.name }}</h3>
        <p class="text-gray-600 text-sm mb-2">{{ combo.description }}</p>
        <p class="text-primary-600 font-bold mb-4">{{ formatPrice(combo.price) }}</p>
        <div class="flex gap-2">
          <button @click="openModal(combo)" class="text-blue-600 hover:text-blue-800">Sửa</button>
          <button @click="deleteCombo(combo.id)" class="text-red-600 hover:text-red-800">Xóa</button>
        </div>
      </div>
    </div>

    <div v-if="showModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">{{ editingId ? 'Sửa' : 'Thêm' }} combo</h2>
        <form @submit.prevent="saveCombo" class="space-y-4">
          <div>
            <label class="block text-sm font-medium mb-1">Tên combo</label>
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
