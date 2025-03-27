all: mkobj mklib mkexe

# 1. Compile objects
mkobj:
	gcc -c addNumbers.c subNumbers.c

# 2. Create static library
mklib: mkobj
	mkdir -p lib
	ar cr lib/libmath.a addNumbers.o subNumbers.o

# 3. Create executable
# -l is used because we need to link a custom library
# -I is used because the header file is in a subdirectory
# -L is used becuse the library is in a subdirectory
# use -static to staticly link libraries that would normally be dynamically linked
mkexe: mkobj mklib
	gcc doMath.c -lmath -o doMath -I include -L lib
	gcc doMath.c -lmath -o doMathStatic -I include -L lib -static

clean:
	rm -rf lib *.o doMath doMathStatic
