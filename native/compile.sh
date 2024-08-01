
# Create a build directory
mkdir ios_build
cd ios_build

# Compile for armv7
clang -c -arch armv7 -isysroot $(xcrun --sdk iphoneos --show-sdk-path) -o blur_armv7.o ../blur.c

# Compile for arm64
clang -c -arch arm64 -isysroot $(xcrun --sdk iphoneos --show-sdk-path) -o blur_arm64.o ../blur.c

# Create a universal static library
libtool -static -o libblur.a blur_armv7.o blur_arm64.o
