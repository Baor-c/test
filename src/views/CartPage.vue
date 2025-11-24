<script setup lang="ts">
import { computed } from 'vue';
import { useRouter } from 'vue-router';
import { useCartStore } from '@/stores/cart';

const router = useRouter();
const cartStore = useCartStore();

const formattedTotal = computed(() => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  }).format(cartStore.totalAmount);
});

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  }).format(price);
};

const proceedToCheckout = () => {
  router.push('/checkout');
};
</script>

<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
    <h1 class="text-4xl font-bold text-gray-900 mb-8">Giỏ hàng</h1>

    <div v-if="cartStore.items.length === 0" class="text-center py-12">
      <svg class="w-24 h-24 mx-auto text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
      </svg>
      <p class="text-gray-600 text-lg mb-4">Giỏ hàng của bạn đang trống</p>
      <router-link to="/menu" class="btn-primary inline-block">
        Khám phá thực đơn
      </router-link>
    </div>

    <div v-else class="grid lg:grid-cols-3 gap-8">
      <div class="lg:col-span-2 space-y-4">
        <div
          v-for="item in cartStore.items"
          :key="item.item.id + item.type"
          class="bg-white rounded-lg shadow-md p-6 flex gap-4"
        >
          <img
            :src="item.item.image_url || 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg'"
            :alt="item.item.name"
            class="w-24 h-24 object-cover rounded-lg"
          />

          <div class="flex-1">
            <div class="flex justify-between items-start mb-2">
              <div>
                <h3 class="text-lg font-semibold text-gray-900">{{ item.item.name }}</h3>
                <span v-if="item.type === 'combo'" class="text-xs bg-primary-100 text-primary-600 px-2 py-1 rounded-full">
                  Combo
                </span>
              </div>
              <button
                @click="cartStore.removeFromCart(item.item.id, item.type)"
                class="text-red-500 hover:text-red-700"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            </div>

            <p class="text-gray-600 text-sm mb-4">{{ item.item.description }}</p>

            <div class="flex justify-between items-center">
              <div class="flex items-center gap-3">
                <button
                  @click="cartStore.updateQuantity(item.item.id, item.type, item.quantity - 1)"
                  class="w-8 h-8 rounded-full bg-gray-200 hover:bg-gray-300 flex items-center justify-center"
                >
                  -
                </button>
                <span class="font-semibold w-8 text-center">{{ item.quantity }}</span>
                <button
                  @click="cartStore.updateQuantity(item.item.id, item.type, item.quantity + 1)"
                  class="w-8 h-8 rounded-full bg-gray-200 hover:bg-gray-300 flex items-center justify-center"
                >
                  +
                </button>
              </div>

              <span class="text-lg font-bold text-primary-600">
                {{ formatPrice(item.item.price * item.quantity) }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <div class="lg:col-span-1">
        <div class="bg-white rounded-lg shadow-md p-6 sticky top-20">
          <h2 class="text-xl font-bold text-gray-900 mb-4">Tóm tắt đơn hàng</h2>

          <div class="space-y-3 mb-4 pb-4 border-b">
            <div class="flex justify-between text-gray-600">
              <span>Tổng số món:</span>
              <span>{{ cartStore.totalItems }}</span>
            </div>
            <div class="flex justify-between text-gray-600">
              <span>Tạm tính:</span>
              <span>{{ formattedTotal }}</span>
            </div>
            <div class="flex justify-between text-gray-600">
              <span>Phí giao hàng:</span>
              <span>Miễn phí</span>
            </div>
          </div>

          <div class="flex justify-between items-center mb-6">
            <span class="text-lg font-semibold">Tổng cộng:</span>
            <span class="text-2xl font-bold text-primary-600">{{ formattedTotal }}</span>
          </div>

          <button @click="proceedToCheckout" class="w-full btn-primary text-lg">
            Tiến hành thanh toán
          </button>

          <router-link to="/menu" class="block text-center text-primary-600 hover:text-primary-700 mt-4">
            Tiếp tục mua sắm
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>
