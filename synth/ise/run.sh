#!/bin/sh


toplevel=$1
export toplevel=$toplevel

cdir=`pwd`
ROOT_DIR=`echo $cdir | sed 's/synth\/ise//g'`
export ROOT_DIR=$ROOT_DIR

listfile=vhdl_src.f
export listfile=$listfile

xst -ifn synth.xst -ofn $toplevel".srp" 

ngdbuild -uc multiplier $toplevel".ngc" 

map -p xc7a100t-csg324-3 -w -logic_opt on -ol high -t 1 -xt 0 -r 4 -mt on -lc off -o $toplevel"_map.ncd" $toplevel".ngd" $toplevel".pcf" -timing
par -mt 4 -ol high $toplevel"_map.ncd" $toplevel".ncd" $toplevel".pcf" -w
xpwr -ol std $toplevel".ncd" $toplevel".pcf" -o $toplevel".pwr"
