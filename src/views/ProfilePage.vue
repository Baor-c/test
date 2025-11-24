<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useAuthStore } from '@/stores/auth';

const authStore = useAuthStore();

const formData = ref({
  full_name: '',
  phone: '',
  address: '',
  date_of_birth: '',
});

const loading = ref(false);
const message = ref('');

onMounted(() => {
  if (authStore.profile) {
    formData.value = {
      full_name: authStore.profile.full_name,
      phone: authStore.profile.phone,
      address: authStore.profile.address,
      date_of_birth: authStore.profile.date_of_birth || '',
    };
  }
});

const handleUpdate = async () => {
  loading.value = true;
  message.value = '';

  const result = await authStore.updateProfile(formData.value);
  loading.value = false;

  if (result.success) {
    message.value = 'Cập nhật thông tin thành công';
  } else {
    message.value = result.error || 'Cập nhật thất bại';
  }
};
</script>

<template>
  <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
    <h1 class="text-4xl font-bold text-gray-900 mb-8">Thông tin cá nhân</h1>

    <div class="bg-white rounded-lg shadow-md p-6">
      <form @submit.prevent="handleUpdate" class="space-y-4">
        <div v-if="message" :class="['p-3 rounded-lg text-sm', message.includes('thành công') ? 'bg-green-50 text-green-600' : 'bg-red-50 text-red-600']">
          {{ message }}
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
          <input :value="authStore.profile?.email" type="email" disabled class="input-field bg-gray-100" />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Họ và tên</label>
          <input v-model="formData.full_name" type="text" required class="input-field" />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Số điện thoại</label>
          <input v-model="formData.phone" type="tel" required class="input-field" />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Địa chỉ</label>
          <input v-model="formData.address" type="text" required class="input-field" />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Ngày sinh</label>
          <input v-model="formData.date_of_birth" type="date" class="input-field" />
        </div>

        <button type="submit" :disabled="loading" class="w-full btn-primary">
          {{ loading ? 'Đang xử lý...' : 'Cập nhật' }}
        </button>
      </form>
    </div>
  </div>
</template>
