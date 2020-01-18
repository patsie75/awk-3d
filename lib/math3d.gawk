#!/usr/bin/gawk -f

function vector(v, x,y,z) {
  v["x"] = x
  v["y"] = y
  v["z"] = z
}

function crossProduct(n, a,b,    l) {
  n["x"] = a["y"] * b["z"] - a["z"] * b["y"]
  n["y"] = a["z"] * b["x"] - a["x"] * b["z"]
  n["z"] = a["x"] * b["y"] - a["y"] * b["x"]

  l = sqrt(n["x"]*n["x"] + n["y"]*n["y"] + n["z"]*n["z"])

  n["x"] /= l ? l : 1
  n["y"] /= l ? l : 1
  n["z"] /= l ? l : 1
}

