#!/usr/bin/gawk -f

function crossProduct(n, a,b,    l) {
  n["x"] = a["y"] * b["z"] - a["z"] - b["y"]
  n["y"] = a["z"] * b["x"] - a["x"] - b["z"]
  n["z"] = a["x"] * b["y"] - a["y"] - b["x"]

  l = sqrt(n["x"]*n["x"] + n["y"]*n["y"] + n["z"]*n["z"])

  n["x"] /= l
  n["y"] /= l
  n["z"] /= l
}

