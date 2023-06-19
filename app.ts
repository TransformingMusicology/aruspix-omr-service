import cp from "child_process";
import fs from "fs";

import createError from "http-errors";
import express from "express";
import fileUpload from "express-fileupload";
import path from "path";
import cookieParser from "cookie-parser";
import logger from "morgan";
import {fileURLToPath} from "url";
import os from "os";

class NoSuchBinaryError extends Error {
  constructor(program: string) {
    super(`Program '${program}' doesn't exist`);
  }
}

class ErrorRunningProgram extends Error {
  constructor(program: string) {
    super(`Error when running '${program}'`);
  }
}

const app = express();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'hbs');

app.use(logger('dev'));
app.use(express.json());
app.use(fileUpload());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
// app.use(express.static(path.join(__dirname, 'public')));


export function perform_omr_image(workingDir: string, imageName: string) {
  const status = cp.spawnSync(
      "convert",
      [imageName, "-alpha", "off", "-compress", "none", "page.tiff"],
      {cwd: workingDir})
  if (status.status !== 0) {
    console.error("Error when running 'convert'");
    if ((status.error as NodeJS.ErrnoException).code === 'ENOENT') {
      throw new NoSuchBinaryError('convert');
    }
    if (status.stdout !== null) {
      console.error(status.stdout);
    }
    if (status.stderr !== null) {
      console.error(status.stderr);
    }
    throw new ErrorRunningProgram('convert');
  }

  const aruspixStatus = cp.spawnSync(
      "aruspix-cmdline",
      ["-m", "/app/aruspix_models", "page.tiff"],
      {cwd: workingDir})
  if (aruspixStatus.status !== 0) {
    console.error("Error when running aruspix");
    if (status.stdout !== null) {
      console.error(aruspixStatus.stdout.toString());
    }
    if (status.stderr !== null) {
      console.error(aruspixStatus.stderr.toString());
    }
    throw new ErrorRunningProgram('aruspix');
  }

  const zipStatus = cp.spawnSync(
      "unzip",
      ["-q", "page.axz", "page.mei"],
      {cwd: workingDir})
  if (zipStatus.status !== 0) {
    console.error("Error when uncompressing archive");
    console.error(zipStatus.stdout.toString());
    console.error(zipStatus.stderr.toString());
    throw new ErrorRunningProgram('unzip');
  }

  return path.join(workingDir, 'page.mei');
}

export function convert_mei_xslt(workingDir: string, meiName: string) {
  const xsltStatus = cp.spawnSync(
      "xsltproc",
      ["/app/aruspix2m21mei.xsl", meiName],
      {cwd: workingDir})
  if (xsltStatus.status !== 0) {
    console.error("Error when running 'xsltproc'");
    if ((xsltStatus.error as NodeJS.ErrnoException).code === 'ENOENT') {
      throw new NoSuchBinaryError('xsltproc');
    }
    if (xsltStatus.stdout !== null) {
      console.error(xsltStatus.stdout.toString());
    }
    if (xsltStatus.stderr !== null) {
      console.error(xsltStatus.stderr.toString());
    }
    throw new ErrorRunningProgram('xsltproc');
  } else {
    const stdOut = xsltStatus.stdout.toString();
    const filePath = path.join(workingDir, 'converted.mei');
    fs.writeFileSync(filePath, stdOut);
    return filePath;
  }
}

export async function run_image_query(image: fileUpload.UploadedFile, workingDir: string, doXslt: boolean) {

  const appPrefix = 'emo-upload';
  try {
    await image.mv(path.join(workingDir, image.name));

    const meiFilename = perform_omr_image(workingDir, image.name);
    if (doXslt) {
      return convert_mei_xslt(workingDir, meiFilename);
    } else {
      return meiFilename;
    }
  }
  catch (e) {
    console.error(`error when running stuff ${e}`);
    return null;
  }
}


app.get('/', function(req, res, next) {
  res.render('index', {layout: false});
});

app.post('/api/image_query', async function (req, res, next) {
  if (!req.files) {
    return res.status(400).json({status: "error", error: 'No files were uploaded.'});
  }

  let user_image = req.files.user_image_file as fileUpload.UploadedFile;
  if (user_image === undefined) {
    return res.status(400).json({status: "error", error: 'uploaded file must be named user_image_file'});
  }

  const xsltParam = req.body.xslt;
  const doXslt = xsltParam === 'true';

  let tmpDir: string | undefined;
  const appPrefix = 'emo-upload';
  try {
    tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), appPrefix));
    const result = await run_image_query(user_image, tmpDir, doXslt);
    if (result) {
      return res.download(result, 'converted.mei', (err) => {
        if (err) {
          console.error(`error downloading ${err}`);
          next(err);
        } else {
          try {
            if (tmpDir) {
              fs.rmSync(tmpDir, {recursive: true, force: true});
            }
          } catch (e) {
            console.error(`An error has occurred while removing the temp folder at ${tmpDir}. Please remove it manually. Error: ${e}`);
          }
        }
      });
    }
  } catch (e) {
    console.error(`error doing download, about to next() ${e}`);
    next(e);
  }
});

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err: any, req: any, res: any, next: any) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

export default app;
