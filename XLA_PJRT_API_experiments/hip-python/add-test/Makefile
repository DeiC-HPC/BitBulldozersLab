MAKEFLAGS += --no-print-directory

PYTHON_INT=python
PYTHON_SRC=add

CC=gcc
CC_TARGET=add
LDFLAGS=-ldl

all:
	@make embed
	@make $(CC_TARGET)

embed:
	$(PYTHON_INT) cffi-builder.py $(PYTHON_SRC)

$(CC_TARGET):
	$(CC) $(CC_TARGET).c $(LDFLAGS) -o $(CC_TARGET)

run:
	@./$(CC_TARGET)

again:
	@make clean
	@make

clean:
	rm -f libadd libadd.c libadd.o libadd.so $(CC_TARGET) *~



.PHONY: all run embed cpp clean again
