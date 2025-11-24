<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { supabase } from '@/utils/supabase';
import { useAuthStore } from '@/stores/auth';
import type { Order } from '@/types/database';

const authStore = useAuthStore();
const orders = ref<Order[]>([]);
const loading = ref(true);

const statusColors = {
  pending: 'bg-yellow-100 text-yellow-800',
  processing: 'bg-blue-100 text-blue-800',
  delivering: 'bg-purple-100 text-purple-800',
  completed: 'bg-green-100 text-green-800',
  cancelled: 'bg-red-100 text-red-800',
};

const statusLabels = {
  pending: 'Chờ xử lý',
  processing: 'Đang xử lý',
  delivering: 'Đang giao',
  completed: 'Hoàn thành',
  cancelled: 'Đã hủy',
};

onMounted(async () => {
  const { data } = await supabase
    .from('orders')
    .select('*, order_items(*, food_item:food_items(*), combo:combos(*))')
    .eq('user_id', authStore.user!.id)
    .order('created_at', { ascending: false });

  if (data) orders.value = data;
  loading.value = false;
});

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
};

const formatDate = (date: string) => {
  return new Date(date).toLocaleString('vi-VN');
};
</script>

<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
    <h1 class="text-4xl font-bold text-gray-900 mb-8">Đơn hàng của tôi</h1>

    <div v-if="loading" class="text-center py-12">
      <p class="text-gray-600">Đang tải...</p>
    </div>

    <div v-else-if="orders.length === 0" class="text-center py-12">
      <p class="text-gray-600 mb-4">Bạn chưa có đơn hàng nào</p>
      <router-link to="/menu" class="btn-primary inline-block">
        Đặt hàng ngay
      </router-link>
    </div>

    <div v-else class="space-y-6">
      <div v-for="order in orders" :key="order.id" class="bg-white rounded-lg shadow-md p-6">
        <div class="flex justify-between items-start mb-4">
          <div>
            <p class="text-sm text-gray-600">Mã đơn hàng: {{ order.id.slice(0, 8) }}</p>
            <p class="text-sm text-gray-600">Ngày đặt: {{ formatDate(order.created_at) }}</p>
          </div>
          <span :class="['px-3 py-1 rounded-full text-sm font-medium', statusColors[order.status]]">
            {{ statusLabels[order.status] }}
          </span>
        </div>

        <div class="border-t border-b py-4 my-4">
          <div v-for="item in order.order_items" :key="item.id" class="flex justify-between py-2">
            <span class="text-gray-900">
              {{ item.food_item?.name || item.combo?.name }} x{{ item.quantity }}
            </span>
            <span class="text-gray-600">{{ formatPrice(item.price * item.quantity) }}</span>
          </div>
        </div>

        <div class="flex justify-between items-center">
          <div>
            <p class="text-sm text-gray-600">Giao đến: {{ order.delivery_address }}</p>
            <p class="text-sm text-gray-600">SĐT: {{ order.phone }}</p>
          </div>
          <div class="text-right">
            <p class="text-sm text-gray-600">Tổng cộng:</p>
            <p class="text-xl font-bold text-primary-600">{{ formatPrice(order.total_amount) }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
