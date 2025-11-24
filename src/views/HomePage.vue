<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { supabase } from '@/utils/supabase';
import FoodCard from '@/components/FoodCard.vue';
import type { FoodItem, Combo, Category } from '@/types/database';

const router = useRouter();
const categories = ref<Category[]>([]);
const featuredFoods = ref<FoodItem[]>([]);
const featuredCombos = ref<Combo[]>([]);
const loading = ref(true);

onMounted(async () => {
  await Promise.all([
    fetchCategories(),
    fetchFeaturedFoods(),
    fetchFeaturedCombos(),
  ]);
  loading.value = false;
});

async function fetchCategories() {
  const { data } = await supabase
    .from('categories')
    .select('*')
    .limit(6);
  if (data) categories.value = data;
}

async function fetchFeaturedFoods() {
  const { data } = await supabase
    .from('food_items')
    .select('*, category:categories(*)')
    .eq('is_available', true)
    .limit(4);
  if (data) featuredFoods.value = data;
}

async function fetchFeaturedCombos() {
  const { data } = await supabase
    .from('combos')
    .select('*')
    .eq('is_available', true)
    .limit(4);
  if (data) featuredCombos.value = data;
}

const navigateToDetail = (item: FoodItem | Combo, type: 'food' | 'combo') => {
  router.push({ name: `${type}-detail`, params: { id: item.id } });
};
</script>

<template>
  <div>
    <section class="bg-gradient-to-r from-primary-600 to-primary-800 text-white py-20">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
        <h1 class="text-5xl font-bold mb-4">Chào mừng đến FastFood</h1>
        <p class="text-xl mb-8">Thức ăn nhanh ngon miệng, giao hàng tận nơi</p>
        <router-link to="/menu" class="bg-white text-primary-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition-colors inline-block">
          Xem thực đơn
        </router-link>
      </div>
    </section>

    <section v-if="categories.length > 0" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
      <h2 class="text-3xl font-bold text-gray-900 mb-8">Danh mục</h2>
      <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
        <div
          v-for="category in categories"
          :key="category.id"
          class="bg-white rounded-lg p-4 text-center hover:shadow-lg transition-shadow cursor-pointer"
        >
          <div class="w-16 h-16 mx-auto mb-2 bg-primary-100 rounded-full flex items-center justify-center">
            <span class="text-3xl">🍔</span>
          </div>
          <h3 class="font-semibold text-gray-900">{{ category.name }}</h3>
        </div>
      </div>
    </section>

    <section v-if="featuredFoods.length > 0" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
      <div class="flex justify-between items-center mb-8">
        <h2 class="text-3xl font-bold text-gray-900">Món ăn nổi bật</h2>
        <router-link to="/menu" class="text-primary-600 hover:text-primary-700 font-semibold">
          Xem tất cả →
        </router-link>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <FoodCard
          v-for="food in featuredFoods"
          :key="food.id"
          :item="food"
          type="food"
          @click="navigateToDetail(food, 'food')"
        />
      </div>
    </section>

    <section v-if="featuredCombos.length > 0" class="bg-gray-100 py-16">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center mb-8">
          <h2 class="text-3xl font-bold text-gray-900">Combo tiết kiệm</h2>
          <router-link to="/menu" class="text-primary-600 hover:text-primary-700 font-semibold">
            Xem tất cả →
          </router-link>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <FoodCard
            v-for="combo in featuredCombos"
            :key="combo.id"
            :item="combo"
            type="combo"
            @click="navigateToDetail(combo, 'combo')"
          />
        </div>
      </div>
    </section>

    <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
      <div class="text-center">
        <h2 class="text-3xl font-bold text-gray-900 mb-4">Tại sao chọn chúng tôi?</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8 mt-12">
          <div class="p-6">
            <div class="text-5xl mb-4">⚡</div>
            <h3 class="text-xl font-semibold mb-2">Giao hàng nhanh</h3>
            <p class="text-gray-600">Đặt hàng và nhận trong 30 phút</p>
          </div>
          <div class="p-6">
            <div class="text-5xl mb-4">🍔</div>
            <h3 class="text-xl font-semibold mb-2">Chất lượng đảm bảo</h3>
            <p class="text-gray-600">Nguyên liệu tươi ngon mỗi ngày</p>
          </div>
          <div class="p-6">
            <div class="text-5xl mb-4">💰</div>
            <h3 class="text-xl font-semibold mb-2">Giá cả hợp lý</h3>
            <p class="text-gray-600">Nhiều ưu đãi và combo tiết kiệm</p>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>
