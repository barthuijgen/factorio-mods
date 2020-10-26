import * as path from "path";
import { promisify } from "util";
import * as fs from "fs-extra";
import * as readdirp from "readdirp";

function readdir(
  root: string,
  opts: readdirp.ReaddirpOptions,
  handler: (file: any) => Promise<any>
) {
  if (typeof opts === "function") {
    handler = opts;
    opts = {};
  }
  return new Promise((resolve, reject) => {
    let actions: Promise<any>[] = [];

    readdirp(root, opts)
      .on("data", (file) => {
        actions.push(handler(file));
      })
      .on("error", (reason) => {
        console.log("readdir error", reason);
        reject(reason);
      })
      .on("end", () => {
        resolve(Promise.all(actions));
      });
  });
}

async function watch(mod_path: string) {
  const modDir = getModDirectory();
  if (!modDir) return console.log("Error determining mod directory");
  const info = JSON.parse(fs.readFileSync(path.join(mod_path, "info.json"), "utf8"));
  const destination = path.join(modDir, `${info.name}_${info.version}`);

  console.log(`Target directory ${destination}`);
  await promisify(fs.mkdir)(destination).catch(() => {});
  console.log("Clearing old files...");
  await clearDirectory(destination);
  console.log("Copying new files...");
  await copyDirectory(mod_path, destination);

  console.log(`Watching ${mod_path}`);

  // Watch main directory
  watchDirectory(mod_path, mod_path, destination);
  // Watch sub directories (fs.watch is buggy in this)
  readdirp(mod_path, { type: "directories" })
    .on("data", async (file) => {
      watchDirectory(file.fullPath, mod_path, destination);
    })
    .on("error", (reason) => {
      console.error(reason);
    })
    .on("end", () => {
      console.log(`Now watching all files in ${mod_path}`);
    });
}

function watchDirectory(dir: string, source: string, destination: string) {
  fs.watch(dir, (type, file) => {
    console.log("watcher", type, file);
    let relativeDir = path.relative(source, dir);
    let from = path.resolve(dir, file);
    let to = path.resolve(destination, relativeDir, file);
    console.log("-", from);
    console.log("-", to);
    fs.createReadStream(from).pipe(fs.createWriteStream(to));
  });
}

function copyDirectory(from: string, to: string) {
  return readdir(from, { type: "files_directories", alwaysStat: true }, async (file) => {
    let dest = path.resolve(to, path.relative(from, file.fullPath));
    if (file.stats.isDirectory()) {
      return promisify(fs.mkdir)(dest).catch(() => {});
    }
    fs.createReadStream(file.fullPath).pipe(fs.createWriteStream(dest));
  });
}

function clearDirectory(directory: string) {
  return new Promise((resolve, reject) => {
    let files: string[] = [];
    let folders: string[] = [];
    readdirp(directory, { type: "files_directories", alwaysStat: true })
      .on("data", async (file) => {
        if (file.stats.isDirectory()) {
          folders.push(file.fullPath);
        } else {
          files.push(file.fullPath);
        }
      })
      .on("error", (reason) => {
        reject(reason);
      })
      .on("end", () => {
        folders.sort((a, b) => b.length - a.length);
        resolve(
          Promise.all(files.map((path) => promisify(fs.unlink)(path))).then(() => {
            return Promise.all(folders.map((path) => promisify(fs.rmdir)(path)));
          })
        );
      });
  });
}

function main() {
  if (!getModDirectory()) {
    return console.log("Failed to find mod directory");
  }
  if (!process.argv[2]) {
    return console.log("Please supply a mod directory name as argument");
  }

  let mod_path = path.join(__dirname, "../", process.argv[2]);
  fs.stat(mod_path, (err, x) => {
    if (err) return console.log(`The directory ${mod_path} does not exist`);
    if (!x.isDirectory()) return console.log(`${mod_path} is not a directory`);
    watch(mod_path).catch((reason) => {
      console.log(reason);
    });
  });
}

function getModDirectory() {
  if (process.argv[3]) {
    let dir = path.resolve(process.argv[3]);
    let stats = fs.statSync(dir);
    if (stats && stats.isDirectory()) return dir;
    else return null;
  }

  const os = require("os");
  const platform = os.platform();
  const homedir = os.homedir();

  if (platform === "win32" && process.env.APPDATA) {
    return path.resolve(process.env.APPDATA, "Factorio/mods");
  } else if (platform === "darwin") {
    return path.resolve(homedir, "/Library/Application Support/factorio/mods");
  } else if (homedir) {
    return path.resolve(homedir, ".factorio/mods");
  }
  return null;
}

main();
