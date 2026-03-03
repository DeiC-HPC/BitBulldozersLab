# Compiler and flags
CC = hipcc
CFLAGS = -Wall -O2

# ONNX Runtime paths (adjust these to your installation)
ONNX_INCLUDE = /opt/onnxruntime/include
ONNX_LIB = /opt/onnxruntime/lib

# Include and library paths
INCLUDES = -I$(ONNX_INCLUDE)
LDFLAGS = -L$(ONNX_LIB) -lonnxruntime

# Target executable
TARGET = onnx_runtime_api

# Source files
SRCS = onnx_runtime_api.c

# Object files
OBJS = $(SRCS:.c=.o)

# Default target
all: $(TARGET)

# Build the executable
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

# Compile source files to object files
%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

# Clean build artifacts
clean:
	rm -f $(OBJS) $(TARGET)

# Run the program
run: $(TARGET)
	./$(TARGET)

.PHONY: all clean run
