# Intro to Compiling
## Compilation Process
- Preprocessing
	- expaned macros, etc.
- Compiling
	- src code to arch specific assemble code
- Assembling
	- input source.s(assembly code) source.o(object file)
- Linking
	- links object files together into a single object file
	- symbol is a reference toa  component in an object i.e. fucntion or global variable.
	- symbols resolve to a memory address where that symbol resided


## Types of linking 
### Dynamic Linking 
1. Desired function/data exists inside a shared object, like lib.c for example.

2. Compiler creates reference to symbols in the final object

3. Symbols from external libraries (i.e. shared objects) are linked/resolved at runtime.

Main Takeaway: The compiled executable does NOT containe the actualy code for the function stored in the shared libraries
Note: soname is a symbolic link to the real name

### Static Linking
Main Takeaway: All the symbols frome external libraries are resolve at compiltime and they're compiled into the final object file.


## Types of Object Files
1. Relocatable File - the non-executable output of the assembly stage.
2. Executables - binary program
3. Shared Objects - a shared library


## `gcc` Commands and Options
-E 				preprocess 						dont compile
-S 				preprocess compile 				dont assemble
-c				preprocess compile assemble		dont link
-save-temps		dont delete intermediate files
-I				non-standard dirs to search for includes (.h) 
-L				non-standard dirs to search for libraries (.a .so)
-l				use to specify a specific library to link. 
-static			compile a staticly linked executable

## Example
Examples: -lc links libc (C standard library), -lm links libm (math library), -lpthread (posix thread library)
The `-l` option needs to come AFTER all the source files that require it. If `hello.c` needs to link with libm then `gcc hello.c -lm` works but `gcc -lm hello.c` would fail.

gcc will probably dynamically link by default
staticly linked executables are MUCH largers
the header are for the compiler on the development machine

# Creating and Linking Static Libraries
Recall, a symbol is a reference to some component of an object i.e. a 
- function or 
- global variable

Pros: Changes in the lib require binaries to be recompiled
Cons: Does not require the .a to reside on the target platform

Anything link in from a static library is compiled directly into the final object.

To create a static library, i.e. archive hense the `.a` extension, use 
	`ar cr lib.a source1.o source2.o
Here `ar` stands for archive and `cr` stands for create.

To link with a static library use
	`gcc source.c -lfoo -o outputFile

## Demo notes
Use `file` to determine file type. On an object file, notice it says "relocatable"
Use `ar t` to list the "table of contents", i.e. show the file stored in the archive.

You can do a comparison between one of the object files and the archive file. You'll see the entirety of te object's file contents have been copy and pasted into the archive character for character.

Note that `gcc` produces *dynamic executables* be default. So while said executable may have staticly linked libs, it could also dynamically linked libs. In the demo dynamic lib in questions is libc.so.
`readelf -a doMath | grep Shared`

If you wish to produce *static executables*, i.e. all libraries (.a and .so) are staticly link, you must use the `-static` options when compiling.

Size of `doMath` with out `-static`: 	 16264 bytes
Size of `doMath` with `-static`: 		901408 bytes


# Creating and Linking Shared Libraries
Shared libraries are libraries taht can be linked in by the dynamic linker when the process is loaded into memory (.so) (libc.so)

Pros: Changes in the lib do not require binaries to be recompiled
Cons: Requires the .so to reside on the target platform

## Position Independant Code
Shared objects should be compiled as position independant code (PIC) meaning they can be loaded into any address of memory.

With PIC, all dynamic symbols are stored in a Global Offset Table. These dynamic symbols are functions with will be dynamically-linked. 
When the process is started the dynamic load resolved the GOT entries to their addresses. In the binary, any reference to one of those function will point to its entry in the GOT which will in-turn point to the resolved address of the function.

function reference -> GOT entry -> function address

GCC offers two PIC options `-fpic` and `-fPIC`.
-`-fpic` generates smaller faster code, but there may be machine specific size limitations of the size of the global offset table. If the table exceeds this limit the compiler throws an error.

- `-fPIC` may not be as small and fast, but there is no size limit on the global offset table and will never throw an error.

**Recomendation**: 
- Try using `-fpic` first. If the compiler complains, use `-fPIC`.
- For predicatble results, use the same option for all stages of compilation.

## Naming Conventions for Shared Libraries
Shared libraries can have three types of names

### Real Name
The real name is the acutal compiled shared object and follow the convension `libNAME.so.MAJOR.MINOR.PATCH`. For example, the real name of the dynamic JPEG library, version 8.2.2, would be `libjpeg.so.8.2.2`

However, not all shared libs do not follow this convension. The C library uses the convension `libNAME-MAJOR.MINOR.so` becomes `libc-2.31.so`

### Shared Object Name
The shared object name, or soname, is just a label for a major version of shared lib. Although not required, it makes resolving shared lib dependancies much easier.

A binary that is linked to a shared lib with an soname will look first for the soname on the target system. On the target system the soname is usually a symlink that points to the real name of the current version of the that library. `libjpeg.so.8.2.2` becomes `libjpeg.so.8`

### Linker Name
The linker name is simply the name of the shared lib that is invoked when linking it at compile time. `gcc` looks for this library during the linker phase when given the `-l` option. `-ljpeg` becomes `libjpeg.so`

## Creating a Share Library 
1. Generate the object files `-c` using `-fpic` or `-fPIC`.
2. Compile the objects files into a shared lib useing `-shared`
	- If a soname is desired, use `-Wl,-soname,<SONAME>`

Sometimes use `-fpic`, `-fPIC`, or neither will produce the same output. Best practice is to always put something, either `-fpic` or `-fPIC`.

The reason specifying a pic option may not be required is becasue linux defaults to making .o relocatable, i.e. it is position independant.

## Installing Shared Libraries
### Standard Directories
Normally .so files need to be in a standard directory so they can be located by `gcc` and `ld`. The table below provides commonly found exmaples.

Historical `/lib` was for critical system libraries and `/usr/lib` was for non-essential but widely used system libraries. Now days all system libraries are store in one location and `/lib` is just a symlink to `/usr/lib`.

| Directory | Specificity |
|-|-|
|`/usr/lib` | System |
|`/usr/lib/x86_64-linux-gnu` | Architecture |
|`/usr/local/lib`| Application |
|`$HOME/.local/lib`| User |

### Non-Standard Directories
If you wish to install your shared libraries in a non-standard location you'll to update the dynamic linker's config files. 

It should be noted that `ld` refers to the (static) linker that is used during the compilation process, but `ld.so` referes the dynamic linker/loader that's used by the operating system during the execution process.

When a dynamicly linked executable is called, the invokation begins like any other program: 1. the executable is located and 2. the ELF headers are parsed. By examining the Program header `readelf --program-headers <exec>` we see the `INTERP` field which specifics program interpreter that should be used to run the executable.





<!-- Dynamic linker configurations can be found in `/etc/ls.do.conf.d` -->



<!-- To see the linker's list of search directories use ` ld --verbose | grep SEARCH_DIR`

By placing the real name, the soname, and the linker name info different directories we can see how they are being used.

`gcc -L` searches for the linker name
`ld -rpath` searches for the soname
If the library has no soname, `ld -rpath` accepts the linker name

### Other Methods of Updating the Linker's Search Path
#### LD_LIBRARY_PATH
See 18:40 in the video for more details
Append to the `LD_LIBRARY_PATH` enviroment variable. This variable is empty by default and used to store additional search paths for the linker. `export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/path/to/shared/lib`

This can be used to fix a `cannot open shared object file: No such file or directory` error you may encounter when trying to run your executable. -->

## Demo 
You can see the soname of the library by using `readelf -a lib/libmath.so.1.2.3 | grep soname`.

You can see the libc link script in `/usr/lib/x86_64-linux-gnu/libc.so` which links in the C standard library.

You can see by using `readelf -a doMath | grep Shared` that the lib has been dynamically linked to the executable. Notice that the lib list in the elf file is the soname. The symlink `libmath.so` is just for the linker at compile time. This means that after compile `libmath.so` is not needed on the system. Keep this in mind for cross-compiling.

The benefit of the soname is that we can change where the soname symlink points without needing to change the soname itself. This means you don't need to recompile. E.g. if we if we make a minor update to the library `libmath.so.1.3.0`, all we need to do is update the soname symlink. So, `libmath.so.1 -> libmath.so.1.2.3` becomes `libmath.so.1 -> libmath.so.1.3.0`.

However be mindful when updating libraries. If the update is not backwards compatable, the major version should be changed `libmath.so.2.0.0` and the in turn the soname as well `libmath.so.2`. In this case you would need to recompile.


