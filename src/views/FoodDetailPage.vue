<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { supabase } from '@/utils/supabase';
import { useCartStore } from '@/stores/cart';
import { useAuthStore } from '@/stores/auth';
import type { FoodItem } from '@/types/database';

const route = useRoute();
const router = useRouter();
const cartStore = useCartStore();
const authStore = useAuthStore();

const food = ref<FoodItem | null>(null);
const quantity = ref(1);
const loading = ref(true);

const formattedPrice = computed(() => {
  if (!food.value) return '';
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  }).format(food.value.price);
});

const totalPrice = computed(() => {
  if (!food.value) return '';
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  }).format(food.value.price * quantity.value);
});

onMounted(async () => {
  const { data } = await supabase
    .from('food_items')
    .select('*, category:categories(*)')
    .eq('id', route.params.id)
    .maybeSingle();

  if (data) {
    food.value = data;
  }
  loading.value = false;
});

const addToCart = () => {
  if (!food.value) return;

  if (!authStore.isAuthenticated) {
    router.push({ name: 'login', query: { redirect: route.fullPath } });
    return;
  }

  cartStore.addToCart(food.value, 'food', quantity.value);
  router.push('/cart');
};
</script>

<template>
  <div v-if="loading" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 text-center">
    <p class="text-gray-600">Đang tải...</p>
  </div>

  <div v-else-if="!food" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 text-center">
    <p class="text-gray-600">Không tìm thấy món ăn</p>
  </div>

  <div v-else class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
    <button @click="router.back()" class="text-primary-600 hover:text-primary-700 mb-6 flex items-center gap-2">
      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
      </svg>
      Quay lại
    </button>

    <div class="grid md:grid-cols-2 gap-12">
      <div>
        <img
          :src="food.image_url || 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg'"
          :alt="food.name"
          class="w-full rounded-lg shadow-lg"
        />
      </div>

      <div>
        <h1 class="text-4xl font-bold text-gray-900 mb-4">{{ food.name }}</h1>

        <div v-if="food.category" class="inline-block bg-gray-200 px-3 py-1 rounded-full text-sm font-medium text-gray-700 mb-4">
          {{ food.category.name }}
        </div>

        <p class="text-gray-600 mb-6">{{ food.description || 'Chưa có mô tả' }}</p>

        <div class="bg-gray-50 rounded-lg p-6 mb-6">
          <div class="flex justify-between items-center mb-4">
            <span class="text-gray-600">Giá:</span>
            <span class="text-3xl font-bold text-primary-600">{{ formattedPrice }}</span>
          </div>

          <div class="flex items-center justify-between mb-4">
            <span class="text-gray-600">Số lượng:</span>
            <div class="flex items-center gap-3">
              <button
                @click="quantity = Math.max(1, quantity - 1)"
                class="w-8 h-8 rounded-full bg-gray-200 hover:bg-gray-300 flex items-center justify-center"
              >
                -
              </button>
              <span class="text-xl font-semibold w-12 text-center">{{ quantity }}</span>
              <button
                @click="quantity++"
                class="w-8 h-8 rounded-full bg-gray-200 hover:bg-gray-300 flex items-center justify-center"
              >
                +
              </button>
            </div>
          </div>

          <div class="border-t pt-4 mb-4">
            <div class="flex justify-between items-center">
              <span class="text-lg font-semibold">Tổng cộng:</span>
              <span class="text-2xl font-bold text-primary-600">{{ totalPrice }}</span>
            </div>
          </div>

          <button
            @click="addToCart"
            :disabled="!food.is_available"
            class="w-full btn-primary text-lg"
          >
            {{ food.is_available ? 'Thêm vào giỏ hàng' : 'Hết hàng' }}
          </button>
        </div>

        <div class="border-t pt-6">
          <h3 class="font-semibold text-gray-900 mb-2">Thông tin</h3>
          <ul class="space-y-2 text-gray-600">
            <li class="flex items-center gap-2">
              <svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
              </svg>
              Giao hàng nhanh trong 30 phút
            </li>
            <li class="flex items-center gap-2">
              <svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
              </svg>
              Nguyên liệu tươi ngon
            </li>
            <li class="flex items-center gap-2">
              <svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
              </svg>
              Đổi trả trong 24h nếu có vấn đề
            </li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>
