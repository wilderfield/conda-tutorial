PROJECT(protobuf-examples)
CMAKE_MINIMUM_REQUIRED (VERSION 3.5)
SET(CMAKE_CXX_FLAGS "-g -Wall -Werror -std=c++11")

#INCLUDE(FindProtobuf)
FIND_PACKAGE(Protobuf REQUIRED)
INCLUDE_DIRECTORIES(${PROTOBUF_INCLUDE_DIR})
PROTOBUF_GENERATE_CPP(PROTO_SRC PROTO_HEADER addressbook.proto)
ADD_LIBRARY(proto ${PROTO_HEADER} ${PROTO_SRC})

INCLUDE_DIRECTORIES(${CMAKE_CURRENT_BINARY_DIR})
LINK_DIRECTORIES(${CMAKE_CURRENT_BINARY_DIR})
ADD_EXECUTABLE(add_person_cpp add_person.cc)
ADD_EXECUTABLE(list_people_cpp list_people.cc)
TARGET_LINK_LIBRARIES(add_person_cpp proto ${PROTOBUF_LIBRARY})
TARGET_LINK_LIBRARIES(list_people_cpp proto ${PROTOBUF_LIBRARY})
