#!/usr/bin/gawk -f

@include "lib/3d.gawk"
@include "lib/colors.gawk"

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

  ## initialize screen buffer
  #width = 85
  #height = 80
  init(scr, width,height)

  f["interval"] = 0.5

  ## set up viewmode variables
  cam["viewmode"] = 1; # 0 == isometric, 1 == 3d
  cam["drawmode"] = 3; # 0 == vertices; 1 == edges; 2 == triangles; 3 == filled triangles
  cam["wireframe"] = 0; # 0 == solid; 1 == wireframe
  cam["shading"] = 1; # 0 == no shading; 1 == shading
  cam["color"] = 1; # 0 == greyscale; 1 == color

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
  #loadmesh(mesh, "models/pyramid.mesh")
  #loadmesh(mesh, "models/cube.mesh")
  #loadmesh(mesh, "models/octohedron.mesh")
  #loadmesh(mesh, "models/dodecahedron.mesh")
  #loadmesh(mesh, "models/icosahedron.mesh")
  loadmesh(mesh, "models/true/true.mesh")
  #loadmesh(mesh, "models/plane/plane.mesh")

  ##
  ## main loop
  ##
  cursor("off")
  start = myTime()

  while ("awk" != "difficult") {
#  while (framenr++ < 500) {
    cam["angle"]["x"] += 0.01;     # spin on x-axis
    cam["angle"]["y"] += 0.05;     # spin on y-axis
    cam["angle"]["z"] += 0.03;     # spin on z-axis

    cam["loc"]["x"] = cos(cam["angle"]["z"]) * width / 4
    cam["loc"]["y"] = sin(cam["angle"]["y"]) * height / 4

    clear(scr)
    animate(start)
    drawmesh(scr, mesh, cam)
    draw(scr, 0,0)
    printf("\033[H%.2fFPS", fps(f))
    system("sleep 0.01")
  }

  cursor("on")
}

function between(value, min, max) {
  if ((value >= min) && (value < max)) return(1)
  else return(0)
}

function animate(starttime) {
  elapsed = myTime() - starttime

  if (between(elapsed,  0,  5)) { cam["viewmode"] = 0; cam["drawmode"] = 0; cam["wireframe"] = 1; cam["shading"] = 0; cam["color"] = 0 }
  if (between(elapsed,  5, 10)) { cam["viewmode"] = 0; cam["drawmode"] = 2; cam["wireframe"] = 1; cam["shading"] = 0; cam["color"] = 0 }
  if (between(elapsed, 10, 15)) { cam["viewmode"] = 0; cam["drawmode"] = 3; cam["wireframe"] = 0; cam["shading"] = 0; cam["color"] = 0 }
  if (between(elapsed, 15, 20)) { cam["viewmode"] = 0; cam["drawmode"] = 3; cam["wireframe"] = 0; cam["shading"] = 1; cam["color"] = 0 }
  if (between(elapsed, 20, 25)) { cam["viewmode"] = 1; cam["drawmode"] = 3; cam["wireframe"] = 0; cam["shading"] = 1; cam["color"] = 0 }
  if (between(elapsed, 25, 30)) { cam["viewmode"] = 1; cam["drawmode"] = 3; cam["wireframe"] = 0; cam["shading"] = 1; cam["color"] = 1 }
  if (elapsed > 35) exit 0
}
