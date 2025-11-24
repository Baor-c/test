import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from '@/stores/auth';

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('@/views/HomePage.vue'),
    },
    {
      path: '/menu',
      name: 'menu',
      component: () => import('@/views/MenuPage.vue'),
    },
    {
      path: '/food/:id',
      name: 'food-detail',
      component: () => import('@/views/FoodDetailPage.vue'),
    },
    {
      path: '/combo/:id',
      name: 'combo-detail',
      component: () => import('@/views/ComboDetailPage.vue'),
    },
    {
      path: '/register',
      name: 'register',
      component: () => import('@/views/RegisterPage.vue'),
      meta: { guest: true },
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/LoginPage.vue'),
      meta: { guest: true },
    },
    {
      path: '/cart',
      name: 'cart',
      component: () => import('@/views/CartPage.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/checkout',
      name: 'checkout',
      component: () => import('@/views/CheckoutPage.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/orders',
      name: 'orders',
      component: () => import('@/views/OrdersPage.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/profile',
      name: 'profile',
      component: () => import('@/views/ProfilePage.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/admin',
      name: 'admin',
      component: () => import('@/views/admin/AdminLayout.vue'),
      meta: { requiresAuth: true, requiresAdmin: true },
      children: [
        {
          path: '',
          name: 'admin-dashboard',
          component: () => import('@/views/admin/DashboardPage.vue'),
        },
        {
          path: 'users',
          name: 'admin-users',
          component: () => import('@/views/admin/UsersPage.vue'),
        },
        {
          path: 'categories',
          name: 'admin-categories',
          component: () => import('@/views/admin/CategoriesPage.vue'),
        },
        {
          path: 'foods',
          name: 'admin-foods',
          component: () => import('@/views/admin/FoodsPage.vue'),
        },
        {
          path: 'combos',
          name: 'admin-combos',
          component: () => import('@/views/admin/CombosPage.vue'),
        },
        {
          path: 'orders',
          name: 'admin-orders',
          component: () => import('@/views/admin/OrdersPage.vue'),
        },
      ],
    },
  ],
});

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore();

  if (authStore.loading) {
    await new Promise(resolve => {
      const unwatch = authStore.$subscribe(() => {
        if (!authStore.loading) {
          unwatch();
          resolve(true);
        }
      });
    });
  }

  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next({ name: 'login', query: { redirect: to.fullPath } });
  } else if (to.meta.requiresAdmin && !authStore.isAdmin) {
    next({ name: 'home' });
  } else if (to.meta.guest && authStore.isAuthenticated) {
    next({ name: 'home' });
  } else {
    next();
  }
});

export default router;
