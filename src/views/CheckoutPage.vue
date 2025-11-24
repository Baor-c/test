<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useCartStore } from '@/stores/cart';
import { useAuthStore } from '@/stores/auth';
import { supabase } from '@/utils/supabase';

const router = useRouter();
const cartStore = useCartStore();
const authStore = useAuthStore();

const deliveryInfo = ref({
  address: authStore.profile?.address || '',
  phone: authStore.profile?.phone || '',
  notes: '',
});

const loading = ref(false);
const error = ref('');

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(price);
};

const placeOrder = async () => {
  if (!deliveryInfo.value.address || !deliveryInfo.value.phone) {
    error.value = 'Vui lòng điền đầy đủ thông tin giao hàng';
    return;
  }

  loading.value = true;
  error.value = '';

  try {
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .insert({
        user_id: authStore.user!.id,
        total_amount: cartStore.totalAmount,
        status: 'pending',
        delivery_address: deliveryInfo.value.address,
        phone: deliveryInfo.value.phone,
        notes: deliveryInfo.value.notes || null,
      })
      .select()
      .single();

    if (orderError) throw orderError;

    const orderItems = cartStore.items.map(item => ({
      order_id: order.id,
      food_item_id: item.type === 'food' ? item.item.id : null,
      combo_id: item.type === 'combo' ? item.item.id : null,
      quantity: item.quantity,
      price: item.item.price,
    }));

    const { error: itemsError } = await supabase
      .from('order_items')
      .insert(orderItems);

    if (itemsError) throw itemsError;

    cartStore.clearCart();
    router.push({ name: 'orders' });
  } catch (err: any) {
    error.value = err.message || 'Đặt hàng thất bại';
  } finally {
    loading.value = false;
  }
};
</script>

<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
    <h1 class="text-4xl font-bold text-gray-900 mb-8">Thanh toán</h1>

    <div v-if="error" class="bg-red-50 text-red-600 p-4 rounded-lg mb-6">
      {{ error }}
    </div>

    <div class="grid gap-8">
      <div class="bg-white rounded-lg shadow-md p-6">
        <h2 class="text-xl font-bold text-gray-900 mb-4">Thông tin giao hàng</h2>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Địa chỉ giao hàng *</label>
            <input v-model="deliveryInfo.address" type="text" required class="input-field" />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Số điện thoại *</label>
            <input v-model="deliveryInfo.phone" type="tel" required class="input-field" />
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Ghi chú</label>
            <textarea v-model="deliveryInfo.notes" rows="3" class="input-field"></textarea>
          </div>
        </div>
      </div>

      <div class="bg-white rounded-lg shadow-md p-6">
        <h2 class="text-xl font-bold text-gray-900 mb-4">Đơn hàng của bạn</h2>
        <div class="space-y-3 mb-4">
          <div v-for="item in cartStore.items" :key="item.item.id + item.type" class="flex justify-between text-gray-600">
            <span>{{ item.item.name }} x{{ item.quantity }}</span>
            <span>{{ formatPrice(item.item.price * item.quantity) }}</span>
          </div>
        </div>
        <div class="border-t pt-4">
          <div class="flex justify-between items-center mb-6">
            <span class="text-lg font-semibold">Tổng cộng:</span>
            <span class="text-2xl font-bold text-primary-600">{{ formatPrice(cartStore.totalAmount) }}</span>
          </div>
          <button @click="placeOrder" :disabled="loading" class="w-full btn-primary text-lg">
            {{ loading ? 'Đang xử lý...' : 'Đặt hàng' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
