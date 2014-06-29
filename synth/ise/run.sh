#!/bin/sh


toplevel=$1
export toplevel=$toplevel

cdir=`pwd`
ROOT_DIR=`echo $cdir | sed 's/synth\/ise//g'`
export ROOT_DIR=$ROOT_DIR

listfile=vhdl_src.f
export listfile=$listfile

xst -ifn synth.xst
