#!/usr/bin/gawk -f

function create_subtree(arr, subkey, sep,   i,j) {
  if (subkey) {
    sep = sep ? sep : ","
    j = index(subkey, sep)

    i = j ? substr(subkey, 1, j-1) : subkey
    subkey = j ? substr(subkey, j+length(sep)) : ""

    j = "__RANDOM_KEY_" rand()
    arr[i][j] = ""
    delete arr[i][j]
    create_subtree(arr, subkey, sep)
  }
}

## usage: assign(arr1["key"], arr2, "some,subkey")
## will assign all elements from under arr1["key"] to arr2["some"]["subkey"]
function assign(src, dst, subkey, sep,     i, j) {
  if (subkey) {
    sep = sep ? sep : ","
    j = index(subkey, sep)

    i = j ? substr(subkey, 1, j-1) : subkey
    subkey = j ? substr(subkey, j+length(sep)) : ""

    j = "__RANDOM_KEY_" rand()
    dst[i][j] = ""
    delete dst[i][j]
    assign(src, dst[i], subkey, sep)

    return
  }

  for (i in src) {
    if(isarray(src[i])) {
      j = "__RANDOM_KEY_" rand()
      dst[i][j] = ""
      delete dst[i][j]
      assign(src[i], dst[i])
    } else {
      dst[i] = src[i]
    }
  }
}

function show_array(arr, name,      i) {
  for (i in arr) {
    if (isarray(arr[i]))
      if (typeof(i) == "integer")
        show_array(arr[i], name"[" i "]" )
      else
        show_array(arr[i], name"[\"" i "\"]" )
    else
      printf("%s[%s] == %s\n", name, i, arr[i])
  }
}
