<script setup lang="ts">
defineProps<{
  columns?: number
}>()
</script>

<template>
  <div class="card-grid" :style="{ '--cols': columns || 2 }">
    <slot />
  </div>
</template>

<style scoped>
.card-grid {
  display: grid;
  grid-template-columns: repeat(var(--cols), 1fr);
  gap: 16px;
  margin: 24px 0;
}

@media (max-width: 768px) {
  .card-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 1024px) and (min-width: 769px) {
  .card-grid[style*="--cols: 3"],
  .card-grid[style*="--cols:4"] {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
