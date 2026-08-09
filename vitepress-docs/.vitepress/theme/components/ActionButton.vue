<script setup lang="ts">
import { withBase } from 'vitepress'

defineProps<{
  href?: string
  text: string
  type?: 'brand' | 'alt' | 'subtle'
  size?: 'small' | 'medium' | 'large'
  external?: boolean
}>()
</script>

<template>
  <a
    :href="href ? (external ? href : withBase(href)) : undefined"
    class="action-button"
    :class="[type || 'brand', size || 'medium']"
    :target="external ? '_blank' : undefined"
    :rel="external ? 'noopener noreferrer' : undefined"
  >
    {{ text }}
    <span class="button-icon" v-if="external">↗</span>
  </a>
</template>

<style scoped>
.action-button {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  border-radius: 8px;
  font-weight: 600;
  text-decoration: none;
  transition: all 0.25s ease;
  white-space: nowrap;
}

.action-button.small {
  padding: 6px 14px;
  font-size: 13px;
}

.action-button.medium {
  padding: 10px 20px;
  font-size: 14px;
}

.action-button.large {
  padding: 12px 24px;
  font-size: 16px;
}

.action-button.brand {
  background: var(--vp-button-brand-bg);
  color: var(--vp-button-brand-text);
  border: 1px solid var(--vp-button-brand-border);
}

.action-button.brand:hover {
  background: var(--vp-button-brand-hover-bg);
  border-color: var(--vp-button-brand-hover-border);
  transform: translateY(-1px);
  box-shadow: 0 2px 8px var(--vp-c-brand-soft);
}

.action-button.alt {
  background: var(--vp-button-alt-bg);
  color: var(--vp-button-alt-text);
  border: 1px solid var(--vp-button-alt-border);
}

.action-button.alt:hover {
  background: var(--vp-button-alt-hover-bg);
  border-color: var(--vp-button-alt-hover-border);
  transform: translateY(-1px);
}

.action-button.subtle {
  background: transparent;
  color: var(--vp-c-text-1);
  border: 1px solid var(--vp-c-divider);
}

.action-button.subtle:hover {
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
}

.button-icon {
  font-size: 0.85em;
}
</style>
