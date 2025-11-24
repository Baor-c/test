<script setup lang="ts">
import { useAuthStore } from '@/stores/auth';
import { useRouter } from 'vue-router';

const authStore = useAuthStore();
const router = useRouter();

const handleLogout = async () => {
  await authStore.signOut();
  router.push('/');
};
</script>

<template>
  <div class="flex h-screen bg-gray-100">
    <aside class="w-64 bg-white shadow-lg">
      <div class="p-6">
        <h2 class="text-2xl font-bold text-primary-600">Admin Panel</h2>
      </div>

      <nav class="mt-6">
        <router-link
          to="/admin"
          exact
          class="block px-6 py-3 text-gray-700 hover:bg-primary-50 hover:text-primary-600 transition-colors"
          active-class="bg-primary-50 text-primary-600 font-semibold"
        >
          Dashboard
        </router-link>
        <router-link
          to="/admin/users"
          class="block px-6 py-3 text-gray-700 hover:bg-primary-50 hover:text-primary-600 transition-colors"
          active-class="bg-primary-50 text-primary-600 font-semibold"
        >
          Quản lý người dùng
        </router-link>
        <router-link
          to="/admin/categories"
          class="block px-6 py-3 text-gray-700 hover:bg-primary-50 hover:text-primary-600 transition-colors"
          active-class="bg-primary-50 text-primary-600 font-semibold"
        >
          Quản lý danh mục
        </router-link>
        <router-link
          to="/admin/foods"
          class="block px-6 py-3 text-gray-700 hover:bg-primary-50 hover:text-primary-600 transition-colors"
          active-class="bg-primary-50 text-primary-600 font-semibold"
        >
          Quản lý món ăn
        </router-link>
        <router-link
          to="/admin/combos"
          class="block px-6 py-3 text-gray-700 hover:bg-primary-50 hover:text-primary-600 transition-colors"
          active-class="bg-primary-50 text-primary-600 font-semibold"
        >
          Quản lý combo
        </router-link>
        <router-link
          to="/admin/orders"
          class="block px-6 py-3 text-gray-700 hover:bg-primary-50 hover:text-primary-600 transition-colors"
          active-class="bg-primary-50 text-primary-600 font-semibold"
        >
          Quản lý đơn hàng
        </router-link>

        <div class="border-t mt-6 pt-6">
          <router-link
            to="/"
            class="block px-6 py-3 text-gray-700 hover:bg-gray-50 transition-colors"
          >
            Về trang chủ
          </router-link>
          <button
            @click="handleLogout"
            class="block w-full text-left px-6 py-3 text-gray-700 hover:bg-gray-50 transition-colors"
          >
            Đăng xuất
          </button>
        </div>
      </nav>
    </aside>

    <main class="flex-1 overflow-y-auto p-8">
      <router-view />
    </main>
  </div>
</template>
