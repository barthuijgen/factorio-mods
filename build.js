const fs = require('fs');
const path = require('path');
const util = require('util');
const archiver = require('archiver');

function main() {
  if (!process.argv[2]) {
    return console.log('Please supply a directory name as argument');
  }

  let mod = path.join(__dirname, process.argv[2]);
  fs.stat(mod, (err, x) => {
    if (err) return console.log(`The directory ${mod} does not exist`);
    if (!x.isDirectory()) return console.log(`${mod} is not a directory`);
    build(mod);
  });
}

async function build(mod) {
  console.log(`Building ${mod}`);
  const info = JSON.parse(fs.readFileSync(path.join(mod, 'info.json'), 'utf8'));
  const dir = path.resolve(`build`);
  const filename = `${info.name}_${info.version}`;
  await createBuildDirectory(dir);
  await zip(mod, dir, filename);
}

async function createBuildDirectory() {
  await util.promisify(fs.mkdir)(path.join(__dirname, 'build')).catch((e) => {});
}

function zip(directory, destination, filename) {
  return new Promise((resolve, reject) => {
    console.log(`Zipping...`);
    var output_path = path.resolve(destination, `${filename}.zip`);
    var output = fs.createWriteStream(output_path);
    var archive = archiver('zip', {
      zlib: { level: 9 } // Sets the compression level.
    });

    archive.directory(directory, false);

    output.on('close', () => {
      console.log(`Done: ${output_path} [${Math.round(archive.pointer() / 102.4)/10}kb]`);
    });

    archive.pipe(output);
    archive.finalize();
  });
}

main();
