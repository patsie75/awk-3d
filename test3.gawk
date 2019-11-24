#!/usr/bin/gawk -We

# Copyright (c) 2018 Steve Litt
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Version 1.0
# This software demonstrates a deep copy function for the awk programming
# language. It may not be the most efficient, but it works. The
# BEGIN{} section builds a 3 dimensional array a, deep copies it to
# b, changes one element in a, and then displays each, showing that
# changing one didn't change the other.
#
# Deep copying in awk is important because you can't pass arrays as
# function returns, so the way to do that is to pass them in as args.
# You cannot copy an array with:
#   array2 = array1
# The preceding produces a "attempt to use array `array1` in a
# scalar context" error. Only a deep copy works in awk.
# Because you might need to use the same function on different
# arrays, you sometimes need to copy them, and in awk the way to do
# that is to deep copy them.

BEGIN {
  a["now"]["here"]["one"] = "now_here_one"
  a["now"]["here"]["two"] = "now_here_two"
  a["now"]["there"]["one"] = "now_there_one"
  a["now"]["there"]["two"] = "now_there_two"
  a["then"]["here"]["one"] = "then_here_one"
  a["then"]["here"]["two"] = "then_here_two"
  a["then"]["there"]["one"] = "then_there_one"
  a["then"]["there"]["two"] = "then_there_two"

  show_array(a, "a")

#  b["subkey"]["now"][1] = "test"
#  delete b["subkey"]["now"][1]

  print "\ndeep_copy(a[now], b[this][is][a][test])"
  deep_copy_array(a["now"], b, "this--is--a--test", "--")
  print "deep_copy(a[now], b[this][is][another])"
  deep_copy_array(a["now"], b, "this,is,another")
  print "deep_copy(a[now][there], b[subkey][now][there])"
  deep_copy_array(a["now"]["there"], b, "subkey,now,there")

  print "\nb[here][now][one] = here_now_one\n"
  b["here"]["now"]["one"] = "here_now_one"

  show_array(b, "b")
}


# FUNCTION deep_copy_array() copies all elements of arr1 to
# arr2, such that the two arrays are completely independent
# and changing an element in one doesn't change anything
# in the other.
# The i arg at the end is intended to be a local variable, so
# you don't actually pass that. You invoke deep_copy_array() 
# like the following:
# deep_copy_array(a, "", b)

function create_subtree(arr, subkey, sep,   i,j) {
  if (subkey) {
    sep = sep ? sep : ","
    j = index(subkey, sep)

    i = j ? substr(subkey, 1, j-1) : subkey
    subkey = j ? substr(subkey, j+length(sep)) : ""

    j = "__RANDOM_KEY_" rand()
    arr[i][j] = ""
    delete arr[i][j]
    create_subtree(arr, subkey, sep)
  }
}

function deep_copy_array(arr1, arr2, subkey, sep,     i, j){
  if (subkey) {
    sep = sep ? sep : ","
    j = index(subkey, sep)

    i = j ? substr(subkey, 1, j-1) : subkey
    subkey = j ? substr(subkey, j+length(sep)) : ""

    j = "__RANDOM_KEY_" rand()
    arr2[i][j] = ""
    delete arr2[i][j]
    deep_copy_array(arr1, arr2[i], subkey, sep)

    return
  }

  for (i in arr1) {
    if(isarray(arr1[i])) {
      j = "__RANDOM_KEY_" rand()
      arr2[i][j] = ""
      delete arr2[i][j]
      deep_copy_array(arr1[i], arr2[i])
    } else {
      arr2[i] = arr1[i]
    }
  }
}

# Function show_array() displays a multidimensional array's
# name and contents. It's invoked like this:
# show_array(myarray1, "myarray1")
# The i argument is just a local variable you don't need to
# use in your call to show_array().
function show_array(arr, name,      i)
{
  for (i in arr) {
    if (isarray(arr[i]))
      show_array(arr[i], name"[" i "]" )
    else
      printf("%s[%s] == %s\n", name, i, arr[i])
  }
}


