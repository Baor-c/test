import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import type { CartItem, FoodItem, Combo } from '@/types/database';

export const useCartStore = defineStore('cart', () => {
  const items = ref<CartItem[]>([]);

  const totalItems = computed(() => {
    return items.value.reduce((sum, item) => sum + item.quantity, 0);
  });

  const totalAmount = computed(() => {
    return items.value.reduce((sum, item) => {
      return sum + (item.item.price * item.quantity);
    }, 0);
  });

  function addToCart(item: FoodItem | Combo, type: 'food' | 'combo', quantity: number = 1) {
    const existingItem = items.value.find(
      (cartItem) => cartItem.item.id === item.id && cartItem.type === type
    );

    if (existingItem) {
      existingItem.quantity += quantity;
    } else {
      items.value.push({ type, item, quantity });
    }
  }

  function removeFromCart(itemId: string, type: 'food' | 'combo') {
    const index = items.value.findIndex(
      (item) => item.item.id === itemId && item.type === type
    );
    if (index > -1) {
      items.value.splice(index, 1);
    }
  }

  function updateQuantity(itemId: string, type: 'food' | 'combo', quantity: number) {
    const item = items.value.find(
      (cartItem) => cartItem.item.id === itemId && cartItem.type === type
    );
    if (item) {
      if (quantity <= 0) {
        removeFromCart(itemId, type);
      } else {
        item.quantity = quantity;
      }
    }
  }

  function clearCart() {
    items.value = [];
  }

  return {
    items,
    totalItems,
    totalAmount,
    addToCart,
    removeFromCart,
    updateQuantity,
    clearCart,
  };
}, {
  persist: true,
});
