# Project: Project1
# Makefile created by Dev-C++ 4.9.9.2

CPP  = g++
CC   = gcc
RES  = 
OBJ  = main.o cvcalibinit3.o $(RES)
LINKOBJ  = main.o cvcalibinit3.o $(RES)
LIBS =  -L"/home/wei/opencv-2.4.9_build/lib" -lopencv_core -lopencv_highgui -lopencv_calib3d -lopencv_imgproc
INCS =  -I"/usr/local/include"  -I"/usr/local/include/opencv" 
CXXINCS = -I"/usr/local/include"  -I"/usr/local/include/opencv" 
BIN  = FindCorners
CXXFLAGS = $(CXXINCS)  
CFLAGS = $(INCS)  
RM = rm -f

.PHONY: all clean

all: $(BIN)

clean:
	${RM} $(OBJ) $(BIN)

$(BIN): $(OBJ)
	$(CPP) $(LINKOBJ) -g -o $(BIN) $(LIBS)

main.o: main.cpp
	$(CPP) -c -g main.cpp -o main.o $(CXXFLAGS)

cvcalibinit3.o: cvcalibinit3.cpp
	$(CPP) -c -g cvcalibinit3.cpp -o cvcalibinit3.o $(CXXFLAGS)
