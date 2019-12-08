#!/usr/bin/gawk -f

@include "lib/3d.gawk"

BEGIN {
#  if ("COLUMNS" in ENVIRON) {
#    width = ENVIRON["COLUMNS"]
#    height = ENVIRON["LINES"]
#  } else {
#    "tput cols"  | getline width
#    "tput lines" | getline height
#    if (!w || !h)
#      w = 80; h = 24
#  }
#  height = (height-1) * 2

  ## initialize screen buffer
  width = 85
  height = 80
  init(scr, width,height)

  ## set up viewmode variables
  cam["viewmode"] = 1; # 0 == isometric, 1 == 3d
  cam["drawmode"] = 3; # 0 == vertices; 1 == edges; 2 == triangles; 3 == filled triangles
  cam["wireframe"] = 0; # 0 == solid; 1 == wireframe

  ## create 'camera' array
  array(cam, "loc")
  array(cam, "move")
  array(cam, "angle")
  array(cam, "piv")

  ## set camera values
  vector(cam["loc"], 0, 0, 200)
  vector(cam["move"], width/2, height/2, 1)
  vector(cam["angle"], 0, 0, 0)
  vector(cam["piv"], 0, 0, 0)

  ## load 3D object
  loadmesh(mesh, "models/cube.mesh")
  #loadmesh(mesh, "models/pyramid.mesh")
  #loadmesh(mesh, "models/octohedron.mesh")

  ##
  ## main loop
  ##
  cursor("off")

  while ("awk" != "difficult") {
    cam["angle"]["y"] += 0.05;     # spin on y-axis
    cam["angle"]["z"] += 0.03;     # spin on z-axis

    clear(scr)
    drawmesh(scr, mesh, cam)
    draw(scr, 0,0)

    system("sleep 0.05")
  }

  cursor("on")
}
