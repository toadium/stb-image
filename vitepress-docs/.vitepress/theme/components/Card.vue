<script setup lang="ts">
import { withBase } from 'vitepress'

defineProps<{
  href?: string
  title: string
  description?: string
  icon?: string
  badge?: string
}>()
</script>

<template>
  <component
    :is="href ? 'a' : 'div'"
    :href="href ? withBase(href) : undefined"
    class="custom-card"
    :class="{ 'has-link': href }"
  >
    <div class="card-icon" v-if="icon">{{ icon }}</div>
    <div class="card-content">
      <div class="card-title">
        {{ title }}
        <span class="card-badge" v-if="badge">{{ badge }}</span>
      </div>
      <div class="card-description" v-if="description">{{ description }}</div>
    </div>
    <div class="card-arrow" v-if="href">→</div>
  </component>
</template>

<style scoped>
.custom-card {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 20px 24px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  background: var(--vp-c-bg-soft);
  transition: all 0.3s ease;
  text-decoration: none;
  color: inherit;
}

.custom-card.has-link {
  cursor: pointer;
}

.custom-card.has-link:hover {
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 2px 12px var(--vp-c-brand-soft);
  transform: translateY(-2px);
}

.card-icon {
  font-size: 28px;
  line-height: 1;
  flex-shrink: 0;
}

.card-content {
  flex: 1;
  min-width: 0;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 4px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.card-badge {
  font-size: 12px;
  font-weight: 400;
  padding: 2px 8px;
  border-radius: 10px;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
}

.card-description {
  font-size: 14px;
  color: var(--vp-c-text-2);
  line-height: 1.6;
}

.card-arrow {
  font-size: 18px;
  color: var(--vp-c-text-3);
  transition: transform 0.3s ease;
  align-self: center;
}

.custom-card.has-link:hover .card-arrow {
  transform: translateX(4px);
  color: var(--vp-c-brand-1);
}
</style>
