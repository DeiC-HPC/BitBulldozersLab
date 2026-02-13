CXX = g++
CFLAGS = --debug -ggdb -I $(PWD)/../c/pjrt -I /snap/flatbuffers/current/include/flatbuffers -I /snap/flatbuffers/current/include
LDFLAGS = -ldl
TARGET = pjrt_flatbuffers
SOURCE = pjrt_flatbuffers.cpp

all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CXX) $(SOURCE) -o $(TARGET) $(CFLAGS) $(LDFLAGS)

run: $(TARGET)
	./$(TARGET)

debug: $(TARGET)
	gdb ./$(TARGET)


clean:
	rm -f $(TARGET)

.PHONY: all run debug clean
