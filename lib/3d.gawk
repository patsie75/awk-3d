#!/usr/bin/gawk -f

@include "lib/2d.gawk"
@include "lib/array.gawk"
@include "lib/math3d.gawk"

function variable(value, vararr,   v, neg) {
  v = value
  neg = 0

  ## just a number
  if (v == v+0) return(v)

  ## negative variable
  if (substr(v,1,1) == "-") {
    neg = 1
    v = substr(v,2)
  }

  # return variable content or 0
  if (v in vararr)
    return neg ? -vararr[v] : vararr[v]
  else return 0
}


function loadmesh(mesh, file,   var, linenr, v, e) {
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
          mesh["vert"][v]["x"] = variable($2, var)
          mesh["vert"][v]["y"] = variable($3, var)
          mesh["vert"][v]["z"] = variable($4, var)
          #printf("loadmesh(): v[%d] = (%s, %s, %s) -> (%s, %s, %s)\n", v, $2, $3, $4, mesh["vert"][v]["x"], mesh["vert"][v]["y"], mesh["vert"][v]["z"])
        } else printf("Error line #%d: syntax error: \"vert <x> <y> <z>\"\n", linenr)
  
      } else if ($1 == "edge") {
        if ((NF == 4) || (NF == 5)) {
          e++
          mesh["edge"][e]["from"]  = variable($2, var)
          mesh["edge"][e]["to"]    = variable($3, var)
          mesh["edge"][e]["color"] = (NF == 5) ? variable($4, var) : 7
          #printf("loadmesh(): e[%d] = (%s, %s, %s) -> (%s, %s, %s)\n", v, $2, $3, $4, mesh["edge"][e]["from"], mesh["edge"][e]["to"], mesh["edge"][e]["color"])
        } else printf("Error line #%d: syntax error: \"edge <vertex1> <vertex2> [<color>]\"\n", linenr)
      } else if ($1 == "tri") {
        if ((NF == 4) || (NF == 5)) {
          t++
          mesh["tri"][t][1] = variable($2, var)
          mesh["tri"][t][2] = variable($3, var)
          mesh["tri"][t][3] = variable($4, var)
          mesh["tri"][t]["color"] = (NF == 5) ? variable($5, var) : 7
          printf("loadmesh(): t[%d] = (%s, %s, %s, %s) -> (%s, %s, %s, %s)\n", t, $2, $3, $4, $5, mesh["tri"][t][1], mesh["tri"][t][2], mesh["tri"][t][3], mesh["tri"][t]["color"])
        } else printf("Error line #%d: syntax error: \"tri <vertex1> <vertex2> <vertex3> [<color>]\"\n", linenr)

      } else {
        printf("Error line #%d: unknown keyword \"%s\"\n", linenr, $1)
      }
    }
  }
  mesh["vertices"] = v
  mesh["edges"] = e
  mesh["tris"] = t

  printf("Loaded %d vertices, %d edges and %d triangles in %d lines\n", v, e, t, linenr)
}

function drawmesh(scr, mesh, cam,    v, dx,dy,dz, zx,zy,yx,yz,xy,xz, px,py, v1,v2,v3, xrotoffset,yrotoffset,zrotoffset, xpos,ypos,zpos) {

  ## 3D or isometric depth
  cam["move"]["z"] = (cam["viewmode"] == 1) ? 1 / cam["loc"]["z"] : 1

  # calculate screen coordinates of each vertex
  for (v=1; v<=mesh["vertices"]; v++) {
    # delta from pivot point
    dx = mesh["vert"][v]["x"] - cam["piv"]["x"]
    dy = mesh["vert"][v]["y"] - cam["piv"]["y"]
    dz = mesh["vert"][v]["z"] - cam["piv"]["z"]

    zx = dx*cos(cam["angle"]["z"]) - dy*sin(cam["angle"]["z"]) - dx
    zy = dx*sin(cam["angle"]["z"]) + dy*cos(cam["angle"]["z"]) - dy

    yx = (dx+zx)*cos(cam["angle"]["y"]) - dz*sin(cam["angle"]["y"]) - (dx+zx)
    yz = (dx+zx)*sin(cam["angle"]["y"]) + dz*cos(cam["angle"]["y"]) - dz

    xy = (dy+zy)*cos(cam["angle"]["x"]) - (dz+yz)*sin(cam["angle"]["x"]) - (dy+zy)
    xz = (dy+zy)*sin(cam["angle"]["x"]) + (dz+yz)*cos(cam["angle"]["x"]) - (dz+yz)

    xrotoffset = yx+zx
    yrotoffset = zy+xy
    zrotoffset = xz+yz

    if (cam["viewmode"] == 1) {
      # real 3d view
      zpos[v] = (mesh["vert"][v]["z"] + zrotoffset + cam["loc"]["z"])
      xpos[v] = (mesh["vert"][v]["x"] + xrotoffset + cam["loc"]["x"]) / zpos[v] / cam["move"]["z"] + cam["move"]["x"]
      ypos[v] = (mesh["vert"][v]["y"] + yrotoffset + cam["loc"]["y"]) / zpos[v] / cam["move"]["z"] + cam["move"]["y"]
    } else {
      # isometric view
      xpos[v] = (mesh["vert"][v]["x"] + xrotoffset + cam["loc"]["x"]) / cam["move"]["z"] + cam["move"]["x"]
      ypos[v] = (mesh["vert"][v]["y"] + yrotoffset + cam["loc"]["y"]) / cam["move"]["z"] + cam["move"]["y"]
    }

  }

  # draw pivot pixel
  px = ( (cam["piv"]["x"]+cam["loc"]["x"]) / (cam["piv"]["z"]+cam["loc"]["z"]) ) / cam["move"]["z"] + cam["move"]["x"]
  py = ( (cam["piv"]["y"]+cam["loc"]["y"]) / (cam["piv"]["z"]+cam["loc"]["z"]) ) / cam["move"]["z"] + cam["move"]["y"]
  pixel(scr, px,py, pc)

  # drawmode, edges or vertices
  if ((cam["drawmode"] == 3) || (cam["drawmode"] == 2)){
    # draw filled triangles
    for (t=1; t<=mesh["tris"]; t++) {
      v1 = mesh["tri"][t][1]
      v2 = mesh["tri"][t][2]
      v3 = mesh["tri"][t][3]

      vector(a, xpos[v2]-xpos[v1], ypos[v2]-ypos[v1], zpos[v2]-zpos[v1])
      vector(b, xpos[v3]-xpos[v1], ypos[v3]-ypos[v1], zpos[v3]-zpos[v1])

      crossProduct(n, a,b)

      if (n["z"] < 0) {
        if (cam["drawmode"] == 3)
          fillTriangle(scr, xpos[v1],ypos[v1], xpos[v2],ypos[v2], xpos[v3],ypos[v3], mesh["tri"][t]["color"])
        else
          triangle(scr, xpos[v1],ypos[v1], xpos[v2],ypos[v2], xpos[v3],ypos[v3], mesh["tri"][t]["color"])
      }
    }
  } else if (cam["drawmode"] == 1) {
    # draw edges
    for (e=1; e<=mesh["edges"]; e++) {
      v1 = mesh["edge"][e]["from"]
      v2 = mesh["edge"][e]["to"]

      line(scr, xpos[v1],ypos[v1], xpos[v2], ypos[v2], mesh["edge"][e]["color"])
    }
  } else {
    # draw vertices
    for (v=1; v<=mesh["vertices"]; v++)
      pixel(scr, xpos[v], ypos[v], color["white"])
  }

}

