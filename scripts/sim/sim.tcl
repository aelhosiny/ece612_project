set scr_dir [exec pwd]

set ROOT_DIR [regsub /scripts/sim $scr_dir ""]

set env(ROOT_DIR) $ROOT_DIR

set list_file $ROOT_DIR/source/tb/vhdl_src.f
set simdir $ROOT_DIR/sim
set INPATH $ROOT_DIR/source/tb/tc
set env(INPATH) $INPATH
set OUTPATH $simdir
set env(OUTPATH) $OUTPATH
set tcdir $INPATH


if { [file exists $simdir] == 0} {
	puts "==== create compile directory ===="
	exec mkdir -p $simdir
} else {
	puts "==== cleanup simulation directory ===="
	exec rm -fr $simdir
	exec mkdir -p $simdir
}

vlib $simdir/work
vmap work $simdir/work


vcom -f $list_file

vsim -t ns multiplier_top_tb
do $tcdir/wave.do
do $tcdir/tc_cfg.do