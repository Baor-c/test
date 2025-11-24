import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { supabase } from '@/utils/supabase';
import type { UserProfile } from '@/types/database';
import type { User } from '@supabase/supabase-js';

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null);
  const profile = ref<UserProfile | null>(null);
  const loading = ref(true);

  const isAuthenticated = computed(() => !!user.value);
  const isAdmin = computed(() => profile.value?.role === 'admin');
  const isCustomer = computed(() => profile.value?.role === 'customer');

  async function initialize() {
    try {
      loading.value = true;
      const { data: { session } } = await supabase.auth.getSession();

      if (session?.user) {
        user.value = session.user;
        await fetchProfile();
      }

      supabase.auth.onAuthStateChange(async (_event, session) => {
        user.value = session?.user || null;
        if (session?.user) {
          await fetchProfile();
        } else {
          profile.value = null;
        }
      });
    } catch (error) {
      console.error('Auth initialization error:', error);
    } finally {
      loading.value = false;
    }
  }

  async function fetchProfile() {
    if (!user.value) return;

    try {
      const { data, error } = await supabase
        .from('user_profiles')
        .select('*')
        .eq('id', user.value.id)
        .maybeSingle();

      if (error) throw error;
      profile.value = data;
      console.log('Profile loaded:', data);
    } catch (error) {
      console.error('Error fetching profile:', error);
    }
  }

  async function signUp(userData: {
    email: string;
    password: string;
    full_name: string;
    phone: string;
    address: string;
    date_of_birth?: string;
  }) {
    try {
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email: userData.email,
        password: userData.password,
      });

      if (authError) throw authError;
      if (!authData.user) throw new Error('User creation failed');

      const { error: profileError } = await supabase
        .from('user_profiles')
        .insert({
          id: authData.user.id,
          email: userData.email,
          full_name: userData.full_name,
          phone: userData.phone,
          address: userData.address,
          date_of_birth: userData.date_of_birth || null,
          role: 'customer',
        });

      if (profileError) throw profileError;

      return { success: true };
    } catch (error: any) {
      console.error('Sign up error:', error);
      return { success: false, error: error.message };
    }
  }

  async function signIn(email: string, password: string) {
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) throw error;

      if (data.user) {
        user.value = data.user;
        await fetchProfile();
      }

      return { success: true };
    } catch (error: any) {
      console.error('Sign in error:', error);
      return { success: false, error: error.message };
    }
  }

  async function signInWithGoogle() {
    try {
      const { data, error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: {
          redirectTo: window.location.origin,
        },
      });

      if (error) throw error;
      return { success: true };
    } catch (error: any) {
      console.error('Google sign in error:', error);
      return { success: false, error: error.message };
    }
  }

  async function signOut() {
    try {
      const { error } = await supabase.auth.signOut();
      if (error) throw error;

      user.value = null;
      profile.value = null;
      return { success: true };
    } catch (error: any) {
      console.error('Sign out error:', error);
      return { success: false, error: error.message };
    }
  }

  async function updateProfile(updates: Partial<UserProfile>) {
    if (!user.value) return { success: false, error: 'Not authenticated' };

    try {
      const { error } = await supabase
        .from('user_profiles')
        .update(updates)
        .eq('id', user.value.id);

      if (error) throw error;
      await fetchProfile();
      return { success: true };
    } catch (error: any) {
      console.error('Update profile error:', error);
      return { success: false, error: error.message };
    }
  }

  return {
    user,
    profile,
    loading,
    isAuthenticated,
    isAdmin,
    isCustomer,
    initialize,
    fetchProfile,
    signUp,
    signIn,
    signInWithGoogle,
    signOut,
    updateProfile,
  };
});
