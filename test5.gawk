#!/usr/bin/gawk -f

@include "lib/3d.gawk"

BEGIN {
  if ("COLUMNS" in ENVIRON) {
    width = ENVIRON["COLUMNS"]
    height = ENVIRON["LINES"]
  } else {
    "tput cols"  | getline width
    "tput lines" | getline height
    if (!w || !h)
      w = 80; h = 24
  }
  height = (height-1) * 2

  width = 85
  height = 80
  init(scr, width,height)
  cursor("off")

  # set up viewmode variables
  i = height/3
  viewmode = 1
  drawmode = 2
  camx = 0;   camy = 0;   camz = 200
  movex = 0;  movey = 0;  scale = 1
  anglex = 0; angley = 0; anglez = 0
  pivx = 0;   pivy = 0;   pivz = 0

  movex = width/2
  movey = height/2

  load3d(obj, "models/cube2.obj")

  while ("awk" != "difficult") {
    angley += 0.05;     # spin on y-axis
    anglez += 0.03;     # spin on z-axis

    obj3d(scr, obj)
    draw(scr, 80,2)

    system("sleep 0.1")
  }

  cursor("on")
}
