import inJson from '../../manifest.json' assert { type: "json" }

await Deno.writeTextFile("scripts/generated/manifest.ts", `
/// GENERATED FILE

export const manifest = ${JSON.stringify(inJson, null, 2)};
`);