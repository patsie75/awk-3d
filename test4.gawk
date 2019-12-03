#!/usr/bin/gawk -f

@include "array.gawk"

function vector(v, x,y,z) {
  v["x"] = x
  v["y"] = y
  v["z"] = z
}

function triangle(t, x1,y1,z1, x2,y2,z2, x3,y3,z3) {
  t["vect"][1]["x"] = x1
  t["vect"][1]["y"] = y1
  t["vect"][1]["z"] = z1

  t["vect"][2]["x"] = x2
  t["vect"][2]["y"] = y2
  t["vect"][2]["z"] = z2

  t["vect"][3]["x"] = x3
  t["vect"][3]["y"] = y3
  t["vect"][3]["z"] = z3
}

function readobj(o, fname) {
  while ((getline < fname) > 0) {
  }
}

BEGIN {
#  obj[1]["tri"][1]["vect"][1]["x"] = 0
#  obj[1]["tri"][1]["vect"][1]["y"] = 0
#  obj[1]["tri"][1]["vect"][1]["z"] = 0
#
#  obj[1]["tri"][1]["vect"][2]["x"] = 0
#  obj[1]["tri"][1]["vect"][2]["y"] = 0
#  obj[1]["tri"][1]["vect"][2]["z"] = 0
#
#  obj[1]["tri"][1]["vect"][3]["x"] = 0
#  obj[1]["tri"][1]["vect"][3]["y"] = 0
#  obj[1]["tri"][1]["vect"][3]["z"] = 0

#  v["x"] = 0
#  v["y"] = 0
#  v["z"] = 0

  vector(v, 1,2,3)
  show_array(v, "v")

  assign(v, tri, "vect,1")
  assign(v, tri, "vect,2")
  assign(v, tri, "vect,3")
  delete(v)

  assign(tri, obj, "tri,1")

  triangle(tri, 11,21,31, 12,22,32, 13,23,33)
  assign(tri, obj, "tri,2")

  delete(tri)

  show_array(tri, "tri")
  show_array(obj, "obj")
}
