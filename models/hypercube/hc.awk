#!/usr/bin/awk -f

## header and vertices generation
BEGIN {
  printf("##\n## H Y P E R C U B E\n##\n\n")
  for (z=-15; z<=15; z+=10) {
    printf("# z plane %d\n", z)
    for (y=-15; y<=15; y+=10) {
      for (x=-15; x<=15; x+=10) {
        printf("vert %3d %3d %3d\n", x, y, z)
      }
      printf("\n")
    }
  }
}

## parse quad data and convert to triangles
($1 != "#") && (NF == 4) {
  printf("tri %3d %3d %3d\ntri %3d %3d %3d\n", $1, $4, $3, $3, $2, $1)
  next
}

## print non-quad data as-is
1
