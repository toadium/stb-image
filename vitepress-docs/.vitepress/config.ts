import { defineConfig } from 'vitepress'
import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'
import { dirname, resolve } from 'node:path'

const __dirname = dirname(fileURLToPath(import.meta.url))
const moonbitGrammar = JSON.parse(
  readFileSync(resolve(__dirname, 'moonbit.tmLanguage.json'), 'utf-8')
)

export default defineConfig({
  title: 'image',
  description: 'MoonBit 图像处理库文档',
  lang: 'zh-CN',

  markdown: {
    shikiSetup(shiki) {
      shiki.loadLanguageSync({
        ...moonbitGrammar,
        name: 'moonbit',
        scopeName: 'source.moonbit',
        aliases: ['mbt']
      })
    }
  },

  themeConfig: {
    nav: [
      { text: '概述', link: '/overview' },
      { text: '架构', link: '/architecture' },
      { text: 'API', link: '/api/' },
      { text: '指南', link: '/guides/' },
      {
        text: 'GitHub',
        link: 'https://github.com/Toadium/image'
      }
    ],

    sidebar: {
      '/': [
        {
          text: '简介',
          items: [
            { text: '概述', link: '/overview' },
            { text: '技术栈', link: '/tech-stack' },
            { text: '架构设计', link: '/architecture' }
          ]
        },
        {
          text: '核心概念',
          items: [
            { text: '像素类型', link: '/concepts/pixel-types' },
            { text: '编解码', link: '/concepts/encode-decode' },
            { text: '格式检测', link: '/concepts/format-detection' },
            { text: '缩放', link: '/concepts/resize' },
            { text: '图像处理分类', link: '/concepts/image-processing' }
          ]
        },
        {
          text: 'API 参考',
          items: [
            { text: '统一 API 层', link: '/api/lib-api' },
            { text: 'Core API', link: '/api/core-api' },
            { text: 'Pure API', link: '/api/pure-api' },
            { text: 'Process API', link: '/api/process-api' }
          ]
        },
        {
          text: '使用指南',
          items: [
            { text: '安装', link: '/guides/installation' },
            { text: '编解码流程', link: '/guides/decode-encode' },
            { text: '图像处理', link: '/guides/processing' },
            { text: '多目标支持', link: '/guides/multi-target' }
          ]
        },
        {
          text: '参考',
          items: [
            { text: '约束与限制', link: '/reference/constraints' }
          ]
        }
      ]
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/Toadium/image' }
    ],

    search: {
      provider: 'local',
      options: {
        detailedView: true
      }
    },

    footer: {
      message: '基于 Toadium/image 生成',
      copyright: 'MIT License'
    }
  }
})
