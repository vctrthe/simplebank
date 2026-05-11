<script setup lang="ts">
import InputGroup from 'primevue/inputgroup'
import InputGroupAddon from 'primevue/inputgroupaddon'
import { InputText } from 'primevue'
</script>

<template>
  <div class="flex flex-column row-gap-5">
    <InputGroup>
      <InputGroupAddon>
        <i class="pi pi-user"></i>
      </InputGroupAddon>
      <InputText v-model="text1" placeholder="Username" />
    </InputGroup>

    <InputGroup>
      <InputGroupAddon>
        <i class="pi pi-lock"></i>
      </InputGroupAddon>
      <InputText v-model="text1" type="password" placeholder="Password" />
    </InputGroup>
  </div>
</template>

<style scoped></style>
