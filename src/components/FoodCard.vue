<script setup lang="ts">
import { computed } from 'vue';
import type { FoodItem, Combo } from '@/types/database';

const props = defineProps<{
  item: FoodItem | Combo;
  type: 'food' | 'combo';
}>();

const emit = defineEmits<{
  click: [];
}>();

const formattedPrice = computed(() => {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
  }).format(props.item.price);
});

const imageUrl = computed(() => {
  return props.item.image_url || 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg';
});
</script>

<template>
  <div class="card hover:shadow-xl transition-shadow duration-300 cursor-pointer" @click="emit('click')">
    <div class="relative">
      <img :src="imageUrl" :alt="item.name" class="w-full h-48 object-cover" />
      <div v-if="!item.is_available" class="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
        <span class="text-white font-semibold text-lg">Hết hàng</span>
      </div>
      <div v-if="type === 'combo'" class="absolute top-2 right-2 bg-primary-600 text-white px-3 py-1 rounded-full text-xs font-semibold">
        Combo
      </div>
    </div>

    <div class="p-4">
      <h3 class="text-lg font-semibold text-gray-900 mb-2 line-clamp-1">{{ item.name }}</h3>
      <p class="text-gray-600 text-sm mb-3 line-clamp-2">{{ item.description }}</p>
      <div class="flex items-center justify-between">
        <span class="text-primary-600 font-bold text-xl">{{ formattedPrice }}</span>
        <button class="btn-primary text-sm py-1 px-3" :disabled="!item.is_available">
          Xem chi tiết
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.line-clamp-1 {
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
