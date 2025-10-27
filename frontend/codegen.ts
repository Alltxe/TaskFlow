import type { CodegenConfig } from '@graphql-codegen/cli'

const config: CodegenConfig = {
  overwrite: true,
  schema: 'http://localhost:3000/graphql', // Backend GraphQL endpoint
  documents: 'src/**/*.{ts,tsx}',
  generates: {
    'src/api/generated/': {
      preset: 'client',
      plugins: [
        'typescript',
        'typescript-operations',
        'typescript-urql',
      ],
      config: {
        skipTypename: false,
        withHooks: true,
        withHOC: false,
        withComponent: false,
      },
    },
    './graphql.schema.json': {
      plugins: ['introspection'],
    },
  },
}

export default config
