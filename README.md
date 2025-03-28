[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<br>

<h1 align="center">
  MAKEFILE-ULTIMATE
  <h4 align="center">
  <em>Designed for 42 students, powerful for any C project.</em>
</h4>
</h1>

<p align="center">
  <img src="docs/images/make-logo.png?cache-bust=1" alt="Makefile logo" width="142">
</p>

# Overview
What started as a simple Makefile for my first structured 42 project (*push_swap*) quickly evolved into much more. While working on the project, I realized that a well-structured build system was essential—not just for compiling code, but for streamlining the entire **development workflow**. I took this opportunity to learn some cool stuff and to create more than just a compilation script.

Indeed, Makefile-Ultimate is a **C development tool** designed to support you especially during your 42 journey.

Not only does this Makefile simplify project development by handling all the tedious setup and maintenance tasks, but it also helps you catch bugs in your code. Beyond clean **library management** and fully automated linking, parsing, and **building**, it provides debug information that makes tracking down memory issues and segmentation faults easier and efficient.

The best part? You only need to write your project name and your libraries, and your Makefile is ready!

<p align="center">
  <br><br>
  <img src="docs/gifs/makefile-demo.gif" alt="Makefile in action" width="800">
  <br><br>
</p>

<h3 align="center">
    <em>INDEX</em>
    <br><br>
    <a href="#Features">Features</a> <br> ─── <br>
    <a href="#Quickstart">Quickstart</a> <br> ─── <br>
    <a href="#Configuration">Configuration</a> <br> ─── <br>
    <a href="#Usage">Usage</a> <br> ─── <br>
    <a href="#Git">Git</a> <br> ─── <br>
    <a href="#Workflow">Workflow</a> <br> ─── <br>
    <a href="#Contacts">Contacts</a>
  <br>
</h3>


## Features
```
💨 Fast compilation          - Multithread compilation based on your CPU’s available cores
🌈 Colorful output           - Color-coded messages for better readability
🧪 Debug integration         - Built-in support for GDB, AddressSanitizer, and Valgrind
🐳 Docker support            - Cross-platform Valgrind analysis through Docker
🔄 Submodule handling        - Automatic submodule detection and management
🧩 Library management        - Build and link with multiple libraries
📊 Detailed memory analysis  - Track memory leaks and issues with precision
```

# Quickstart

### Prerequisites

- GNU Make
- GCC or Clang
- Git (for submodule features)
- Docker (optional, for cross-platform Valgrind)

### Installation

Copy the Makefile to your root project directory.

If your project requires building an executable:
```bash
wget https://raw.githubusercontent.com/SabaDevvy/makefile-ultimate/main/Makefile
```

If your project requires building an archive:
```bash
wget https://raw.githubusercontent.com/SabaDevvy/makefile-ultimate/main/Makefile.archive
```

I recommend cloning `.gitignore` file to ignore unnecessary files generated during compilation:

```bash
wget https://raw.githubusercontent.com/SabaDevvy/makefile-ultimate/main/.gitignore
```

# Configuration

Input Project name and libraries (separated by space) used within your project. Remove <...> for non used variables.

```
# Project
PROJECT          = your_project_name  (e.g. push_swap)
PROJECT_BONUS    = your_project_bonus (e.g. checker)
# Libraries
LIBS_PRIVATE     := libraries that you made and are not used as submodule. (e.g. libft, libft_printf, ...)
LIBS_SUBMODULE   := libraries added as submodule. (e.g. libft, libft_printf, ...)
LIBS_EXTERNAL    := public libraries. (e.g. minilibx, ...)
```

**Note**: libraries archives must have the prefix lib and they have to march with directory name (e.g. *libraries/libft* and *libft.a*). In case libraries used compile with archive names not starting with lib (very unlikely), you need to manually modify `LIBS_LINKS` for all libraries.


When implementing the bonus part, make sure to either manually specify `OBJS` and `OBJS_BONUS`, or use a Makefile formula to dynamically parse the sources.
<br>
For example, considering that I had all src files for my push_swap mandatory and bonus part, I structured it like this:
```
ALL_OBJS            := $(SRCS:$(SRCS_DIR)%.c=$(OBJS_DIR)%.o)
ALL_OBJS_DEBUG      := $(SRCS:$(SRCS_DIR)%.c=$(OBJS_DEBUG_DIR)%.o)
ALL_OBJS_DOCKER     := $(SRCS:$(SRCS_DIR)%.c=$(OBJS_DOCKER_DIR)%.o)

OBJS                := $(filter-out $(OBJS_DIR)main_bonus.o, $(ALL_OBJS))
OBJS_DEBUG          := $(filter-out $(OBJS_DEBUG_DIR)main_bonus.o, $(ALL_OBJS_DEBUG))
OBJS_DOCKER         := $(filter-out $(OBJS_DOCKER_DIR)main_bonus.o, $(ALL_OBJS_DOCKER))

OBJS_BONUS          := $(filter-out $(OBJS_DIR)main_mandatory.o, $(ALL_OBJS))
OBJS_DEBUG_BONUS    := $(filter-out $(OBJS_DEBUG_DIR)main_mandatory.o, $(ALL_OBJS_DEBUG))
OBJS_DOCKER_BONUS   := $(filter-out $(OBJS_DOCKER_DIR)main_mandatory.o, $(ALL_OBJS_DOCKER))
```

**Note**: While automated source discovery is useful during development, it’s generally recommended to manually define `SRC` and `SRC_BONUS` with full paths in the final version for clarity and control.

For the archive Makefile `Makefile.archive`, you can test archive functions by filling TEST_FILES variable with your test file/s.
This is very useful, because you'll be able to test your archive functions leaks just by creating a test .c file containing main function and calling test functions.

```
TEST_FILES      := test.c test2.c ...
```

In case you are using private libraries, you can input your user Github username in Git settings in order to enable `make clone-repos` rule.
<br>
**Note**: the rule works only if your library name matches your git repo name (e.g. 42 - libft won't work).

```
GITHUB_USER     := <...> #Github username
```

## Optimal setup

Organize your root as follows:

```
- Makefile
- src directory:        for source files. You can also make nested direcotry inside of it.
- inlcudes directory:   for .h files.
- libraries directory:  for your library directories. Archive names have to match with directory name
```

*Directories structures for push swap normal and debug compilations:*

<table>
  <tr>
    <th>Before Build</th>
    <th>After Build</th>
    <th>After debug Build</th>
  </tr>
  <tr>
    <td>
      <pre><code>
.
├── includes
├── libraries
│   ├── libft
│   └── libft_io
└── src
│   ├── algorithm
│   ├── initialization
│   └── operations
└── Makefile
      </code></pre>
    </td>
    <td>
      <pre><code>
.
├── includes
├── libraries
│   ├── libft
│   └── libft_io
├── objs
│   ├── algorithm
│   ├── initialization
│   └── operations
├── src
│   ├── algorithm
│   ├── initialization
│   └── operations
├── Makefile
└── push_swap
      </code></pre>
    </td>
    <td>
      <pre><code>
.
├── debug
│   ├── objs
│   │   ├── algorithm
│   │   ├── initialization
│   │   └── operations
│   └── push_swap_debug.exe
├── includes
├── libraries
│   ├── libft
│   └── libft_io
├── src
│   ├── algorithm
│   ├── initialization
│   └── operations
└── Makefile
      </code></pre>
    </td>
  </tr>
</table>

*Directories structures for push swap valgring compilations:*

<table>
  <tr>
    <th>After valgrind Build</th>
    <th>After valgrind docker Build</th>
  </tr>
  <tr>
    <td>
      <pre><code>
.
├── debug
│   ├── objs
│   │   ├── algorithm
│   │   ├── initialization
│   │   └── operations
│   ├── push_swap_debug_val.exe
│   └── valgrind_report.txt
├── includes
├── libraries
│   ├── libft
│   └── libft_io
├── src
│   ├── algorithm
│   ├── initialization
│   └── operations
└── Makefile
      </code></pre>
    </td>
    <td>
      <pre><code>
.
├── debug
│   ├── docker
│   │   ├── objs
│   │   ├── libft_docker.a
│   │   └── libft_io_docker.a
│   ├── push_swap_debug_val.exe
│   └── valgrind_report.txt
├── includes
├── libraries
│   ├── libft
│   └── libft_io
├── src
│   ├── algorithm
│   ├── initialization
│   └── operations
└── Makefile
      </code></pre>
    </td>
  </tr>
</table>

Notice that *objs/* is created in docker directory because objects are compiled inside docker container and kept separate from root/objs, in order to avoid relinking in docker rule.
These object files (.o) are required because they are *ELF* binary files, essential for compiling in a Linux environment.
Same applies for libft_docker.a and libft_io_docker.a that are libraries archives compiled inside docker contatiner

# Usage

## Commands

```bash
# See all available commands and compile configurations
make help
```

<p align="center">
  <img src="docs/images/make-help_1.png" alt="Help 1" width="800">
</p>
<p align="center">
  <img src="docs/images/make-help_2.png" alt="Help 2" width="800">
</p>

### Basic Commands

```bash
# Compile your project
make

# Clean object files
make clean

# Remove all generated files
make fclean

# Rebuild from scratch
make re

# Remove all libraries generated files
make fclean-deep

# Rebuild from scratch project and libraries
make re-deep
```

### Debug Features

```bash
# Build with debug symbols:    Useful for general debugging (segmentation fault, leaks...) if ASAN is supported
make debug

# Runs debug build
make debug-run

# Run with leak detection
make leak-check

# Debug with GDB
make debug-gdb
```

### Valgrind Analysis

```bash
# Run Valgrind analysis:        run valgrind natevily (make valgrind-native) or in docker container (make valgrind-docker) in case valgrind is not suported
make valgrind

# Linux-native Valgrind
make valgrind-native

# Docker-based Valgrind
make valgrind-docker
```

### Other features
```bash
# Dependencies check:          checks if local environment (libraries and submodules) is ready and if submodules are up-to-date / modified and not committed
make validate_env

# Init and update submodules
make update_submodules

# Clones LIBS_PRIVATE          -> github repo name has to be the same
make clone_repos
```

## Flags
```
- VERBOSE=1    - removes silent flag which will result in very detailed information printed in the terminal.
- DETAILS=1    - prints compilation files and obj path.
- BONUS=1      - debug compilations for bonus files
- DEBUG=1      - actives source code in #ifdef DEBUG <...> endif blocks. Useful for debugging inside functions.
- SLEEP=1      - (with docker valgrind) creates persistent container instead of destroying after use.
- ARGS=<"..."> - arguments that will be passed to the exe once compiled for run commands (e.g. make valgrind). For multiple arguments use: ARGS='"..." "..."'
```

## Common Errors

If you are running valgrind docker and getting:
- linking errors
- compilation errors

You just need to run `make re-valgrind` which will:
- clean libraries *objs/* directories (`make fclean-deep`)
- automatically run make valgrind (`make valgrind`)

<p align="center">
  <br><br>
  <img src="docs/gifs/docker_bug.gif" alt="Docker Bug" width="800">
  <br><br>
</p>

# Git

Makefile-Ultimate contains Git rules to streamline your Git workflow with safe operations that prevent common errors and data loss. These commands handle stashing changes automatically and provide clear feedback.

```bash
# Pull latest changes safely (auto-stashes and restores local changes)
make pull

# Update all tracking branches (fetches and pulls all branches)
make pull-all

# Safely checkout a branch with auto-stashing (if selected)
make checkout to=branch-name

# Commit and push changes in one command
make commit m="Your detailed commit message"

# Safely merge branches with auto-stashing (if selected)
make merge from=source-branch

# Check if working directory is clean
make is-clean

# Discard all local changes (with confirmation)
make clean-all

# Discard all local and unpushed commits to match the remote (with confirmation)
make reset-to-remote
```

# Workflow

## Valgrind

Thanks to `make process-valgrind-report`, fixing memory leaks and errors becomes easy and efficient, thanks to its concise and detailed summary.
This rule is automatically triggered when you run:
```
make valgrind
```
You can also run it manually like this:
```
make process-valgrind-report REPORT_PATH=<fullpath>
```
*(Default path: `debug/valgrind_report.txt`)*

<p align="center">
  <br><br>
  <img src="docs/gifs/valgrind_fix.gif" alt="Valgrind Fix" width="800">
  <br><br>
</p>

## General debug

`make debug` compiles your project with AddressSanitizer, UndefinedBehaviorSanitizer, and Signed Integer Overflow detection (`-fsanitize=address,undefined,signed-integer-overflow`).
With these enabled, catching segmentation faults, undefined behavior, and subtle memory issues becomes fast and efficient.
While it doesn't offer the same deep memory tracking as Valgrind, it's significantly faster and still very powerful for most common issues.

<p align="center">
  <br><br>
  <img src="docs/gifs/segmentationfault_fix.gif" alt="Valgrind Fix" width="800">
  <br><br>
</p>

## Bonus

To debug you bonus part, you simply need to append `BONUS=1` flag after your prompt.

<p align="center">
  <br><br>
  <img src="docs/gifs/bonus_setup.gif" alt="Valgrind Fix" width="800">
  <br><br>
</p>

# Contacts

If you have questions, suggestions, or just want to connect:

- Discord: @sabitos
- X: [@savvysaba](https://x.com/savvysaba)
- GitHub: [@SabaDevvy](https://github.com/SabaDevvy)
- 42 User: gsabatin


