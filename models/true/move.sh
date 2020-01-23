#!/usr/bin/gawk -f

($1 == "vert") { printf("vert %4d %4d %4d\n", $2+x, $3+y, $4+z) }
($1 != "vert")
