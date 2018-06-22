Nimdeps is a [Nim](https://nim-lang.org/) package to bundle dependency files into the generated executable.

It is very common to have external dependency files such as data files, graphics and other payloads as part of an application. Nimdeps makes it easy to carry all this payload within the application binary instead of having to build a separate installer.

All dependencies get packaged into the application binary at compile time. All references to dependencies need to be relative to the application project directory at compile time. At runtime, all files are checked for existence and extracted if not already present or changed. Dependencies get extracted relative to the application location at runtime.

__Installation__

Nimdeps can be installed via [Nimble](https://github.com/nim-lang/nimble):

```
> nimble install nimdeps
```

This will download and install nimdeps in the standard Nimble package location, typically ~/.nimble. Once installed, it can be imported into any Nim program.

__Usage__

Module documentation can be found [here](http://nim.genotrance.com/nimdeps).

```nim
import nimdeps

const FILES = @["data.dat", "icon.png"]
setupDepFiles(FILES)

setupDepDir("depDir1")

setupDeps(@["data2.dat", "depDir2"])
```

NOTE: Nimdeps should be invoked prior to loading any of the dependencies so that they are extracted prior to usage. At this time, DLL files are not supported since Nim loads libraries prior to nimdeps running.

__Feedback__

Nimdeps is a work in progress and any feedback or suggestions are welcome. It is hosted on [GitHub](https://github.com/genotrance/nimdeps) with an MIT license so issues, forks and PRs are most appreciated.
