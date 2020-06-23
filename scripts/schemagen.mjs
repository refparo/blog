import fsSync, { promises as fs } from 'fs'
import { default as tjs } from 'typescript-json-schema'

async function createSchema(file, type, name) {
  const program = tjs.getProgramFromFiles([file])
  const schema = tjs.generateSchema(program, type, {
    required: true
  })
  if (! fsSync.existsSync('resources')) await fs.mkdir('resources')
  await fs.writeFile(
    `resources/${name}.schema.json`,
    JSON.stringify(schema, undefined, 2))
}

async function main() {
  await createSchema('scripts/schemas.ts', 'Dict', 'dict')
}

main().catch(err => console.log(err))
