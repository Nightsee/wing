import * as path from "path";
import * as fs from "fs";

export const repoRoot = path.resolve(__dirname, "../../..");
export const distDir = path.join(repoRoot, "dist");
export const testDir = path.join(repoRoot, "examples/tests");
export const validTestDir = path.join(testDir, "valid");
export const pluginsDir = path.join(validTestDir, "plugins");
export const sdkTests = path.join(testDir, "sdk_tests");
export const invalidTestDir = path.join(testDir, "invalid");
export const benchmarksTestDir = path.join(validTestDir, "benchmarks");
export const errorTestDir = path.join(testDir, "error");
export const hangarDir = path.join(repoRoot, "tools/hangar");
export const tmpDir = path.join(hangarDir, "tmp");
export const npmCacheDir = path.join(tmpDir, ".npm");

export const npmBin = path.join(hangarDir, "node_modules/.bin/npm");
export const wingBin = path.join(tmpDir, "node_modules/.bin/wing");

export const snapshotDir = path.join(hangarDir, "__snapshots__");

export const tarballFiles = fs
  .readdirSync(distDir)
  .filter((f) => f.endsWith(".tgz"))
  .map((f) => path.join(distDir, f));

export const validWingFiles = fs
  .readdirSync(validTestDir)
  .filter((f) => f.endsWith(".w"))
  .filter((f) => !f.endsWith("skip.w"));
export const invalidWingFiles = fs
  .readdirSync(invalidTestDir)
  .filter((f) => f.endsWith(".w"))
  .filter((f) => !f.endsWith("skip.w"));
export const errorWingFiles = fs
  .readdirSync(errorTestDir)
  .filter((f) => f.endsWith(".w"))
  .filter((f) => !f.endsWith("skip.w"));

/** Recursively walk a directory, yielding each file path. */
export async function* walkdir(dir: string): AsyncGenerator<string> {
  for await (const d of await fs.promises.opendir(dir)) {
    const entry = path.join(dir, d.name);
    if (d.isDirectory()) yield* walkdir(entry);
    else if (d.isFile()) yield entry;
  }
}
