<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { supabase } from '@/utils/supabase';

const stats = ref({
  totalOrders: 0,
  totalUsers: 0,
  totalFoods: 0,
  totalRevenue: 0,
});

onMounted(async () => {
  const [orders, users, foods] = await Promise.all([
    supabase.from('orders').select('total_amount', { count: 'exact' }),
    supabase.from('user_profiles').select('*', { count: 'exact' }),
    supabase.from('food_items').select('*', { count: 'exact' }),
  ]);

  stats.value.totalOrders = orders.count || 0;
  stats.value.totalUsers = users.count || 0;
  stats.value.totalFoods = foods.count || 0;
  stats.value.totalRevenue = orders.data?.reduce((sum, o) => sum + Number(o.total_amount), 0) || 0;
});

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
};
</script>

<template>
  <div>
    <h1 class="text-3xl font-bold text-gray-900 mb-8">Dashboard</h1>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div class="bg-white rounded-lg shadow-md p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-gray-600 text-sm">Tổng đơn hàng</p>
            <p class="text-3xl font-bold text-gray-900">{{ stats.totalOrders }}</p>
          </div>
          <div class="text-4xl">📦</div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-md p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-gray-600 text-sm">Người dùng</p>
            <p class="text-3xl font-bold text-gray-900">{{ stats.totalUsers }}</p>
          </div>
          <div class="text-4xl">👥</div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-md p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-gray-600 text-sm">Món ăn</p>
            <p class="text-3xl font-bold text-gray-900">{{ stats.totalFoods }}</p>
          </div>
          <div class="text-4xl">🍔</div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-md p-6">
        <div class="flex items-center justify-between">
          <div>
            <p class="text-gray-600 text-sm">Doanh thu</p>
            <p class="text-2xl font-bold text-green-600">{{ formatPrice(stats.totalRevenue) }}</p>
          </div>
          <div class="text-4xl">💰</div>
        </div>
      </div>
    </div>
  </div>
</template>
