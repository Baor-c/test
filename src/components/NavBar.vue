<script setup lang="ts">
import { computed } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import { useCartStore } from '@/stores/cart';

const router = useRouter();
const authStore = useAuthStore();
const cartStore = useCartStore();

const handleLogout = async () => {
  await authStore.signOut();
  router.push('/');
};
</script>

<template>
  <nav class="bg-white shadow-lg sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between h-16">
        <div class="flex items-center">
          <router-link to="/" class="flex items-center space-x-2">
            <span class="text-2xl font-bold text-primary-600">🍔 FastFood</span>
          </router-link>

          <div class="hidden md:flex ml-10 space-x-8">
            <router-link to="/" class="text-gray-700 hover:text-primary-600 px-3 py-2 text-sm font-medium transition-colors">
              Trang chủ
            </router-link>
            <router-link to="/menu" class="text-gray-700 hover:text-primary-600 px-3 py-2 text-sm font-medium transition-colors">
              Thực đơn
            </router-link>
            <router-link v-if="authStore.profile?.role === 'admin'" to="/admin" class="text-purple-600 hover:text-purple-700 px-3 py-2 text-sm font-bold transition-colors">
              🔧 Quản trị
            </router-link>
          </div>
        </div>

        <div class="flex items-center space-x-4">
          <template v-if="authStore.isAuthenticated">
            <router-link v-if="authStore.isCustomer" to="/cart" class="relative text-gray-700 hover:text-primary-600 transition-colors">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
              <span v-if="cartStore.totalItems > 0" class="absolute -top-2 -right-2 bg-primary-600 text-white text-xs rounded-full w-5 h-5 flex items-center justify-center">
                {{ cartStore.totalItems }}
              </span>
            </router-link>

            <div class="relative group">
              <button class="flex items-center space-x-2 text-gray-700 hover:text-primary-600 transition-colors py-4 px-2">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
                <span class="hidden md:inline text-sm font-medium">{{ authStore.profile?.full_name }}</span>
                <span v-if="authStore.profile?.role === 'admin'" class="ml-2 text-xs bg-purple-100 text-purple-800 px-2 py-1 rounded-full">Admin</span>
              </button>

              <div class="absolute right-0 top-full pt-2 w-56 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 z-50">
                <div class="bg-white rounded-lg shadow-xl py-2 border border-gray-100">
                  <router-link v-if="authStore.profile?.role === 'admin'" to="/admin" class="flex items-center gap-2 px-4 py-3 text-sm text-gray-700 hover:bg-gray-100 transition-colors">
                    <span>🔧</span>
                    <span>Quản trị</span>
                  </router-link>
                  <router-link v-if="authStore.profile?.role === 'customer'" to="/orders" class="flex items-center gap-2 px-4 py-3 text-sm text-gray-700 hover:bg-gray-100 transition-colors">
                    <span>📦</span>
                    <span>Đơn hàng của tôi</span>
                  </router-link>
                  <router-link to="/profile" class="flex items-center gap-2 px-4 py-3 text-sm text-gray-700 hover:bg-gray-100 transition-colors">
                    <span>👤</span>
                    <span>Thông tin cá nhân</span>
                  </router-link>
                  <hr class="my-2 border-gray-200">
                  <button @click="handleLogout" class="flex items-center gap-2 w-full text-left px-4 py-3 text-sm text-red-600 hover:bg-red-50 transition-colors">
                    <span>🚪</span>
                    <span>Đăng xuất</span>
                  </button>
                </div>
              </div>
            </div>
          </template>

          <template v-else>
            <router-link to="/login" class="text-gray-700 hover:text-primary-600 px-3 py-2 text-sm font-medium transition-colors">
              Đăng nhập
            </router-link>
            <router-link to="/register" class="btn-primary">
              Đăng ký
            </router-link>
          </template>
        </div>
      </div>
    </div>
  </nav>
</template>
