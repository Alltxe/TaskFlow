import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    minify: false
  },
  css: {
    modules: {
      // Это предотвратит хэширование имен в ваших файлах .module.css
      generateScopedName: '[local]', 
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@pages': path.resolve(__dirname, './src/pages'),
      '@features': path.resolve(__dirname, './src/features'),
      '@lib': path.resolve(__dirname, './src/lib'),
      '@api': path.resolve(__dirname, './src/api'),
      '@store': path.resolve(__dirname, './src/store'),
      '@types': path.resolve(__dirname, './src/types'),
      '@locales': path.resolve(__dirname, './src/locales'),
    },
  },
  optimizeDeps: {
    include: [
      '@mui/material',
      '@mui/icons-material',
      '@emotion/react',
      '@emotion/styled',
      'react-router-dom',
      'urql',
      'zustand',
    ],
  },
  server: {
    host: '0.0.0.0', // Слушать на всех интерфейсах (IPv4 и IPv6)
    port: 5173,
    strictPort: false,
    hmr: {
      overlay: true,
    },
  },
  preview: {
    host: '0.0.0.0', // То же для preview сервера
    port: 4173,
    strictPort: false,
  },
})
