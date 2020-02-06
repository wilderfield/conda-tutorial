# Conda Tutorial
  
This tutorial guides someone on how to create their first conda package, from a C++ based project.  
`Prerequisite: Install Anaconda`   
  
This tutorial leverages an example C++ application from:

https://github.com/protocolbuffers/protobuf

The example utilizes the common protobuf library from google, so it will have to link in libprotobuf.so

Protobuf provides a way to efficiently "serialize" aka "store" structured data in a compressed binary format.

This application produces two executables: 
  - one will prompt the user for data, and store it in binary format (add_person_cpp)
  - one will dump the data from binary to readable text              (list_people_cpp)

I chose this example, because it is a very common 3rd party library

## Build the example application using make

This method requires that your machine has the protobuf package installed. The
minimum requirement is to install protocol compiler (i.e., the protoc binary)
and the protobuf runtime for C++.  
  
*Note: Ubuntu Machines typically have this already*

`$ make cpp`

If you examine the Makefile, there is some fanciness at play. The Makefile uses a utility called pkg-config to go and find the protobuf header files. It could have just as easily directly pointed to them... -I /path/to/libprotobuf/include  
  
It turns out, their method makes it even easier for us to wrap the project in conda. Stay tuned!

## Build the example application using cmake

`$ mkdir build && cd build && cmake .. && make && cd - `  
  
cmake here will acheive the same thing as make. It will find the system's libprotobuf install, and use the provided header files for compilation.

## Run the application, so you know that this is real
```
$ ./add_person_cpp addressbook.bin
addressbook.bin: File not found.  Creating a new file.
Enter person ID number: 1
Enter name: Captain
Enter email address (blank for none): captain.planet@gmail.com
Enter a phone number (or leave blank to finish): 1-800-SAVE-THE-WORLD
Is this a mobile, home, or work phone? mobile
Enter a phone number (or leave blank to finish):

$ ./list_people_cpp addressbook.bin
Person ID: 1
  Name: Captain
  E-mail address: captain.planet@gmail.com
  Mobile phone #: 1-800-SAVE-THE-WORLD
  Updated: 2020-02-06T23:11:13Z

```

## Examine the executables with ldd, to see what the executable will link
Notice how libprotobuf.so.10 is a dependency (this is really old version), and we will link it from the system.  
  
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
  
We can check our system protobuf version with: `protoc --version`

This is much older than the cutting edge libprotobuf.

If we were to ship our executables, we have to make sure to tell someone about this dependency (so they can install the same version), or we have to give them a docker container, or we have to give them another solution... Conda!!!!

## Look at the Conda Recipe for the Make Flow
```
├── protobuf-example-make-feedstock
│   ├── build.sh
│   └── meta.yaml
```
  
There are just two files needed to create a conda recipe for linux

- meta.yaml  :  Declare package meta data  
  - i.e. : Package Name, Package Version, Build Dependencies, Run Dependencies, Source Code Location
- build.sh   :  How do I build the source? What do I package?

## Examine the meta.yaml
```
{% set version = "1.0.0" %}

package:
  name: protobuf-example-make
  version: {{ version }}

source:
   path: ../

requirements:
  build:
    - protobuf
    - pkg-config
    - make
  run:
    - protobuf
 ```
The source section of the meta.yaml file tells conda where to get source code from. Conda can fetch source from various locations such as git repositories. In our case since this feedstock lives in the same repo as the source, we can simply say that the source code is one directory above us.  
  
The packages listed under requirements/build will be installed into a temporary conda environment for building this package.  

The packages listed under requirements/run will be advertised as runtime dependecies to users who install our package. This example application needs to dynamically link libprotobuf.so, so it is critical that we advertise this.  

Note that it is possible to also specify a specific version of a package in the meta.yaml file... Although, it is not good practice. It is best to have continuous integration so continuosly build your executables with the latest version of dependencies.  
  
The Makefile as written uses pkg-config to go and find it's dependency `libprotobuf` and header files. The system's pkg-config normally won't look in a conda build environment, so installing pkg-config is necessary for us to build with conda. We install protobuf from conda (This will be a much more modern version vs Ubuntu's).
  
For more information about meta.yaml, [read the docs](https://docs.conda.io/projects/conda-build/en/latest/resources/define-metadata.html) 

## Examine the build.sh
```
################
# Build C++
################
# clean
make clean -C $SRC_DIR
# build
make cpp -j -C $SRC_DIR

################################
mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/bin

################################
# copy executable files to environments bin directory
################################
cp -f $SRC_DIR/add_person_cpp ${PREFIX}/bin
cp -f $SRC_DIR/list_people_cpp ${PREFIX}/bin
```
  
Looks earily similar to what we have already done.  
  
The key difference is that after we build, we copy the artifacts we need to ship to special "conda locations".   
  
${PREFIX}/bin is a directory that will be packaged up. Anything we copy into ${PREFIX}/ will be available to users after they install our package.  
  
When a user creates a conda environment with our package, they will have our executable in their: $CONDA_PREFIX/bin directory... meaning it will effectively be in their path... they can use our tool as easily as they can "ls" in a directory.

## Build the protobuf-example-make package
`$ cd protobuf-example-make-feedstock && mkdir conda-channel && conda build . --output-folder ./conda-channel && cd - `
  
We just built a conda package for our example C++ application...  
  
Note: conda build can accept a range of switches... [read the docs](https://docs.conda.io/projects/conda-build/en/latest/resources/commands/conda-build.html)

## Create Anaconda Environment with our package
```
$ conda create -n test protobuf-example-make
$ conda activate test
$ which add_person_cpp
```

## Difference with Cmake
There really isn't much difference if your project was Cmake based.    
Cmake will go and find your dependencies for you. We just have to nudge Cmake in the right direction.  
Line26 of protobuf-example-cmake/build.sh tells Cmake to search the conda environment for dependencies.  
`cmake .. -DCMAKE_PREFIX_PATH=$BUILD_PREFIX`
  
You can build the Cmake version with the same instructions as above, just use the -cmake directory.  

## Applause
Thanks! I hope this was useful to you!

