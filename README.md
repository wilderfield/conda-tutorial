# Conda Tutorial

This tutorial leverages an example C++ application from:

https://github.com/protocolbuffers/protobuf

The example utilizes the common protobuf library from google, so it will have to link in libprotobuf.so

Protobuf provides a way to efficiently "serialize" aka "store" structured data in a compressed binary format.

This application produces two executables: 
  - one will prompt the user for data, and store it in binary format (add_person_cpp)
  - one will dump the data from binary to readable text              (list_people_cpp)

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

## Build the example using cmake

`mkdir build && cd build && cmake ../ && make`
