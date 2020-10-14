# Package

version       = "0.1.0"
author        = "genotrance"
description   = "Nim library to bundle dependency files into executable"
license       = "MIT"

skipDirs = @["tests"]

task docs, "Generate docs":
  exec "nim doc -o:build --project --index:on nimdeps.nim"
  if "--publish" in commandLineParams:
    exec "cd build && ghp-import --no-jekyll -fp ."
