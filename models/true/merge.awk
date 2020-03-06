#!/usr/bin/awk -f

($1 == "vert") && (FNR == NR) { vertnr++ }
($1 == "tri") && (FNR != NR) { printf("tri %4d %4d %4d %s\n", $2+vertnr, $3+vertnr, $4+vertnr, $5); next }
1
