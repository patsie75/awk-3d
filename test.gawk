#!/usr/bin/gawk -f

function pprint(var,   i) {
  if (isarray(var)) {
    for (i in var) {
      printf("[%s]", i)
      if (isarray(var[i])) {
        pprint(var[i])
      } else printf(" = \"%s\" (array)\n", var[i])
    }
  } else printf("%s (scaler)\n", var)
}

function clone2(lhs, rhs,   i) {
printf("lhs == %s; rhs == %s\n", typeof(lhs), typeof(rhs))

  if (isarray(lhs)) {
printf("lhs -> array == loop\n")
    for (i in lhs) {
printf(" element [%s]\n", i)
      if (isarray(lhs[i])) {
printf("  isarray()\n", i)
        if (!isarray(rhs)) {
printf("rhs 1.1 == %s\n", typeof(rhs))
          rhs[i] = ""
          delete rhs[i]
printf("rhs[%s] 1.2 == %s\n", typeof(rhs))
        }
printf("  clone()\n")
        clone2(lhs[i], rhs[i])
      } else {
        if (!isarray(rhs)) {
printf("rhs 2.1 == %s\n", typeof(rhs))
          rhs[i] = ""
          delete rhs[i]
printf("rhs[%s] 2.2 == %s\n", typeof(rhs))
        }
printf(" rhs[%s] = lhs[%s] == \"%s\"\n", i, i, lhs[i])
        rhs[i] = lhs[i]
      }
    }
  } else rhs = lhs
}


function clone(lhs, rhs,   i) {
printf("CLONE\n")
  for (i in rhs) {
    if (isarray(rhs[i])) {
      lhs[i][1] = ""
      delete lhs[i][1]
printf("clone %s\n", i)
      clone(lhs[i], rhs[i])
    } else {
printf(" assign \"%s\"\n", i )
      if (!isarray(lhs)) {
printf(" LHS == %s\n", typeof(lhs))
        lhs[i][1] = ""
printf(" make array 2\n")
        delete lhs[i][1]
printf(" make array 3\n")
      }
printf(" assign %s [%s]\n", i, typeof(lhs) )
      lhs[i] = rhs[i]
    }
  }
}

function assign(elem, var) {
printf(" var1 == %s\n", typeof(var))
  if (!isarray(var)) {
printf(" creating array from var 1\n")
    var[1] = ""
printf(" creating array from var 2\n")
    delete arr[1]
printf(" creating array from var 3\n")
  }
printf(" var2 == %s\n", typeof(var))
  clone(arr, elem)
}

BEGIN {
a["a"]                = "aa"
a["b"]                = "ab"
a["c"]                = "ac"
a["d"]["a"]           = "ada"
a["d"]["b"]["a"]      = "adba"
a["e"]["a"]["a"]["a"] = "aeaaa"

#  b[1][1] = 1
#  clone(b[1], a)
  #b[1][1] = ""
#  assign(a, b[1])

  b[1] = ""
  clone2(a, b)
  pprint(a)
  pprint(b)

#  v["x"] = 0
#  v["y"] = 0
#  v["z"] = 0
#
#  assign(v, t,1)
#
#  assign(t, o,1)
#
##  obj[1]["tri"][1]["vect"][3]["x"] = 0
##  obj[1]["tri"][1]["vect"][3]["y"] = 0
##  obj[1]["tri"][1]["vect"][3]["z"] = 0
}
