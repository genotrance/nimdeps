import macros, os, strutils

proc writeDepFile(constname, filename: string) =
  ## Write out bundled dependency files to filesystem - this is automatically
  ## called by setupDepFile()
  ##
  ## `constname` is name of the constant string that contains the file contents
  ## which is the relative path passed to setupDepFile() with all special
  ## characters replaced by _.
  ##
  ## `filename` is the path to write the file contents relative to the location
  ## of the executable.
  let
    fullpath = joinPath(getAppDir(), filename)
    pdir = parentDir(fullpath)

  if not dirExists(pdir):
    try:
      createDir(pdir)
    except OSError:
      echo "Failed to create directory: " & pdir
      quit(1)

  if not existsFile(fullpath) or getFileSize(fullpath) != constname.len:
    writeFile(fullpath, constname)

  while not existsFile(fullpath):
    sleep(10)

macro setupDepFileImpl(filename: static[string]): untyped =
  result = newNimNode(nnkStmtList)
  var fullpath = joinPath(getProjectPath(), filename)
  if not fileExists(fullpath) and not dirExists(fullpath):
    echo "nimdeps: Failed to find " & fullpath
    quit(1)
  echo "Loading " & fullpath

  var
    vname = "V" & filename.multiReplace([
      ("/", "_"), ("\\", "_"), (":", "_"), (".", "_")]).toUpperAscii()
    ivname = ident(vname)

  result.add(quote do:
    const `ivname` = staticRead `fullpath`
  )

  result.add(quote do:
    writeDepFile(`ivname`, `filename`)
  )

macro setupDepFile*(filename: static[string]): untyped =
  ## Setup dependency file to be bundled into executable
  ##
  ##  `filename` is a file to bundle during compile time and write back at
  ##  runtime. Path should be relative to project directory during compile time
  ##  and will be relative to executable location at runtime.
  return quote do:
    setupDepFileImpl(`filename`)

macro setupDepFiles*(filenames: static[seq[string]]): untyped =
  ## Setup list of dependency files to be bundled into executable
  ##
  ##  `filenames` is an array of files to bundle during compile time and write
  ##  back at runtime.
  result = newNimNode(nnkStmtList)
  for filename in filenames:
    result.add(quote do:
      setupDepFileImpl(`filename`)
    )

template setupDepDir*(dir: untyped): untyped =
  ## Setup directory of dependency files to be bundled into executable
  ##
  ## `dir` is a directory to bundle during compile time and write back at
  ## runtime. Path should be relative to project directory during compile time
  ## and will be relative to executable location at runtime.
  setupDepFiles(block:
    var
      fls: seq[string] = @[]
      fullpath = joinPath(getProjectPath(), dir)

    for f in walkDirRec(fullpath):
      fls.add(f.replace(getProjectPath(), ""))

    fls
  )

macro setupDepDirs*(dirs: static[seq[string]]): untyped =
  ## Setup directories of dependency files to be bundled into executable
  ##
  ##  `dirs` is an array of directories to bundle during compile time and write
  ##  back at runtime.
  result = newNimNode(nnkStmtList)
  for dir in dirs:
    result.add(quote do:
      setupDepDir(`dir`)
    )

macro setupDeps*(fdirs: static[seq[string]]): untyped =
  ## Setup list of directories and files to be bundled into executable
  ##
  ##  `fdirs` is an array of directories and files to bundle during compile time
  ##  and write back at runtime.
  result = newNimNode(nnkStmtList)
  for fdir in fdirs:
    let fullpath = joinPath(getProjectPath(), fdir)
    if dirExists(fullpath):
      result.add(quote do:
        setupDepDir(`fdir`)
      )
    else:
      result.add(quote do:
        setupDepFileImpl(`fdir`)
      )
