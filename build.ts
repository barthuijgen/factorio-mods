import * as path from "path";
import * as util from "util";
import * as fs from "fs-extra";
import * as archiver from "archiver";

const OUTPUT_DIR = path.join(__dirname, "build");

async function main() {
  if (!process.argv[2]) {
    return console.log("Please supply a directory name as argument");
  }

  const mod = path.join(__dirname, process.argv[2]);

  fs.stat(mod, (err, x) => {
    if (err) return console.log(`The directory ${mod} does not exist`);
    if (!x.isDirectory()) return console.log(`${mod} is not a directory`);

    build(mod);
  });
}

async function build(mod_name: string) {
  console.log(`Building ${mod_name}`);

  const info = await fs.readJSON(path.join(mod_name, "info.json"));
  const filename = `${info.name}_${info.version}`;

  await zip(mod_name, filename);
}

async function zip(mod_name: string, filename: string) {
  return new Promise(async (resolve, reject) => {
    console.log(`Zipping ${mod_name}...`);

    await fs.ensureDir(OUTPUT_DIR);

    const output_path = path.resolve(OUTPUT_DIR, `${filename}.zip`);
    const output = fs.createWriteStream(output_path);

    const archive = archiver("zip", {
      zlib: { level: 9 }
    });

    archive.directory(mod_name, filename);

    output.on("close", () => {
      console.log(`Done: ${output_path} [${Math.round(archive.pointer() / 102.4) / 10}kb]`);
    });

    archive.pipe(output);
    archive.finalize();
  });
}

main().catch(console.error);
