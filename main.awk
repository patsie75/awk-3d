#!/usr/bin/gawk -f

BEGIN {
  # Definition of colors
  color["black"] = 0
  color["red"] = 1
  color["green"] = 2
  color["yellow"] = 3
  color["blue"] = 4
  color["magenta"] = 5
  color["cyan"] = 6
  color["white"] = 7
}

function abs(i) { return( (i<0) ? -i : i ) }
function max(a,b) { return( (a>b) ? a : b ) }
function min(a,b) { return( (a<b) ? a : b ) }
function shortint(f) { return( int(sprintf("%.3f", f)) ) }

# return number of frames in time interval
function fps(f) {
  f["frame"] ++
  f["now"] = myTime()

  if (f["interval"] == 0)
    f["interval"] = 1

  if ( (f["now"] - f["prev"]) >= f["interval"] ) {
    f["fps"] = f["frame"] / (f["now"] - f["prev"])
    f["prev"] = f["now"]
    f["frame"] = 0
  }

  return( f["fps"] )
}

## initialize and clear canvas
function init(scr, width, height) {
  scr["width"] = width
  scr["height"] = height

  clear(scr)
}

# turn cursor on or off
function cursor(state) {
  if (state == "off") printf("\033[?25l")
  else if (state == "on") printf("\033[?25h")
}

## clean the canvas (black)
function clear(scr) {
  fill(scr, color["black"])
}

## fill the canvas with a color
function fill(scr, col,   i, size) {
  size = scr["height"] * scr["width"]
  for (i=0; i<size; i++)
    scr[i] = col
}

## Draw "canvas" onto the terminal
function draw(scr,   x,y,ywidth,y2width,buf) {
  # put clear screen in screen buffer
  #buf = "\033[2J\033[H"
  buf = "\033[H"

  w = scr["width"]
  h = scr["height"]

  prevfg = -1
  prevbg = -1

  # for each line
  for (y=0; y<h; y+=2) {
    ywidth = y*w
    y2width = (y+1)*w

    # for each pixel in line
    for (x=0; x<w; x++) {
      fg = scr[ywidth+x]
      bg = scr[y2width+x]
      if ((fg != prevfg) || (bg != prevbg))
        buf = buf sprintf("\033[%d;%dm%s", fg+30, bg+40, "▀")
      else
        buf = buf "▀"
      prevfg = fg
      prevbg = bg
    }

    # end of line
    buf = buf "\n"
  }

  # draw buffer to screen and reset colors
  printf("%s\033[0m", buf)
#  fflush("/dev/stdout")
}


## Draw a pixel of color "col" on position (x,y) on "canvas"
function pixel(scr, x, y, col,   x0,y0) {
  #printf("pixel(%d,%d) [%.5f,%.5f]\n", shortint(x),shortint(y), x,y )
  #scr[int(y)*scr["width"] + int(x)] = col
  #scr[shortint(y)*scr["width"] + shortint(x)] = col
  #scr[int(y+0.0001)*scr["width"] + int(x+0.0001)] = col

  x0 = int(x+0.0001)
  y0 = int(y+0.0001)
  if ((0 <= x0 && x0 < scr["width"]) && (0 <= y0 && y0 < scr["height"]))
    scr[y0*scr["width"] + x0] = col
}

## Draw a line from (x1,y1) to (x2,y2)
function line(scr, x1,y1,x2,y2, col,   direction, a1,a2,b1,b2, tmp, i,j, m) {
  #printf("line2(): (%d,%d),(%d,%d)\n", x1,y1, x2,y2)

  if (abs(x1-x2) >= abs(y1-y2)) {
    # horizontal line
    direction = 1
    a1=x1; a2=x2; b1=y1; b2=y2
  } else {
    # vertical line
    direction = 0
    a1=y1; a2=y2; b1=x1; b2=x2
  }

  # swap points if p1 > p2
  if (a1 > a2) {
    tmp=a1; a1=a2; a2=tmp
    tmp=b1; b1=b2; b2=tmp
  }

  # calculate slope/delta
  m = (a2-a1) ? (b2-b1) / (a2-a1) : 0

  j = b1
  # draw either a "horizontal" or "vertical" line
  for (i=a1; i<=a2; i++) {
    #if (direction) pixel(scr, i,j, col)
    #else pixel(scr, j,i, col)
    pixel(scr, direction?i:j,direction?j:i, col)
    j += m
  }
}

function box(scr, x1,y1,x2,y2, col,   i, tmp) {
  if (x1 > x2) {
    tmp=x1; x1=x2; x2=tmp
  }
  if (y1 > y2) {
    tmp=y1; y1=y2; y2=tmp
  }

  for (i=x1; i<=x2; i++) {
    pixel(scr, i,y1, col)
    pixel(scr, i,y2, col)
  }
  for (i=y1+1; i<y2; i++) {
    pixel(scr, x1,i, col)
    pixel(scr, x2,i, col)
  }

}

function circle(scr, x0,y0,r, col,   x,y, dx,dy, err) {
  x = r-1
  y = 0
  dx = dy = 1
  err = dx - (r*2)

  while (x >= y) {
    pixel(scr, x0+x, y0+y, col)
    pixel(scr, x0+y, y0+x, col)
    pixel(scr, x0-y, y0+x, col)
    pixel(scr, x0-x, y0+y, col)

    pixel(scr, x0-x, y0-y, col)
    pixel(scr, x0-y, y0-x, col)
    pixel(scr, x0+y, y0-x, col)
    pixel(scr, x0+x, y0-y, col)

    if (err <= 0) {
      y += 1
      err += dy
      dy += 2
    }
    if (err > 0) {
      x -= 1
      dx += 2
      err += dx - (r*2)
    }
  }
}

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

      } else {
        printf("Error line #%d: unknown keyword \"%s\"\n", linenr, $1)
      }
    }
  }
  obj["vertices"] = v
  obj["edges"] = e

  printf("Loaded %d vertices and %d edges in %d lines\n", v, e, linenr)
}


function stage1() {
  pc = color["black"]
  viewmode = 1;		# true-3d
  drawmode = 0;		# draw vertices
}

function stage2() {
  drawmode = 1;		# draw edges
}

function stage3() {
  anglez += 0.03;	# spin on z-axis
}

function stage4() {
  pc = color["green"];	# pivot point
  anglez += 0.03;	# spin on z-axis
}

function stage5() {
  angley += 0.05;	# spin on y-axis
  anglez += 0.03;	# spin on z-axis
}

function stage6() {
  anglex += 0.02;	# spin on x-axis
  angley += 0.05;	# spin on y-axis
  anglez += 0.03;	# spin on z-axis
}

function stage7() {
  anglex += 0.02;	# spin on x-axis
  angley += 0.05;	# spin on y-axis
  anglez += 0.03;	# spin on z-axis

  camx = cos(anglez)*width/4;	# move camera x-axis
  camy = sin(angley)*height/4;	# move camera y-axis
}

function myTime() {
  # /proc/uptime has more precision than systime()
  if ((getline < "/proc/uptime") > 0) {
    close("/proc/uptime")
    return($1)
  } else return(systime())
}

##
## Main program
##
BEGIN {
  #pi = atan2(0, -1)

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

  # create empty canvas
  init(scr, width, height)
  cursor("off")

  # set up viewmode variables
  i = height/3
  viewmode = 0
  camx = 0;   camy = 0;   camz = 200
  movex = 0;  movey = 0;  scale = 1
  anglex = 0; angley = 0; anglez = 0
  pivx = 0;   pivy = 0;   pivz = 0

  movex = width/2
  movey = height/2

  # load 3D object
  load3d(obj, "models/pyramid.obj")
  #load3d(obj, "models/cube.obj")
  #load3d(obj, "models/octohedron.obj")
  #load3d(obj, "models/icosahedron.obj")

  #printf("vertices: %d\n", obj["vertices"])
  #for (v=1; v<=obj["vertices"]; v++)
  #  printf("v[%d] = (%3d, %3d, %3d)\n", v, obj["vert"][v]["x"], obj["vert"][v]["y"], obj["vert"][v]["z"])
  #printf("edges: %d\n", obj["edges"])
  #for (e=1; e<=obj["edges"]; e++)
  #  printf("e[%d] = (%3d, %3d, %3d)\n", v, obj["edge"][e]["from"], obj["edge"][e]["to"], obj["edge"][e]["color"])
  #exit(0)


  ##           ##
  ## main loop ##
  ##           ##

  framenr = 0
  starttime = myTime()

  while ("awk" != "difficult") {
    time = myTime() - starttime
    framenr++

    ## do different things at different times
    if (framenr == 1) { stage1(); object = 1 }
    if ( 5 <= time && time < 10) stage2()
    if (10 <= time && time < 15) stage3()
    if (15 <= time && time < 20) stage4()
    if (20 <= time && time < 25) stage5()
    if (25 <= time && time < 30) stage6()
    if (30 <= time) stage7()
    if (35 <= time && object == 1) { load3d(obj, "models/cube.obj"); object = 2 }
    if (40 <= time && object == 2) { load3d(obj, "models/octohedron.obj"); object = 3 }
    if (45 <= time && object == 3) { load3d(obj, "models/icosahedron.obj"); object = 4 }

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
    if (drawmode) {
      # draw edges
      for (e=1; e<=obj["edges"]; e++) {
        vert1 = obj["edge"][e]["from"]
        vert2 = obj["edge"][e]["to"]

        line(scr, xpos[vert1],ypos[vert1], xpos[vert2], ypos[vert2], obj["edge"][e]["color"])
      }
    } else {
      # draw vertices
      for (v=1; v<=obj["vertices"]; v++)
        pixel(scr, xpos[v], ypos[v], color["white"])
    }

    # draw canvas to screen
    draw(scr)

    # print object vertices information
    #for (v=1; v<=obj["obj"]["vertices"]; v++)
    #  printf("#%3d xpos[%d]=%7.3f   ypos[%d]=%7.3f   zpos[%d]=%7.3f\n", framenr, v, xpos[v], v, ypos[v], v, zpos[v])

    fps(f)
    printf("\033[H%.1fFPS", f["fps"])

#    system("sleep 0.01")
  }

  cursor("on")
}

