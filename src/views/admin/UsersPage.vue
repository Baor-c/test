<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { supabase } from '@/utils/supabase';
import { useAuthStore } from '@/stores/auth';
import type { UserProfile } from '@/types/database';

const authStore = useAuthStore();
const users = ref<UserProfile[]>([]);
const loading = ref(true);

onMounted(async () => {
  await fetchUsers();
  loading.value = false;
});

async function fetchUsers() {
  const { data } = await supabase
    .from('user_profiles')
    .select('*')
    .order('created_at', { ascending: false });
  if (data) users.value = data;
}

const deleteUser = async (userId: string) => {
  if (userId === authStore.user?.id) {
    alert('Không thể xóa tài khoản đang sử dụng');
    return;
  }

  if (confirm('Bạn có chắc chắn muốn xóa người dùng này?')) {
    const { error } = await supabase
      .from('user_profiles')
      .delete()
      .eq('id', userId);

    if (!error) {
      await fetchUsers();
    }
  }
};

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('vi-VN');
};
</script>

<template>
  <div>
    <div class="flex justify-between items-center mb-8">
      <h1 class="text-3xl font-bold text-gray-900">Quản lý người dùng</h1>
    </div>

    <div v-if="loading" class="text-center py-12">
      <p class="text-gray-600">Đang tải...</p>
    </div>

    <div v-else class="bg-white rounded-lg shadow-md overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tên</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Email</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">SĐT</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Vai trò</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Ngày tạo</th>
            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Thao tác</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <tr v-for="user in users" :key="user.id">
            <td class="px-6 py-4 whitespace-nowrap">{{ user.full_name }}</td>
            <td class="px-6 py-4 whitespace-nowrap">{{ user.email }}</td>
            <td class="px-6 py-4 whitespace-nowrap">{{ user.phone }}</td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span :class="['px-2 py-1 rounded-full text-xs font-medium', user.role === 'admin' ? 'bg-purple-100 text-purple-800' : 'bg-blue-100 text-blue-800']">
                {{ user.role === 'admin' ? 'Admin' : 'Khách hàng' }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{{ formatDate(user.created_at) }}</td>
            <td class="px-6 py-4 whitespace-nowrap text-right">
              <button
                @click="deleteUser(user.id)"
                :disabled="user.id === authStore.user?.id"
                class="text-red-600 hover:text-red-900 disabled:text-gray-400 disabled:cursor-not-allowed"
              >
                Xóa
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
