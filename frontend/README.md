# TaskFlow Frontend

Веб-приложение для автоматизированного распределения домашних задач с геймификацией и ротацией исполнителей.

## 🚀 Быстрый старт

### Требования
- Node.js >= 18
- npm >= 9
- Backend API запущен на порту 3000

### Установка

```bash
# Установить зависимости
npm install

# Настроить переменные окружения
cp .env.example .env
# Отредактируйте .env если нужно изменить порт backend
```

### Запуск

```bash
# Development режим с hot reload
npm run dev
# Приложение будет доступно на http://localhost:5173

# Production сборка и preview
npm run build
npm run start
# Preview сервер на http://localhost:4173
```

## 📁 Структура проекта

```
src/
├── api/              # GraphQL клиент и запросы
├── components/       # Переиспользуемые компоненты
│   └── layout/      # Layout компоненты (Header, Sidebar, AppShell)
├── features/         # Функциональные модули
├── lib/             # Утилиты и хелперы
│   ├── router.tsx   # Настройка роутинга
│   ├── theme.ts     # Material UI тема
│   └── globalStyles.ts
├── pages/           # Страницы приложения
│   ├── Welcome.tsx
│   ├── Login.tsx
│   ├── Register.tsx
│   └── Dashboard.tsx
├── store/           # Zustand stores
│   ├── authStore.ts
│   ├── uiStore.ts
│   └── notificationStore.ts
└── types/           # TypeScript типы
```

## 🛠️ Технологии

- **React 19** - UI библиотека
- **TypeScript** - Типизация
- **Vite** - Сборщик и dev сервер
- **Material UI** - Компоненты UI
- **Radix UI** - Headless UI компоненты
- **Emotion** - CSS-in-JS
- **React Router** - Маршрутизация
- **urql** - GraphQL клиент
- **Zustand** - State management
- **React Hook Form** + **Zod** - Формы и валидация

## 📝 Доступные команды

```bash
# Разработка
npm run dev              # Запустить dev сервер
npm run build            # Собрать production сборку
npm run start            # Запустить preview сервер
npm run build:start      # Собрать и запустить

# Качество кода
npm run lint             # Проверить код линтером
npm run lint:fix         # Исправить проблемы автоматически
npm run format           # Форматировать код
npm run format:check     # Проверить форматирование

# GraphQL
npm run codegen          # Генерация TypeScript типов из схемы
npm run codegen:watch    # Генерация в режиме watch

# Тестирование
npm test                 # Запустить unit тесты
npm run test:ui          # Запустить тесты с UI
npm run test:coverage    # Тесты с coverage
npm run test:e2e         # End-to-end тесты
npm run test:e2e:ui      # E2E тесты с UI
```

## 🔧 Настройка

### Переменные окружения

Создайте файл `.env` из `.env.example`:

```env
# GraphQL API
VITE_API_URL=http://localhost:3000/graphql
VITE_WS_URL=ws://localhost:3000/graphql
```

Подробнее см. [ENV_SETUP.md](./.docs/ENV_SETUP.md)

### Backend

Убедитесь что backend запущен:
```bash
cd ../backend
npm run start:dev
```

GraphQL Playground: http://localhost:3000/graphql

## 📚 Документация

- [PRD (Product Requirements Document)](./.docs/PRD.md)
- [Development Roadmap](./.docs/DEVELOPMENT_ROADMAP.md)
- [Phase 2 Report](./.docs/PHASE_2_REPORT.md)
- [Environment Setup](./.docs/ENV_SETUP.md)

## 🎯 Статус разработки

- ✅ Phase 1: Project Setup & Infrastructure
- ✅ Phase 2: Authentication & Core Layout
- ⏳ Phase 3: Group Management (in progress)

## 📄 Лицензия

© 2025 TaskFlow. Все права защищены.


- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) uses [Babel](https://babeljs.io/) (or [oxc](https://oxc.rs) when used in [rolldown-vite](https://vite.dev/guide/rolldown)) for Fast Refresh
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) uses [SWC](https://swc.rs/) for Fast Refresh

## React Compiler

The React Compiler is not enabled on this template because of its impact on dev & build performances. To add it, see [this documentation](https://react.dev/learn/react-compiler/installation).

## Expanding the ESLint configuration

If you are developing a production application, we recommend updating the configuration to enable type-aware lint rules:

```js
export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...

      // Remove tseslint.configs.recommended and replace with this
      tseslint.configs.recommendedTypeChecked,
      // Alternatively, use this for stricter rules
      tseslint.configs.strictTypeChecked,
      // Optionally, add this for stylistic rules
      tseslint.configs.stylisticTypeChecked,

      // Other configs...
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```

You can also install [eslint-plugin-react-x](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-x) and [eslint-plugin-react-dom](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-dom) for React-specific lint rules:

```js
// eslint.config.js
import reactX from 'eslint-plugin-react-x'
import reactDom from 'eslint-plugin-react-dom'

export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{ts,tsx}'],
    extends: [
      // Other configs...
      // Enable lint rules for React
      reactX.configs['recommended-typescript'],
      // Enable lint rules for React DOM
      reactDom.configs.recommended,
    ],
    languageOptions: {
      parserOptions: {
        project: ['./tsconfig.node.json', './tsconfig.app.json'],
        tsconfigRootDir: import.meta.dirname,
      },
      // other options...
    },
  },
])
```
