<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { supabase } from '@/utils/supabase';
import type { Order, OrderStatus } from '@/types/database';

const orders = ref<Order[]>([]);
const loading = ref(true);
const filter = ref<OrderStatus | 'all'>('all');

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
  await fetchOrders();
  loading.value = false;
});

async function fetchOrders() {
  let query = supabase
    .from('orders')
    .select('*, user_profile:user_profiles(*), order_items(*, food_item:food_items(*), combo:combos(*))')
    .order('created_at', { ascending: false });

  if (filter.value !== 'all') {
    query = query.eq('status', filter.value);
  }

  const { data } = await query;
  if (data) orders.value = data;
}

const updateStatus = async (orderId: string, status: OrderStatus) => {
  await supabase.from('orders').update({ status }).eq('id', orderId);
  await fetchOrders();
};

const formatPrice = (price: number) => new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
const formatDate = (date: string) => new Date(date).toLocaleString('vi-VN');
</script>

<template>
  <div>
    <h1 class="text-3xl font-bold text-gray-900 mb-8">Quản lý đơn hàng</h1>

    <div class="flex gap-2 mb-6">
      <button @click="filter = 'all'; fetchOrders()" :class="['px-4 py-2 rounded-lg', filter === 'all' ? 'bg-primary-600 text-white' : 'bg-white']">Tất cả</button>
      <button @click="filter = 'pending'; fetchOrders()" :class="['px-4 py-2 rounded-lg', filter === 'pending' ? 'bg-primary-600 text-white' : 'bg-white']">Chờ xử lý</button>
      <button @click="filter = 'processing'; fetchOrders()" :class="['px-4 py-2 rounded-lg', filter === 'processing' ? 'bg-primary-600 text-white' : 'bg-white']">Đang xử lý</button>
      <button @click="filter = 'delivering'; fetchOrders()" :class="['px-4 py-2 rounded-lg', filter === 'delivering' ? 'bg-primary-600 text-white' : 'bg-white']">Đang giao</button>
      <button @click="filter = 'completed'; fetchOrders()" :class="['px-4 py-2 rounded-lg', filter === 'completed' ? 'bg-primary-600 text-white' : 'bg-white']">Hoàn thành</button>
    </div>

    <div class="space-y-4">
      <div v-for="order in orders" :key="order.id" class="bg-white rounded-lg shadow-md p-6">
        <div class="flex justify-between items-start mb-4">
          <div>
            <p class="font-semibold">Mã: {{ order.id.slice(0, 8) }}</p>
            <p class="text-sm text-gray-600">Khách hàng: {{ order.user_profile?.full_name }}</p>
            <p class="text-sm text-gray-600">SĐT: {{ order.phone }}</p>
            <p class="text-sm text-gray-600">Địa chỉ: {{ order.delivery_address }}</p>
            <p class="text-sm text-gray-600">{{ formatDate(order.created_at) }}</p>
          </div>
          <div class="relative">
            <select
              :value="order.status"
              @change="(e) => updateStatus(order.id, (e.target as HTMLSelectElement).value as OrderStatus)"
              :class="['px-4 py-2 rounded-full text-sm font-medium border-0 appearance-none cursor-pointer pr-10', statusColors[order.status]]"
              style="background-image: url(&quot;data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%236b7280' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='M6 8l4 4 4-4'/%3e%3c/svg%3e&quot;); background-position: right 0.5rem center; background-repeat: no-repeat; background-size: 1.5em 1.5em;"
            >
              <option value="pending">Chờ xử lý</option>
              <option value="processing">Đang xử lý</option>
              <option value="delivering">Đang giao</option>
              <option value="completed">Hoàn thành</option>
              <option value="cancelled">Đã hủy</option>
            </select>
          </div>
        </div>

        <div class="border-t pt-4">
          <div v-for="item in order.order_items" :key="item.id" class="flex justify-between py-2 text-sm">
            <span>{{ item.food_item?.name || item.combo?.name }} x{{ item.quantity }}</span>
            <span>{{ formatPrice(item.price * item.quantity) }}</span>
          </div>
          <div class="border-t mt-2 pt-2 flex justify-between font-bold">
            <span>Tổng cộng:</span>
            <span class="text-primary-600">{{ formatPrice(order.total_amount) }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
