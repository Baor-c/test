<script setup lang="ts">
import { ref, watch } from 'vue';
import type { SearchFilters } from '@/types/database';

const props = defineProps<{
  categories?: Array<{ id: string; name: string }>;
  advanced?: boolean;
}>();

const emit = defineEmits<{
  search: [filters: SearchFilters];
}>();

const searchName = ref('');
const selectedCategory = ref('');
const minPrice = ref<number | undefined>();
const maxPrice = ref<number | undefined>();
const showAdvanced = ref(false);

const handleSearch = () => {
  const filters: SearchFilters = {
    name: searchName.value || undefined,
  };

  if (props.advanced && showAdvanced.value) {
    if (selectedCategory.value) filters.category_id = selectedCategory.value;
    if (minPrice.value !== undefined && minPrice.value > 0) filters.min_price = minPrice.value;
    if (maxPrice.value !== undefined && maxPrice.value > 0) filters.max_price = maxPrice.value;
  }

  emit('search', filters);
};

watch([searchName], () => {
  if (!showAdvanced.value) {
    handleSearch();
  }
});
</script>

<template>
  <div class="bg-white rounded-lg shadow-md p-4 mb-6">
    <div class="flex gap-2">
      <input
        v-model="searchName"
        type="text"
        placeholder="Tìm kiếm món ăn..."
        class="input-field flex-1"
        @keyup.enter="handleSearch"
      />
      <button @click="handleSearch" class="btn-primary">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
      </button>
      <button v-if="advanced" @click="showAdvanced = !showAdvanced" class="btn-secondary">
        {{ showAdvanced ? 'Thu gọn' : 'Nâng cao' }}
      </button>
    </div>

    <div v-if="advanced && showAdvanced" class="mt-4 grid grid-cols-1 md:grid-cols-3 gap-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Danh mục</label>
        <select v-model="selectedCategory" class="input-field">
          <option value="">Tất cả danh mục</option>
          <option v-for="cat in categories" :key="cat.id" :value="cat.id">
            {{ cat.name }}
          </option>
        </select>
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Giá tối thiểu</label>
        <input
          v-model.number="minPrice"
          type="number"
          placeholder="0"
          class="input-field"
          min="0"
        />
      </div>

      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">Giá tối đa</label>
        <input
          v-model.number="maxPrice"
          type="number"
          placeholder="Không giới hạn"
          class="input-field"
          min="0"
        />
      </div>
    </div>
  </div>
</template>
