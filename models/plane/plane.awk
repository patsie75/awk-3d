#!/usr/bin/gawk -f

BEGIN {
  srand()

  maxx = 30	# number of x vertices
  maxz = 10	# number of z vertices

  widthx = 5	# width between x vertices
  widthz = 5	# width between z vertices
  height = 5	# height (y vertices)

  col = 7	# color of triangles

  for (z=1; z<=maxz; z++) {
    for (x=1; x<=maxx; x++) {
      ## height based on previous (x pos) vertex
      y = (rand()*height) - (height/2) + prev[x]
      prev[x] = y

      ## print new vertex
      printf("vert %8.3f %8.3f %8.3f\n", (x*widthx)-(maxx*(widthx/2)), y, (z*widthz)-(maxz*(widthz/2)))
    }
  }

  printf("\n")

  for (z=0; z<maxz-1; z++) {
    for (x=1; x<maxx; x++) {
      ## print two triangles for each position
      printf("tri %4d %4d %4d %2d\n", (z+1)*maxx+x, (z+1)*maxx+x+1, (z*maxx)+x+1, col)
      printf("tri %4d %4d %4d %2d\n", (z*maxx)+x+1, (z*maxx)+x, (z+1)*maxx+x, col)
    }
  }
}
