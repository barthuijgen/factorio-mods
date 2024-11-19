import * as path from "path";
import * as fs from "node:fs/promises";
import { safeAwait } from "./util";

async function watch(mod_path: string) {
  const modDir = await getModDirectory();
  if (!modDir) return console.log("Error determining mod directory");
  const info = JSON.parse(
    await fs.readFile(path.join(mod_path, "info.json"), "utf8")
  );
  const destination = path.join(modDir, `${info.name}_${info.version}`);

  console.log(`Target directory ${destination}`);

  console.log("Clearing old files...");
  await clearDirectory(destination);

  await fs.mkdir(destination).catch(() => {});

  console.log("Copying new files...");
  await copyDirectory(mod_path, destination);

  // Watch main directory
  watchDirectory(mod_path, mod_path, destination);
  // Watch sub directories (fs.watch is buggy in this)
  const dirFiles = await fs.readdir(mod_path, { recursive: true });
  for (const file of dirFiles) {
    if ((await fs.stat(path.join(mod_path, file))).isDirectory()) {
      watchDirectory(path.join(mod_path, file), mod_path, destination);
    }
  }
}

async function watchDirectory(
  dir: string,
  source: string,
  destination: string
) {
  // console.log(`Watching: ${dir}`);
  const watcher = fs.watch(dir);
  for await (const event of watcher) {
    const { filename, eventType } = event;
    if (!filename || eventType !== "change") continue;
    if (filename.endsWith(".png")) return;
    let relativeDir = path.relative(source, dir);
    let from = path.resolve(dir, filename);
    let to = path.resolve(destination, relativeDir, filename);
    console.log("watcher", eventType, filename);
    console.log("-", from);
    fs.copyFile(from, to);
  }
}

async function copyDirectory(from: string, to: string) {
  const files = await fs.readdir(from, { recursive: true });
  for (const file of files) {
    const source = path.resolve(from, file);
    const dest = path.resolve(to, path.relative(from, source));
    if ((await fs.stat(source)).isDirectory()) {
      await fs.mkdir(dest).catch(() => {});
    } else {
      await fs.copyFile(source, dest);
    }
  }
}

async function clearDirectory(directory: string) {
  await fs.rmdir(directory, { recursive: true });
}

async function main() {
  if (!getModDirectory()) {
    return console.log("Failed to find mod directory");
  }
  if (!process.argv[2]) {
    return console.log("Please supply a mod directory name as argument");
  }

  let mod_path = path.join(__dirname, "../", process.argv[2]);

  const [error, result] = await safeAwait(fs.stat(mod_path));
  if (error) return console.log(`The directory ${mod_path} does not exist`);
  if (!result.isDirectory()) {
    return console.log(`${mod_path} is not a directory`);
  }

  console.log(`Watching ${mod_path}`);
  watch(mod_path).catch((reason) => {
    console.log(reason);
  });
}

async function getModDirectory() {
  if (process.argv[3]) {
    let dir = path.resolve(process.argv[3]);
    let stats = await fs.stat(dir);
    if (stats && stats.isDirectory()) return dir;
    else return null;
  }

  const os = require("os");
  const platform = os.platform();
  const homedir = os.homedir();

  if (platform === "win32" && process.env.APPDATA) {
    return path.join(process.env.APPDATA, "Factorio/mods");
  } else if (platform === "darwin") {
    return path.join(homedir, "/Library/Application Support/factorio/mods");
  } else if (homedir) {
    return path.join(homedir, ".factorio/mods");
  }
  return null;
}

main();
