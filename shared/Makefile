# 

all: clean mkobj mkreal mksoname mklnname mkexe

# 1. Compile objects
# -fpic is used because it's required for shared libraries
# (although linux will do this by default most of the time)
mkobj:
	gcc -fpic -c addNumbers.c subNumbers.c

# 2. Create Shared Object (real name)
# the real name is store in real/
# -shared is used to create the shared object (.so)
# -soname tells the linker the soname
mkreal: mkobj
	mkdir -p real/
	gcc -o real/libmath.so.1.2.3 addNumbers.o subNumbers.o -shared -Wl,-soname,libmath.so.1

# 3. Create symlink to soname
# Only create link if it doesn't already exist
# The soname is store in so/
mksoname: mkobj mkreal 
	mkdir -p so/
	ln -s ../real/libmath.so.1.2.3 so/libmath.so.1

# 4. Create symlink to Linker name
# The linker name is stored in lib/
mklnname: mkobj mkreal mksoname
	mkdir -p lib
	ln -s ../so/libmath.so.1 lib/libmath.so

# 5. Create executable
# -l is used because we need to link a the library
# -I is used because the header file is in a subdirectory
# -L is used becuse the library is in a subdirectory
# -rpath is used because the shared lib is in a non-standard directory
# In practice, the linker name, soname, and real name are all stored in the same folder
mkexe: mkobj mkreal mksoname mklnname
	gcc doMath.c -lmath -o doMath -I include -L lib -Wl,-rpath,so

clean:
	rm -rf real so lib *.o doMath
