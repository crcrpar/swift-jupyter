# Swift-Jupyter

This fork is based on google/swift-jupyter/tensorflow-0.4.

# Installation Instructions

## Using the Docker Container

This repository also includes three dockerfiles:  
1. docker/Dockerfile -> crcrpar/swift-jupyter:cv*

```bash
# from inside the directory of this repository
$ docker build -f docker/Dockerfile -t crcrpar/swift-jupyter:tf0.4 .
```

The resulting container comes with the latest Swift for TensorFlow toolchain installed, along with Jupyter and the Swift kernel contained in this repository.

This container can now be run with the following command:

```bash
docker run -p 8888:8888 --cap-add SYS_PTRACE -v /my/host/notebooks:/notebooks crcrpar/swift-jupyter:tf0.4-opencv-jupyter
```

The functions of these parameters are:

- `-p 8888:8888` exposes the port on which Jupyter is running to the host.

- `--cap-add SYS_PTRACE` adjusts the privileges with which this container is run, which is required for the Swift REPL.

- `-v <host path>:/notebooks` bind mounts a host directory as a volume where notebooks created in the container will be stored.  If this command is omitted, any notebooks created using the container will not be persisted when the container is stopped.

# Jupyter Usage

## %install directives

`%install` directives let you install SwiftPM packages so that your notebook
can import them:

```swift
// Specify SwiftPM flags to use during package installation.
%install-swiftpm-flags -c release

// Install the DeckOfPlayingCards package from GitHub.
%install '.package(url: "https://github.com/NSHipster/DeckOfPlayingCards", from: "4.0.0")' DeckOfPlayingCards

// Install the SimplePackage package that's in the kernel's working directory.
%install '.package(path: "$cwd/SimplePackage")' SimplePackage
```

The first argument to `%install` is a [SwiftPM package dependency specification](https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescriptionV4.md#dependencies).
The next argument(s) to `%install` are the products that you want to install from the package.

`%install` directives currently have some limitations:

* You must install all your packages in the first cell that you execute. (It
  will refuse to install packages, and print out an error message explaining
  why, if you try to install packages in later cells.)
* `%install-swiftpm-flags` apply to all packages that you are installing; there
  is no way to specify different flags for different packages.
* Packages that use system libraries may require you to manually specify some
  header search paths. See the `%install-extra-include-command` section below.

### Troubleshooting %installs

If you get "expression failed to parse, unknown error" when you try to import a
package that you installed, there is a way to get a more detailed error
message.

The cell with the "%install" directives has something like "Working in:
/tmp/xyzxyzxyzxyz/swift-install" in its output. There is a binary
`usr/bin/swift` where you extracted the toolchain. Start the binary as follows:

```
SWIFT_IMPORT_SEARCH_PATH=/tmp/xyzxyzxyzxyz/swift-install/modules <path-to-toolchain>/usr/bin/swift
```

This gives you an interactive Swift REPL. In the REPL, do:
```
import Glibc
dlopen("/tmp/xyzxyzxyzxyz/swift-install/package/.build/debug/libjupyterInstalledPackages.so", RTLD_NOW)

import TheModuleThatYouHaveTriedToInstall
```

This should give you a useful error message. If the error message says that
some header files can't be found, see the section below about
`%install-extra-include-command`.

### %install-extra-include-command

You can specify extra header files to be put on the header search path. Add a
directive `%install-extra-include-command`, followed by a shell command that
prints "-I/path/to/extra/include/files". For example,

```
// Puts the headers in /usr/include/glib-2.0 on the header search path.
%install-extra-include-command echo -I/usr/include/glib-2.0

// Puts the headers returned by `pkg-config` on the header search path.
%install-extra-include-command pkg-config --cflags-only-I glib-2.0
```

In principle, swift-jupyter should be able to infer the necessary header search
paths without you needing to manually specify them, but this hasn't been
implemented yet. See [this forum
thread](https://forums.fast.ai/t/cant-import-swiftvips/44833/21?u=marcrasi) for
more information.

## %include directives

`%include` directives let you include code from files. To use them, put a line
`%include "<filename>"` in your cell. The kernel will preprocess your cell and
replace the `%include` directive with the contents of the file before sending
your cell to the Swift interpreter.

`<filename>` must be relative to the directory containing `swift_kernel.py`.
We'll probably add more search paths later.

# Running tests

## Locally

Install swift-jupyter locally using the above installation instructions. Now
you can activate the virtualenv and run the tests:

```
. venv/bin/activate
python test/fast_test.py  # Fast tests, should complete in 1-2 min
python test/all_test_local.py  # Much slower, 10+ min
python test/all_test_local.py SimpleNotebookTests.test_simple_successful  # Invoke specific test method
```

You might also be interested in manually invoking the notebook tester on
specific notebooks. See its `--help` documentation:

```
python test/notebook_tester.py --help
```

## In Docker

After building the docker image according to the instructions above,

```
docker run --cap-add SYS_PTRACE swift-jupyter python3 /swift-jupyter/test/all_test_docker.py
```
