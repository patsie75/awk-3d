#!/usr/bin/gawk -f

## Usage: tool.awk [-v x=<xoffset>] [-v y=<yoffset>] [-v z=<zoffset>] [-v size=<newsize>] <file1> [<file2>]

## x, y and z parameters reposition the object on file
## size parameter resizes the object in file
## given 2 files they will be merged into one (2 files maximum)
## file can be either a .mesh file or an .obj file, output will be a .mesh

BEGIN {
  printf("# MESH file created with meshtool.awk\n")

  ## convert size% to decimal value
  if (substr(size, length(size), 1) == "%")
    size = substr(size, 1, length(size)-1) / 100
}

## skip previous headers placed
/# MESH file created with meshtool.awk/ { next }

{ 
  # convert DOS newlines to unix
  sub(//, "")
}

## Read color information from mtllib file (part of .obj file)
($1 == "mtllib") {
  fname = $2
  while ((getline < fname) > 0) {
    sub(//, "")
    if ($1 == "newmtl") {
      mtl = $2
    }
    if ($1 == "Kd") {
      color[mtl] = int($2 * 255) ";" int($3 * 255) ";" int($4 * 255)
      printf("col %-20s %s\n", mtl, color[mtl])
    }
  }
  close(fname)
  printf("\n")
  next
}

## Read mtl color information
($1 == "usemtl") {
  col = $2
  next
}

## print variables
($1 == "var") {
  if ($2 in var) {
    if (var[$2] == $3) next
    printf("### WARN: Conflicting `var` entries (%s was [%s] now [%s])\n", $2, var[$2], $3)
  }
  var[$2] = $3
  printf("var %-20s %s\n", $2, $3)
  next
}

## print vertices
($1 == "v") || ($1 == "vert") {
  # handle merging of two files
  if (FNR == NR) voffset++

  # handle resizing
  if (size) {
    $2 *= size
    $3 *= size
    $4 *= size
  }

  # handle movement
  if (x) $2 += x
  if (y) $3 += y
  if (z) $4 += z

  printf("vert %8.3f %8.3f %8.3f\n", $2, $3, $4)
  next
}

## print triangles/faces
($1 == "f") || ($1 == "tri") {
  sub(/\/.*/, "", $2)
  sub(/\/.*/, "", $3)
  sub(/\/.*/, "", $4)

  ## handle merging of two files
  if (FNR != NR) {
    $2 += voffset
    $3 += voffset
    $4 += voffset
  }

  printf("tri %5d %8d %8d %s\n", $2, $3, $4, $5 ? $5 : ((col in color) ? col : "") )
  next
}

## print comments and emtpy lines
/^[[:space:]]*(#|$)/

