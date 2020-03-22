#!/usr/bin/env bash

meshtool="../../meshtool.awk"

## position meshes on X axis
"$meshtool" -v x=-90 "t.mesh" > "/tmp/t.mesh"
"$meshtool" -v x=-30 "r.mesh" > "/tmp/r.mesh"
"$meshtool" -v x=+30 "u.mesh" > "/tmp/u.mesh"
"$meshtool" -v x=+90 "e.mesh" > "/tmp/e.mesh"

## intermediate merge
"$meshtool" "/tmp/t.mesh" "/tmp/r.mesh" > "/tmp/tr.mesh"
"$meshtool" "/tmp/u.mesh" "/tmp/e.mesh" > "/tmp/ue.mesh"

## final merge
"$meshtool" "/tmp/tr.mesh" "/tmp/ue.mesh" > "/tmp/true.mesh"

## cleanup
rm /tmp/{t,r,u,e,tr,ue}.mesh

