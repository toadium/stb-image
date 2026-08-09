import DefaultTheme from 'vitepress/theme'
import type { Theme } from 'vitepress'
import Card from './components/Card.vue'
import CardGrid from './components/CardGrid.vue'
import ActionButton from './components/ActionButton.vue'

import './custom.css'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component('Card', Card)
    app.component('CardGrid', CardGrid)
    app.component('ActionButton', ActionButton)
  }
} satisfies Theme
