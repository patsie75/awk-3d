#!/usr/bin/gawk -f

## Usage: obj2mesh <file.obj> 

## Converts an 3d .obj file into a mesh format, optionally including color information from an .mtl file

function readmtl(fname) {
  while ((getline < fname) > 0) {
    if ($1 == "newmtl") mtl = $2
    if ($1 == "Kd") color[mtl] = int($2 * 255) ";" int($3 * 255) ";" int($4 *255)
  }
  close(fname)

  for (mtl in color)
    printf("col %-15s %s\n", mtl, color[mtl])
  printf("\n")
}

BEGIN { printf("#\n# Converted with obj2mesh.awk\n#\n\n") }
($1 == "mtllib") { readmtl($2) }
($1 == "usemtl") { col = $2 }
($1 == "v") { printf("vert %8.3f %8.3f %8.3f\n", $2, $3, $4) }
($1 == "f") { printf("tri %5d %8d %8d %15s\n", $2, $3, $4, col in color ? col : "") }
