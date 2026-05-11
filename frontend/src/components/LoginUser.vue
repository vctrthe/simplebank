<script setup lang="ts">
import InputGroup from 'primevue/inputgroup'
import InputGroupAddon from 'primevue/inputgroupaddon'
import { InputText, useToast } from 'primevue'
import FloatLabel from 'primevue/floatlabel'
import { computed, ref } from 'vue'
import Button from 'primevue/button'
import axios from 'axios'
import type { User } from '@/types/user.ts'
import store from '@/store.ts'

interface LoginResponse {
  user: User
  access_token: string
  refresh_token: string
}

const username = ref<string>('')
const password = ref<string>('')
const isLoginDisabled = computed(() => !username.value || !password.value)
const errorMessage = ref<string>('')
const toast = useToast()
const handleLogin = async () => {
  try {
    const response = await axios.post<LoginResponse>('http://localhost:8080/v1/login_user', {
      username: username.value,
      password: password.value,
    })

    store.setUser(response.data.user, response.data.access_token, response.data.refresh_token)
    toast.add({
      severity: 'success',
      summary: `Hello, ${response.data.user.full_name}`,
      detail: 'Login successful',
      life: 3000,
    })
  } catch (error: any) {
    if (error.response && error.response.status === 404) {
      errorMessage.value = error.response.data.message
    } else {
      errorMessage.value = 'An error occurred. Please try again later.'
    }

    toast.add({
      severity: 'error',
      summary: 'Login failed.',
      detail: errorMessage.value,
      life: 3000,
    })
  }
}
</script>

<template>
  <div class="flex flex-column row-gap-5">
    <InputGroup>
      <InputGroupAddon>
        <i class="pi pi-user"></i>
      </InputGroupAddon>
      <FloatLabel>
        <InputText id="Username" v-model="username" />
        <label for="Username">Username</label>
      </FloatLabel>
    </InputGroup>

    <InputGroup>
      <InputGroupAddon>
        <i class="pi pi-lock"></i>
      </InputGroupAddon>
      <FloatLabel>
        <InputText type="password" id="Password" v-model="password" />
        <label for="Password">Password</label>
      </FloatLabel>
    </InputGroup>

    <Button label="Login" :disabled="isLoginDisabled" @click="handleLogin" />
  </div>
</template>

<style scoped></style>
