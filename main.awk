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
function draw(scr, xpos,ypos,    x,y,ywidth,y2width,buf) {
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
    buf = buf sprintf("\033[%s;%sH", (y/2)+ypos+1, xpos+1)

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

#    # end of line
#    buf = buf "\n"
  }

  # draw buffer to screen and reset colors
  printf("%s\033[0m\n", buf)
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

function line3d(scr, vert, piv, angle, move, cam, viewmode, col,   dx,dy,dz, xy,xz,yx,yz,zx,zy, xrotoffset,yrotoffset,zrotoffset, v,scale) {
    # calculate screen coordinates of each vertex
    for (v=1; v<=2; v++) {
      # delta from pivot point
      dx = vert[v]["x"] - piv["x"]
      dy = vert[v]["y"] - piv["y"]
      dz = vert[v]["z"] - piv["z"]

      zx = dx*cos(angle["z"]) - dy*sin(angle["z"]) - dx
      zy = dx*sin(angle["z"]) + dy*cos(angle["z"]) - dy 

      yx = (dx+zx)*cos(angle["y"]) - dz*sin(angle["y"]) - (dx+zx)
      yz = (dx+zx)*sin(angle["y"]) + dz*cos(angle["y"]) - dz

      xy = (dy+zy)*cos(angle["x"]) - (dz+yz)*sin(angle["x"]) - (dy+zy)
      xz = (dy+zy)*sin(angle["x"]) + (dz+yz)*cos(angle["x"]) - (dz+yz)

      xrotoffset = yx + zx
      yrotoffset = zy + xy
      zrotoffset = xz + yz

      if (viewmode == 1) { 
        # real 3d view
        scale = 1 / cam["z"]
        pos[v]["z"] = (vert[v]["z"] + zrotoffset + cam["z"])
        pos[v]["x"] = (vert[v]["x"] + xrotoffset + cam["x"]) / pos[v]["z"] / scale + move["x"]
        pos[v]["y"] = (vert[v]["y"] + yrotoffset + cam["y"]) / pos[v]["z"] / scale + move["y"]
      } else {
        # isometric view
        scale = 1
        xpos[v] = (vert[v]["x"] + xrotoffset + cam["x"]) / scale + move["x"]
        ypos[v] = (vert[v]["y"] + yrotoffset + cam["y"]) / scale + move["y"]
      }

      line(scr, xpos[1],ypos[1], xpos[2], ypos[2], col)
    }
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

function triangle(src, x1,y1, x2,y2, x3,y3, col) {
  line(scr, x1,y1, x2,y2, col)
  line(scr, x2,y2, x3,y3, col)
  line(scr, x3,y3, x1,y1, col)
}

function hline(scr, x1,y1, len, col, dbg,   i) {
  l = int(x1+len)
#if (dbg) printf("hline(): (%3d,%3d),%2d -- [%6.3f,%6.3f],%6.3f (%d)\n", x1,y1,len, x1,y1,len, col)
  for (i=x1; i<l; i++)
    pixel(scr, i,y1, col)
}

function fillTriangle(scr, x1,y1, x2,y2, x3,y3, col, type, dbg,   i, d1,d2,d3, sx,ex) {
  # y1 < y2 < y3
#if (dbg) printf("(%d,%d), (%d,%d), (%d,%d)\n", x1,y1, x2,y2, x3,y3)

  if (y2 < y1) { i=y1; y1=y2; y2=i; i=x1; x1=x2; x2=i }
  if (y3 < y2) { i=y2; y2=y3; y3=i; i=x2; x2=x3; x3=i }
  if (y3 < y1) { i=y1; y1=y3; y3=i; i=x1; x1=x3; x3=i }
  if (y2 < y1) { i=y1; y1=y2; y2=i; i=x1; x1=x2; x2=i }

#if (dbg) printf("(%d,%d), (%d,%d), (%d,%d)\n", x1,y1, x2,y2, x3,y3)

  # get delta/slopes
  i = y2-y1; d1 = i ? (x2-x1) / i : 0
  i = y3-y2; d2 = i ? (x3-x2) / i : 0
  i = y1-y3; d3 = i ? (x1-x3) / i : 0

#if (dbg) printf("d: %.4f, %.4f, %.4f\n", d1, d2, d3)

  # upper triangle
  for (i=y1; i<y2; i++) {
    sx = x1 + (i-y1) * d3
    ex = x1 + (i-y1) * d1

    if (sx < ex) {
      #if (type == 0) hline(scr, sx,i, (ex-sx)+1 + (sx-int(sx)), col, dbg)
      #if (type == 1) hline(scr, sx,i, (ex-sx)+1, col, dbg)
      hline(scr, sx,i, (ex-sx)+1, col, dbg)
    } else {
      #if (type == 0) hline(scr, ex,i, (sx-ex)+1 + (ex-int(ex)), col, dbg)
      #if (type == 1) hline(scr, ex,i, (sx-ex)+1, col, dbg)
      hline(scr, ex,i, (sx-ex)+1, col, dbg)
    }
  }

  # lower triangle
  for(i=y2; i<=y3; i++) {
    sx = x1 + (i-y1) * d3
    ex = x2 + (i-y2) * d2

    if (sx < ex) {
      #if (type == 0) hline(scr, sx,i, (ex-sx)+1 + (sx-int(sx)), col+1, dbg)
      #if (type == 1) hline(scr, sx,i, (ex-sx)+1, col+1, dbg)
      hline(scr, sx,i, (ex-sx)+1, col+1, dbg)
    } else {
      #if (type == 0) hline(scr, ex,i, (sx-ex)+1 + (ex-int(ex)), col+1, dbg)
      #if (type == 1) hline(scr, ex,i, (sx-ex)+1, col+1, dbg)
      hline(scr, ex,i, (sx-ex)+1, col+1, dbg)
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
  init(scr, 85,80)
  cursor("off")

  #fillTriangle(scr, 5,15, 40,5, 15,35, color["red"])
  #fillTriangle(scr, 15,35, 40,5, 5,15, color["red"])

  for (i=0; i<10000; i++) {
#    triangle(scr,     15,35,  5,15, 40, 5, color["white"])
#    triangle(scr,     55,35, 45,15, 80, 5, color["white"])
#    fillTriangle(scr, 15,35,  5,15, 40, 5, color["red"], 0, 0)
    fillTriangle(scr, 55,35, 45,15, 80, 5, color["yellow"], 1, 0)

#    fillTriangle(scr, 15,75,  5,55, 40,45, color["red"], 0, 0)
#    fillTriangle(scr, 55,75, 45,55, 80,45, color["yellow"], 1, 0)
#    triangle(scr,     15,75,  5,55, 40,45, color["white"])
#    triangle(scr,     55,75, 45,55, 80,45, color["white"])
  }
  draw(scr, 80,2)

  cursor("on")
}
