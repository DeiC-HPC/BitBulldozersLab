import cffi
import os, sys

ffibuilder = cffi.FFI()

modulename = sys.argv[1]

with open(modulename+'.py','r') as f:
    module = f.read()

with open(modulename+".h", "r") as f:
    header = ''.join([line for line in f if not line.startswith('#')])

ffibuilder.embedding_api(header)
ffibuilder.set_source(f"lib{modulename}", f'''
    #include "{modulename}.h"
''')

ffibuilder.embedding_init_code(module)
ffibuilder.compile(verbose=True)
