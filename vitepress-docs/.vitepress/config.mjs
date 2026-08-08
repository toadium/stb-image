import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'pycatia',
  description: 'Python interface for CATIA V5 COM automation',
  lang: 'en-US',

  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Guide', link: '/guide/introduction' },
      { text: 'API', link: '/api/application' },
      { text: 'Examples', link: '/examples/overview' },
      { text: 'User Scripts', link: '/user-scripts/overview' },
      { text: 'GitHub', link: 'https://github.com/evereux/pycatia', target: '_blank' }
    ],

    sidebar: {
      '/guide/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Introduction', link: '/guide/introduction' },
            { text: 'Installation', link: '/guide/installation' },
            { text: 'Quick Start', link: '/guide/quick-start' }
          ]
        },
        {
          text: 'Core Concepts',
          items: [
            { text: 'Application Object', link: '/guide/application' },
            { text: 'Documents', link: '/guide/documents' },
            { text: 'Selection', link: '/guide/selection' },
            { text: 'Part & Product', link: '/guide/part-product' }
          ]
        },
        {
          text: 'Advanced Topics',
          items: [
            { text: 'Context Manager', link: '/guide/context-manager' },
            { text: 'Logging', link: '/guide/logging' },
            { text: 'Enumerations', link: '/guide/enumerations' },
            { text: 'Error Handling', link: '/guide/error-handling' }
          ]
        }
      ],
      '/api/': [
        {
          text: 'API Reference',
          items: [
            { text: 'Application', link: '/api/application' },
            { text: 'Documents', link: '/api/documents' },
            { text: 'Selection', link: '/api/selection' },
            { text: 'PartDocument', link: '/api/part-document' },
            { text: 'ProductDocument', link: '/api/product-document' },
            { text: 'DrawingDocument', link: '/api/drawing-document' }
          ]
        },
        {
          text: 'Interfaces',
          items: [
            { text: 'Hybrid Shape Factory', link: '/api/hybrid-shape-factory' },
            { text: 'Shape Factory', link: '/api/shape-factory' },
            { text: 'Product', link: '/api/product' },
            { text: 'Parameters', link: '/api/parameters' }
          ]
        }
      ],
      '/examples/': [
        {
          text: 'Examples',
          items: [
            { text: 'Overview', link: '/examples/overview' },
            { text: 'Document Handling', link: '/examples/document' },
            { text: 'Product Assembly', link: '/examples/product' },
            { text: 'Hybrid Shapes', link: '/examples/hybrid-shapes' },
            { text: 'Parameters', link: '/examples/parameters' },
            { text: 'Selection', link: '/examples/selection' },
            { text: 'Space Analysis', link: '/examples/space-analysis' },
            { text: 'Drafting', link: '/examples/drafting' }
          ]
        }
      ],
      '/user-scripts/': [
        {
          text: 'User Scripts',
          items: [
            { text: 'Overview', link: '/user-scripts/overview' },
            { text: 'Save Drawings to PDF', link: '/user-scripts/save-drawings-pdf' },
            { text: 'Rename Instances', link: '/user-scripts/rename-instances' },
            { text: 'Create Screenshot', link: '/user-scripts/create-screenshots' },
            { text: 'Save Parts to STP', link: '/user-scripts/save-parts-stp' },
            { text: 'Wing Surface', link: '/user-scripts/wing-surface' }
          ]
        }
      ]
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/evereux/pycatia' }
    ],

    footer: {
      message: 'Released under the MIT License',
      copyright: 'Copyright © 2021 Paul Bourne'
    },

    search: {
      provider: 'local',
      options: {
        detailedView: true
      }
    }
  },

  markdown: {
    theme: {
      light: 'vitesse-light',
      dark: 'vitesse-dark'
    }
  },
  ignoreDeadLinks: true
})
