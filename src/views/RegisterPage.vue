<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';

const router = useRouter();
const authStore = useAuthStore();

const formData = ref({
  email: '',
  password: '',
  confirmPassword: '',
  full_name: '',
  phone: '',
  address: '',
  date_of_birth: '',
});

const error = ref('');
const loading = ref(false);

const handleSubmit = async () => {
  error.value = '';

  if (formData.value.password !== formData.value.confirmPassword) {
    error.value = 'Mật khẩu xác nhận không khớp';
    return;
  }

  if (!formData.value.email || !formData.value.password || !formData.value.full_name ||
      !formData.value.phone || !formData.value.address) {
    error.value = 'Vui lòng điền đầy đủ thông tin';
    return;
  }

  loading.value = true;
  const result = await authStore.signUp(formData.value);
  loading.value = false;

  if (result.success) {
    router.push('/');
  } else {
    error.value = result.error || 'Đăng ký thất bại';
  }
};
</script>

<template>
  <div class="min-h-[calc(100vh-4rem)] flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full">
      <div class="bg-white rounded-lg shadow-lg p-8">
        <h2 class="text-3xl font-bold text-center text-gray-900 mb-8">Đăng ký tài khoản</h2>

        <form @submit.prevent="handleSubmit" class="space-y-4">
          <div v-if="error" class="bg-red-50 text-red-600 p-3 rounded-lg text-sm">
            {{ error }}
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Họ và tên *</label>
            <input
              v-model="formData.full_name"
              type="text"
              required
              class="input-field"
              placeholder="Nguyễn Văn A"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Email *</label>
            <input
              v-model="formData.email"
              type="email"
              required
              class="input-field"
              placeholder="email@example.com"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Số điện thoại *</label>
            <input
              v-model="formData.phone"
              type="tel"
              required
              class="input-field"
              placeholder="0123456789"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Địa chỉ *</label>
            <input
              v-model="formData.address"
              type="text"
              required
              class="input-field"
              placeholder="123 Đường ABC, Quận XYZ"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Ngày sinh</label>
            <input
              v-model="formData.date_of_birth"
              type="date"
              class="input-field"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Mật khẩu *</label>
            <input
              v-model="formData.password"
              type="password"
              required
              minlength="6"
              class="input-field"
              placeholder="Tối thiểu 6 ký tự"
            />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Xác nhận mật khẩu *</label>
            <input
              v-model="formData.confirmPassword"
              type="password"
              required
              class="input-field"
              placeholder="Nhập lại mật khẩu"
            />
          </div>

          <button
            type="submit"
            :disabled="loading"
            class="w-full btn-primary"
          >
            {{ loading ? 'Đang xử lý...' : 'Đăng ký' }}
          </button>

          <p class="text-center text-sm text-gray-600">
            Đã có tài khoản?
            <router-link to="/login" class="text-primary-600 hover:text-primary-700 font-medium">
              Đăng nhập ngay
            </router-link>
          </p>
        </form>
      </div>
    </div>
  </div>
</template>
