MAKEFLAGS += --no-print-directory

PYTHON_INT=python
PYTHON_SRC=pyembed

CC=hipcc
CC_TARGET=myapp
LDFLAGS=-ldl
INCLUDEFLAGS=-I/opt/rocm-7.0.2/include

all:
	@make embed
	@make $(CC_TARGET)

embed:
	CC=$(CC) $(PYTHON_INT) cffi-builder.py $(PYTHON_SRC)

$(CC_TARGET):
	$(CC) $(CC_TARGET).cpp $(INCLUDEFLAGS) $(LDFLAGS) -o $(CC_TARGET)

run:
	@./$(CC_TARGET)

again:
	@make clean
	@make

clean:
	rm -f lib$(PYTHON_SRC) lib$(PYTHON_SRC).c lib$(PYTHON_SRC).o lib$(PYTHON_SRC).so $(CC_TARGET) *~



.PHONY: all run embed cpp clean again
