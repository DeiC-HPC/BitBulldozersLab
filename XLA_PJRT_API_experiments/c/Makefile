CC = amdclang
CFLAGS = -I $(PWD)/pjrt
LDFLAGS = -ldl
TARGET = pjrt_example
SOURCE = pjrt_example.c

all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CC) $(SOURCE) -o $(TARGET) $(CFLAGS) $(LDFLAGS)

run: $(TARGET)
	./$(TARGET)

debug: $(TARGET)
	gdb ./$(TARGET)


clean:
	rm -f $(TARGET)

.PHONY: all run debug clean
