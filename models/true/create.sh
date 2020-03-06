#!/usr/bin/env bash

## position meshes on X axis
./move.awk -v x=-90 t.mesh > /tmp/t.mesh
./move.awk -v x=-30 r.mesh > /tmp/r.mesh
./move.awk -v x=+30 u.mesh > /tmp/u.mesh
./move.awk -v x=+90 e.mesh > /tmp/e.mesh

## intermediate merge
./merge.awk /tmp/t.mesh /tmp/r.mesh > /tmp/tr.mesh
./merge.awk /tmp/u.mesh /tmp/e.mesh > /tmp/ue.mesh

## final merge
./merge.awk /tmp/tr.mesh /tmp/ue.mesh > /tmp/true.mesh

## cleanup
rm /tmp/{t,r,u,e,tr,ue}.mesh

