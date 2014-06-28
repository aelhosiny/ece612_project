onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group TB -radix unsigned -childformat {{/cpa_tb/opa(15) -radix unsigned} {/cpa_tb/opa(14) -radix unsigned} {/cpa_tb/opa(13) -radix unsigned} {/cpa_tb/opa(12) -radix unsigned} {/cpa_tb/opa(11) -radix unsigned} {/cpa_tb/opa(10) -radix unsigned} {/cpa_tb/opa(9) -radix unsigned} {/cpa_tb/opa(8) -radix unsigned} {/cpa_tb/opa(7) -radix unsigned} {/cpa_tb/opa(6) -radix unsigned} {/cpa_tb/opa(5) -radix unsigned} {/cpa_tb/opa(4) -radix unsigned} {/cpa_tb/opa(3) -radix unsigned} {/cpa_tb/opa(2) -radix unsigned} {/cpa_tb/opa(1) -radix unsigned} {/cpa_tb/opa(0) -radix unsigned}} -subitemconfig {/cpa_tb/opa(15) {-radix unsigned} /cpa_tb/opa(14) {-radix unsigned} /cpa_tb/opa(13) {-radix unsigned} /cpa_tb/opa(12) {-radix unsigned} /cpa_tb/opa(11) {-radix unsigned} /cpa_tb/opa(10) {-radix unsigned} /cpa_tb/opa(9) {-radix unsigned} /cpa_tb/opa(8) {-radix unsigned} /cpa_tb/opa(7) {-radix unsigned} /cpa_tb/opa(6) {-radix unsigned} /cpa_tb/opa(5) {-radix unsigned} /cpa_tb/opa(4) {-radix unsigned} /cpa_tb/opa(3) {-radix unsigned} /cpa_tb/opa(2) {-radix unsigned} /cpa_tb/opa(1) {-radix unsigned} /cpa_tb/opa(0) {-radix unsigned}} /cpa_tb/opa
add wave -noupdate -expand -group TB -radix unsigned /cpa_tb/opb
add wave -noupdate -expand -group TB -radix unsigned /cpa_tb/result_ref_s
add wave -noupdate -expand -group TB -radix unsigned /cpa_tb/result
add wave -noupdate -expand -group TB /cpa_tb/feed_s
add wave -noupdate -expand -group TB /cpa_tb/rst_n
add wave -noupdate -expand -group TB /cpa_tb/sim_end_s
add wave -noupdate -expand -group TB /cpa_tb/sys_clk
add wave -noupdate -expand -group TB /cpa_tb/error_s
add wave -noupdate -expand -group TB /cpa_tb/check_acc
add wave -noupdate -expand -group DUT -radix hexadecimal /cpa_tb/cpa_1/opa
add wave -noupdate -expand -group DUT -radix hexadecimal /cpa_tb/cpa_1/opb
add wave -noupdate -expand -group DUT -radix hexadecimal /cpa_tb/cpa_1/result
add wave -noupdate -expand -group DUT /cpa_tb/cpa_1/p_vector_s
add wave -noupdate -expand -group DUT /cpa_tb/cpa_1/g_vector_s
add wave -noupdate -expand -group DUT /cpa_tb/cpa_1/p_a
add wave -noupdate -expand -group DUT /cpa_tb/cpa_1/g_a
add wave -noupdate -expand -group DUT /cpa_tb/cpa_1/c_vector_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {116 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 214
configure wave -valuecolwidth 145
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {210 ns}
