#!/usr/bin/gawk -f

@include "lib/array.gawk"

function shade(col, shades, percent, gradients,    rgb, i) {
  if (split(col, rgb, ";") == 3) {
    delete gradients
    for (i=1; i<=shades; i++) {
      gradients[i] = sprintf("%s;%s;%s", int(rgb[1] - (rgb[1]*(darkness/100)*i/shades)), int(rgb[2] - (rgb[2]*(darkness/100)*i/shades)), int(rgb[3] - (rgb[3]*(darkness/100)*i/shades)) )
    }
    gradients[0] = shades
  } else return -1
}

BEGIN {
  nrshades = 16
  darkness = 50

  shade("0;0;0", nrshades, darkness, gradients)
  assign(gradients, colors, "0")

  shade("255;0;0", nrshades, darkness, gradients)
  assign(gradients, colors, "1")

  shade("0;255;0", nrshades, darkness, gradients)
  assign(gradients, colors, "2")

  shade("255;255;0", nrshades, darkness, gradients)
  assign(gradients, colors, "3")

  shade("0;0;255", nrshades, darkness, gradients)
  assign(gradients, colors, "4")

  shade("255;0;255", nrshades, darkness, gradients)
  assign(gradients, colors, "5")

  shade("0;255;255", nrshades, darkness, gradients)
  assign(gradients, colors, "6")

  shade("255;255;255", nrshades, darkness, gradients)
  assign(gradients, colors, "7")

}

