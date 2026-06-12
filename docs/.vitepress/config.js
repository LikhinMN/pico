import { defineConfig } from 'vitepress'

export default defineConfig({
  title: "Pico",
  description: "Featherweight, zero-boilerplate state management for Flutter.",
  base: '/pico/',
  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Documentation', link: '/guide/getting-started' }
    ],
    sidebar: [
      {
        text: 'Introduction',
        items: [
          { text: 'Why Pico?', link: '/guide/why-pico' },
          { text: 'Getting Started', link: '/guide/getting-started' }
        ]
      },
      {
        text: 'Core Concepts',
        items: [
          { text: 'Store & Actions', link: '/guide/store' },
          { text: 'Surgical Rebuilds', link: '/guide/surgical-rebuilds' },
          { text: 'Async Data', link: '/guide/async-state' }
        ]
      }
    ],
    socialLinks: [
      { icon: 'github', link: 'https://github.com/likhinmn/pico' }
    ],
    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2024-present Likhin'
    }
  }
})
