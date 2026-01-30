CXX = g++
CFLAGS = -I $(PWD)/../c/pjrt
LDFLAGS = -ldl
TARGET = pjrt_example
SOURCE = pjrt_example.cpp

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
