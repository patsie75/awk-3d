#!/usr/bin/awk -f

($1 == "vert") {
  if (FNR == NR)
    vertnr++
}

($1 == "tri") {
  if (FNR != NR)
    printf("tri %4d %4d %4d %s\n", $2+vertnr, $3+vertnr, $4+vertnr, $5)
  else
    print
  next
}

1
