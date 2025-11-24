<script setup lang="ts">
import { ref } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useAuthStore } from '@/stores/auth';

const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();

const email = ref('');
const password = ref('');
const error = ref('');
const loading = ref(false);

const handleSubmit = async () => {
  error.value = '';
  loading.value = true;

  const result = await authStore.signIn(email.value, password.value);
  loading.value = false;

  if (result.success) {
    const redirect = route.query.redirect as string || '/';
    router.push(redirect);
  } else {
    error.value = result.error || 'Đăng nhập thất bại';
  }
};

const handleGoogleSignIn = async () => {
  error.value = '';
  loading.value = true;

  const result = await authStore.signInWithGoogle();
  loading.value = false;

  if (!result.success) {
    error.value = result.error || 'Đăng nhập Google thất bại';
  }
};
</script>

<template>
  <div class="min-h-[calc(100vh-4rem)] flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full">
      <div class="bg-white rounded-lg shadow-lg p-8">
        <h2 class="text-3xl font-bold text-center text-gray-900 mb-8">Đăng nhập</h2>

        <form @submit.prevent="handleSubmit" class="space-y-6">
          <div v-if="error" class="bg-red-50 text-red-600 p-3 rounded-lg text-sm">
            {{ error }}
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
            <input
              v-model="email"
              type="email"
              required
              class="input-field"
              placeholder="email@example.com"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Mật khẩu</label>
            <input
              v-model="password"
              type="password"
              required
              class="input-field"
              placeholder="Nhập mật khẩu"
            />
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full btn-primary"
          >
            {{ loading ? 'Đang xử lý...' : 'Đăng nhập' }}
          </button>

          <div class="relative">
            <div class="absolute inset-0 flex items-center">
              <div class="w-full border-t border-gray-300"></div>
            </div>
            <div class="relative flex justify-center text-sm">
              <span class="px-2 bg-white text-gray-500">Hoặc</span>
            </div>
          </div>

          <button
            type="button"
            @click="handleGoogleSignIn"
            :disabled="loading"
            class="w-full flex items-center justify-center gap-2 bg-white border border-gray-300 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <svg class="w-5 h-5" viewBox="0 0 24 24">
              <path fill="currentColor" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
              <path fill="currentColor" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
              <path fill="currentColor" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
              <path fill="currentColor" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
            </svg>
            Đăng nhập với Google
          </button>

          <p class="text-center text-sm text-gray-600">
            Chưa có tài khoản?
            <router-link to="/register" class="text-primary-600 hover:text-primary-700 font-medium">
              Đăng ký ngay
            </router-link>
          </p>
        </form>
      </div>
    </div>
  </div>
</template>
