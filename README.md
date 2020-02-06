# Conda Tutorial

This tutorial leverages an example C++ application from:

https://github.com/protocolbuffers/protobuf

The example utilizes the common protobuf library from google, so it will have to link in libprotobuf.so

Protobuf provides a way to efficiently "serialize" aka "store" structured data in a compressed binary format.

This application produces two executables: 
  - one will prompt the user for data, and store it in binary format (add_person_cpp)
  - one will dump the data from binary to readable text              (list_people_cpp)

I chose this example, because it is a very common 3rd party library

# To run the examples

    ```
    $ ./add_person_cpp addressbook.data
    $ ./list_people_cpp addressbook.data
    ```

## Build the example using make

You must install the protobuf package before you can build it using make. The
minimum requirement is to install protocol compiler (i.e., the protoc binary)
and the protobuf runtime for the language you want to build.

### Ubuntu Machines typically have this already

`make cpp`

## Examine the executables with ldd, to see what the executable will link
```
$ ldd add_person_cpp
  linux-vdso.so.1 (0x00007ffd46df0000)
  libprotobuf.so.10 => /usr/lib/x86_64-linux-gnu/libprotobuf.so.10 (0x00007f36dc3cc000)
  libstdc++.so.6 => /usr/lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007f36dc03e000)
  libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007f36dbe26000)
  libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f36dba35000)
  libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f36db816000)
  libz.so.1 => /lib/x86_64-linux-gnu/libz.so.1 (0x00007f36db5f9000)
  /lib64/ld-linux-x86-64.so.2 (0x00007f36dca36000)
  libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f36db25b000)
```
Note that we have incurred a system dependency, we are building with some version of protobuf that corresponds to the shared library: libprotobuf.so.10

We can check our system protobuf version with: `protoc --version`

This is much older than the cutting edge libprotobuf.

Also, we are dependent on the glibc we have in the system, customers with older machines may not have compatible glibc

If we were to ship our executable to customers, we have to make sure to tell them about this dependency, or we have to give them a docker container, or we have to give them another solution

## Build the example using cmake

`mkdir build && cd build && cmake ../ && make`
