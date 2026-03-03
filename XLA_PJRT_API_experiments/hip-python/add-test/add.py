#!/usr/bin/env python

from libadd import ffi, lib
import weakref
print("preparing")   # printed once

global_weakkeydict = weakref.WeakKeyDictionary()

@ffi.def_extern()
def adddiff(x, y):
    print("adding %d and %d" % (x, y))
    result = ffi.new("vec *", [x+y, x-y])
    return result

@ffi.def_extern()
def add(x, y):
    print("adding %d and %d" % (x, y))
    return x + y

@ffi.def_extern()
def get_container():
    result = ffi.new("cnt *")
    vec = ffi.new("vec *", [1, 2])
    result.vec = vec
    global_weakkeydict[result] = (vec,)
    return result
