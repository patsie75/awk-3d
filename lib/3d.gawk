#!/usr/bin/gawk -f

@include "lib/2d.gawk"
@include "lib/array.gawk"
@include "lib/math3d.gawk"

function variable(value, vararr,   v, c, neg) {
  v = value
  c = substr(v,1,1)
  neg = 0

  ## just a number
  if (v == v+0) return(v)

  ## negative variable
  if (c == "-") {
    neg = 1
    v = substr(v,2)
  }

  # return variable content or 0
  if (v in vararr)
    return neg ? -vararr[v] : vararr[v]
  else return 0
}


function load3d(obj, file,   var, linenr, v, e) {
  linenr = 0

  while ((getline < file) > 0) {
    linenr++

    if ( (NF > 0) && ($1 !~ /^(#|;)/) ) {

      if ($1 == "var") {
        if (NF == 3) var[$2] = $3
        else printf("Error line #%d: syntax error: \"var <variable> <value>\"\n", linenr)

      } else if ($1 == "vert") {
        if (NF == 4) {
          v++
          obj["vert"][v]["x"] = variable($2, var)
          obj["vert"][v]["y"] = variable($3, var)
          obj["vert"][v]["z"] = variable($4, var)
          #printf("load3d(): v[%d] = (%s, %s, %s) -> (%s, %s, %s)\n", v, $2, $3, $4, obj["vert"][v]["x"], obj["vert"][v]["y"], obj["vert"][v]["z"])
        } else printf("Error line #%d: syntax error: \"vert <x> <y> <z>\"\n", linenr)
  
      } else if ($1 == "edge") {
        if (NF == 4) {
          e++
          obj["edge"][e]["from"]  = variable($2, var)
          obj["edge"][e]["to"]    = variable($3, var)
          obj["edge"][e]["color"] = variable($4, var)
          #printf("load3d(): e[%d] = (%s, %s, %s) -> (%s, %s, %s)\n", v, $2, $3, $4, obj["edge"][e]["from"], obj["edge"][e]["to"], obj["edge"][e]["color"])
        } else printf("Error line #%d: syntax error: \"edge <vertex1> <vertex2> <color>\"\n", linenr)
      } else if ($1 == "tri") {
        if (NF == 5) {
          t++
          obj["tri"][t][1] = variable($2, var)
          obj["tri"][t][2] = variable($3, var)
          obj["tri"][t][3] = variable($4, var)
          obj["tri"][t]["color"] = variable($5, var)
          printf("load3d(): t[%d] = (%s, %s, %s, %s) -> (%s, %s, %s, %s)\n", t, $2, $3, $4, $5, obj["tri"][t][1], obj["tri"][t][2], obj["tri"][t][3], obj["tri"][t]["color"])
        } else printf("Error line #%d: syntax error: \"tri <vertex1> <vertex2> <vertex3> <color>\"\n", linenr)

      } else {
        printf("Error line #%d: unknown keyword \"%s\"\n", linenr, $1)
      }
    }
  }
  obj["vertices"] = v
  obj["edges"] = e
  obj["tris"] = t

  printf("Loaded %d vertices, %d edges and %d triangles in %d lines\n", v, e, t, linenr)
}

function obj3d(scr, obj,   v, dx,dy,dz, zx,zy,yx,yz,xy,xz, px,py, v1,v2,v3, xrotoffset,yrotoffset,zrotoffset, xpos,ypos,zpos) {

  scale = (viewmode == 1) ? 1 / camz : 1

  # calculate screen coordinates of each vertex
  for (v=1; v<=obj["vertices"]; v++) {
    # delta from pivot point
    dx = obj["vert"][v]["x"] - pivx
    dy = obj["vert"][v]["y"] - pivy
    dz = obj["vert"][v]["z"] - pivz

    zx = dx*cos(anglez) - dy*sin(anglez) - dx
    zy = dx*sin(anglez) + dy*cos(anglez) - dy

    yx = (dx+zx)*cos(angley) - dz*sin(angley) - (dx+zx)
    yz = (dx+zx)*sin(angley) + dz*cos(angley) - dz

    xy = (dy+zy)*cos(anglex) - (dz+yz)*sin(anglex) - (dy+zy)
    xz = (dy+zy)*sin(anglex) + (dz+yz)*cos(anglex) - (dz+yz)

    xrotoffset = yx+zx
    yrotoffset = zy+xy
    zrotoffset = xz+yz

    if (viewmode == 1) {
      # real 3d view
      zpos[v] = (obj["vert"][v]["z"] + zrotoffset + camz)
      xpos[v] = (obj["vert"][v]["x"] + xrotoffset + camx) / zpos[v] / scale + movex
      ypos[v] = (obj["vert"][v]["y"] + yrotoffset + camy) / zpos[v] / scale + movey
    } else {
      # isometric view
      xpos[v] = (obj["vert"][v]["x"] + xrotoffset + camx) / scale + movex
      ypos[v] = (obj["vert"][v]["y"] + yrotoffset + camy) / scale + movey
    }

  }

  # clear canvas
  clear(scr)

  # draw pivot pixel
  px = ( (pivx+camx) / (pivz+camz) ) / scale + movex
  py = ( (pivy+camy) / (pivz+camz) ) / scale + movey
  pixel(scr, px,py, pc)

  # drawmode, edges or vertices
  if (drawmode == 3) {
    # draw filled triangles
    for (t=1; t<=obj["tris"]; t++) {
      v1 = obj["tri"][t][1]
      v2 = obj["tri"][t][2]
      v3 = obj["tri"][t][3]

#      a["x"] = obj["vert"][v2]["x"] - obj["vert"][v1]["x"]
#      a["y"] = obj["vert"][v2]["y"] - obj["vert"][v1]["y"]
#      a["z"] = obj["vert"][v2]["z"] - obj["vert"][v1]["z"]
#
#      b["x"] = obj["vert"][v3]["x"] - obj["vert"][v1]["x"]
#      b["y"] = obj["vert"][v3]["y"] - obj["vert"][v1]["y"]
#      b["z"] = obj["vert"][v3]["z"] - obj["vert"][v1]["z"]

      a["x"] = xpos[v2] - xpos[v1]
      a["y"] = ypos[v2] - ypos[v1]
      a["z"] = zpos[v2] - zpos[v1]

      b["x"] = xpos[v3] - xpos[v1]
      b["y"] = ypos[v3] - ypos[v1]
      b["z"] = zpos[v3] - zpos[v1]

      crossProduct(n, a,b)

      if (n["z"] < 0)
        fillTriangle(scr, xpos[v1],ypos[v1], xpos[v2],ypos[v2], xpos[v3],ypos[v3], obj["tri"][t]["color"])
    }
  } else if (drawmode == 2) {
    # draw triangles
    for (t=1; t<=obj["tris"]; t++) {
      v1 = obj["tri"][t][1]
      v2 = obj["tri"][t][2]
      v3 = obj["tri"][t][3]

#      a["x"] = obj["vert"][v2]["x"] - obj["vert"][v1]["x"]
#      a["y"] = obj["vert"][v2]["y"] - obj["vert"][v1]["y"]
#      a["z"] = obj["vert"][v2]["z"] - obj["vert"][v1]["z"]
#
#      b["x"] = obj["vert"][v3]["x"] - obj["vert"][v1]["x"]
#      b["y"] = obj["vert"][v3]["y"] - obj["vert"][v1]["y"]
#      b["z"] = obj["vert"][v3]["z"] - obj["vert"][v1]["z"]

      a["x"] = xpos[v2] - xpos[v1]
      a["y"] = ypos[v2] - ypos[v1]
      a["z"] = zpos[v2] - zpos[v1]

      b["x"] = xpos[v3] - xpos[v1]
      b["y"] = ypos[v3] - ypos[v1]
      b["z"] = zpos[v3] - zpos[v1]

      crossProduct(n, a,b)

      if (n["z"] < 0)
        triangle(scr, xpos[v1],ypos[v1], xpos[v2],ypos[v2], xpos[v3],ypos[v3], obj["tri"][t]["color"])
    }
  } else if (drawmode == 1) {
    # draw edges
    for (e=1; e<=obj["edges"]; e++) {
      v1 = obj["edge"][e]["from"]
      v2 = obj["edge"][e]["to"]

      line(scr, xpos[v1],ypos[v1], xpos[v2], ypos[v2], obj["edge"][e]["color"])
    }
  } else {
    # draw vertices
    for (v=1; v<=obj["vertices"]; v++)
      pixel(scr, xpos[v], ypos[v], color["white"])
  }

}

