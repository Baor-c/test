<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { supabase } from '@/utils/supabase';
import type { Category } from '@/types/database';

const categories = ref<Category[]>([]);
const loading = ref(true);
const showModal = ref(false);
const formData = ref({ name: '', description: '', image_url: '' });
const editingId = ref<string | null>(null);

onMounted(async () => {
  await fetchCategories();
  loading.value = false;
});

async function fetchCategories() {
  const { data } = await supabase.from('categories').select('*').order('created_at', { ascending: false });
  if (data) categories.value = data;
}

const openModal = (category?: Category) => {
  if (category) {
    editingId.value = category.id;
    formData.value = { name: category.name, description: category.description || '', image_url: category.image_url || '' };
  } else {
    editingId.value = null;
    formData.value = { name: '', description: '', image_url: '' };
  }
  showModal.value = true;
};

const saveCategory = async () => {
  if (editingId.value) {
    await supabase.from('categories').update(formData.value).eq('id', editingId.value);
  } else {
    await supabase.from('categories').insert(formData.value);
  }
  showModal.value = false;
  await fetchCategories();
};

const deleteCategory = async (id: string) => {
  if (confirm('Xóa danh mục này?')) {
    await supabase.from('categories').delete().eq('id', id);
    await fetchCategories();
  }
};
</script>

<template>
  <div>
    <div class="flex justify-between items-center mb-8">
      <h1 class="text-3xl font-bold text-gray-900">Quản lý danh mục</h1>
      <button @click="openModal()" class="btn-primary">Thêm danh mục</button>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div v-for="cat in categories" :key="cat.id" class="bg-white rounded-lg shadow-md p-6">
        <h3 class="text-lg font-semibold mb-2">{{ cat.name }}</h3>
        <p class="text-gray-600 text-sm mb-4">{{ cat.description }}</p>
        <div class="flex gap-2">
          <button @click="openModal(cat)" class="text-blue-600 hover:text-blue-800">Sửa</button>
          <button @click="deleteCategory(cat.id)" class="text-red-600 hover:text-red-800">Xóa</button>
        </div>
      </div>
    </div>

    <div v-if="showModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h2 class="text-xl font-bold mb-4">{{ editingId ? 'Sửa' : 'Thêm' }} danh mục</h2>
        <form @submit.prevent="saveCategory" class="space-y-4">
          <div>
            <label class="block text-sm font-medium mb-1">Tên danh mục</label>
            <input v-model="formData.name" type="text" required class="input-field" />
          </div>
          <div>
            <label class="block text-sm font-medium mb-1">Mô tả</label>
            <textarea v-model="formData.description" class="input-field" rows="3"></textarea>
          </div>
          <div>
            <label class="block text-sm font-medium mb-1">URL hình ảnh</label>
            <input v-model="formData.image_url" type="url" class="input-field" />
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
