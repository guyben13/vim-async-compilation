# vim-async-compilation
A simple library that runs syntax compilation on save and load the errors /
warnings into the location list.

## Getting started
### Requirements
The library uses a compilation database file to know how to compile your files.
The format of the compilation database is described
<a href="https://clang.llvm.org/docs/JSONCompilationDatabase.html">here</a>.

NOTE that although the database format was defined by clang/llvm, it works with
gcc as well (and presumably with any other compilation command for any other
language)

If you use CMake, you can generate the compilation database automatically by setting the 
`CMAKE_EXPORT_COMPILE_COMMANDS` variable. You can do that by adding

    set(CMAKE_EXPORT_COMPILE_COMMANDS 1)

to your `CMakeLists.txt` file. See
<a href="https://cmake.org/cmake/help/latest/variable/CMAKE_EXPORT_COMPILE_COMMANDS.html">here</a>
for details.

### Installation
Just copy the `plugin` and `doc` directories to your `~/.vim/plugin`
and `~/.vim/doc` directories.

### Optional (but encouraged)
You might want to install the
<a href="https://github.com/dhruvasagar/vim-markify">Vim-Markify</a>
plugin, which will display the errors / warnings generated nicely.

### Usage
If you set `g:async_compilation#compilation_database` to the location of your
compilation database file (defaults to `compile_commands.json`, which is the
filename created by CMake), every time you save a file a compilation will be
launched automatically in the background.

You can continue working as normal, and once the compilation ends the location
list will be populated automatically (and if you have `Vim-Markify` installed,
will also be displayed automatically).

Then you can navigate the errors / warnings using `:lne` and `:lp`.

### Tweeking the compilation command

Any compilation command is appended with `g:async_compilation#extra_options`,
which defaults to `-o /dev/null -fsyntax-only -Wno-error`.

This is only appropriate for C/C++ compilers (clang / gcc). If you use this
plugin with other languages / compilers, you might need to change the default
value.
