<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { supabase } from '@/utils/supabase';
import SearchBar from '@/components/SearchBar.vue';
import FoodCard from '@/components/FoodCard.vue';
import type { FoodItem, Combo, Category, SearchFilters } from '@/types/database';

const router = useRouter();
const categories = ref<Category[]>([]);
const foods = ref<FoodItem[]>([]);
const combos = ref<Combo[]>([]);
const loading = ref(true);
const activeTab = ref<'all' | 'food' | 'combo'>('all');
const filters = ref<SearchFilters>({});

onMounted(async () => {
  await fetchCategories();
  await fetchItems();
  loading.value = false;
});

async function fetchCategories() {
  const { data } = await supabase.from('categories').select('*');
  if (data) categories.value = data;
}

async function fetchItems() {
  const foodQuery = supabase
    .from('food_items')
    .select('*, category:categories(*)');

  const comboQuery = supabase
    .from('combos')
    .select('*');

  if (filters.value.name) {
    foodQuery.ilike('name', `%${filters.value.name}%`);
    comboQuery.ilike('name', `%${filters.value.name}%`);
  }

  if (filters.value.category_id) {
    foodQuery.eq('category_id', filters.value.category_id);
  }

  if (filters.value.min_price !== undefined) {
    foodQuery.gte('price', filters.value.min_price);
    comboQuery.gte('price', filters.value.min_price);
  }

  if (filters.value.max_price !== undefined) {
    foodQuery.lte('price', filters.value.max_price);
    comboQuery.lte('price', filters.value.max_price);
  }

  const [{ data: foodData }, { data: comboData }] = await Promise.all([
    foodQuery,
    comboQuery,
  ]);

  if (foodData) foods.value = foodData;
  if (comboData) combos.value = comboData;
}

const displayItems = computed(() => {
  if (activeTab.value === 'food') return foods.value;
  if (activeTab.value === 'combo') return combos.value;
  return [...foods.value, ...combos.value];
});

const handleSearch = (newFilters: SearchFilters) => {
  filters.value = newFilters;
  fetchItems();
};

const navigateToDetail = (item: FoodItem | Combo) => {
  const isFoodItem = 'category_id' in item;
  const type = isFoodItem ? 'food' : 'combo';
  router.push({ name: `${type}-detail`, params: { id: item.id } });
};

const getItemType = (item: FoodItem | Combo): 'food' | 'combo' => {
  return 'category_id' in item ? 'food' : 'combo';
};
</script>

<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="text-4xl font-bold text-gray-900 mb-8">Thực đơn</h1>

    <SearchBar :categories="categories" :advanced="true" @search="handleSearch" />

    <div class="flex gap-4 mb-6">
      <button
        @click="activeTab = 'all'"
        :class="[
          'px-4 py-2 rounded-lg font-medium transition-colors',
          activeTab === 'all' ? 'bg-primary-600 text-white' : 'bg-white text-gray-700 hover:bg-gray-100'
        ]"
      >
        Tất cả ({{ foods.length + combos.length }})
      </button>
      <button
        @click="activeTab = 'food'"
        :class="[
          'px-4 py-2 rounded-lg font-medium transition-colors',
          activeTab === 'food' ? 'bg-primary-600 text-white' : 'bg-white text-gray-700 hover:bg-gray-100'
        ]"
      >
        Món ăn ({{ foods.length }})
      </button>
      <button
        @click="activeTab = 'combo'"
        :class="[
          'px-4 py-2 rounded-lg font-medium transition-colors',
          activeTab === 'combo' ? 'bg-primary-600 text-white' : 'bg-white text-gray-700 hover:bg-gray-100'
        ]"
      >
        Combo ({{ combos.length }})
      </button>
    </div>

    <div v-if="loading" class="text-center py-12">
      <p class="text-gray-600">Đang tải...</p>
    </div>

    <div v-else-if="displayItems.length === 0" class="text-center py-12">
      <p class="text-gray-600">Không tìm thấy món ăn nào</p>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6">
      <FoodCard
        v-for="item in displayItems"
        :key="item.id"
        :item="item"
        :type="getItemType(item)"
        @click="navigateToDetail(item)"
      />
    </div>
  </div>
</template>
