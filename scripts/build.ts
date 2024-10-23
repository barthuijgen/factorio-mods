import * as path from "node:path";
import archiver from "archiver";
import * as fs from "node:fs/promises";
import { createWriteStream } from "node:fs";
import { safeAwait } from "./util";

const OUTPUT_DIR = path.join(__dirname, "../build");

async function main() {
  if (!process.argv[2]) {
    return console.log("Please supply a directory name as argument");
  }

  const mod = path.join(__dirname, "..", process.argv[2]);

  const [err, x] = await safeAwait(fs.stat(mod));
  if (err) return console.log(`The directory ${mod} does not exist`);
  if (!x.isDirectory()) return console.log(`${mod} is not a directory`);

  build(mod);
}

async function build(mod_name: string) {
  console.log(`Building ${mod_name}`);

  const info = JSON.parse(
    await fs.readFile(path.join(mod_name, "info.json"), "utf8")
  );
  const filename = `${info.name}_${info.version}`;

  await zip(mod_name, filename);
}

async function zip(mod_name: string, filename: string) {
  console.log(`Zipping ${mod_name}...`);

  await fs.mkdir(OUTPUT_DIR).catch(() => {});

  const output_path = path.resolve(OUTPUT_DIR, `${filename}.zip`);
  const output = createWriteStream(output_path);

  const archive = archiver("zip", {
    zlib: { level: 9 },
  });

  archive.directory(mod_name, filename);

  output.on("close", () => {
    console.log(
      `Done: ${output_path} [${Math.round(archive.pointer() / 102.4) / 10}kb]`
    );
  });

  archive.pipe(output);
  await archive.finalize();
}

main().catch(console.error);
