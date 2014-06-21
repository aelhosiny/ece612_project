onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group TB /multiplier_top_tb/multiplicand
add wave -noupdate -group TB /multiplier_top_tb/multiplier
add wave -noupdate -group TB /multiplier_top_tb/result
add wave -noupdate -group TB /multiplier_top_tb/feed_s
add wave -noupdate -group TB /multiplier_top_tb/rst_n
add wave -noupdate -group TB /multiplier_top_tb/sim_end_s
add wave -noupdate -group TB /multiplier_top_tb/sys_clk
add wave -noupdate -group DUT /multiplier_top_tb/multiplier_top_1/multiplicand
add wave -noupdate -group DUT /multiplier_top_tb/multiplier_top_1/multiplier
add wave -noupdate -group DUT /multiplier_top_tb/multiplier_top_1/result
add wave -noupdate -group DUT /multiplier_top_tb/multiplier_top_1/adder_in1
add wave -noupdate -group DUT /multiplier_top_tb/multiplier_top_1/adder_in2
add wave -noupdate -group pp_gen /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/multiplicand
add wave -noupdate -group pp_gen /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/multiplier
add wave -noupdate -group pp_gen /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/addin_1
add wave -noupdate -group pp_gen /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/addin_2
add wave -noupdate -group pp_gen /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/sdn_s
add wave -noupdate -group pp_gen /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/multiplicand_s
add wave -noupdate -group pp_gen /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/multiplier_s
add wave -noupdate -group pp_gen /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_2y
add wave -noupdate -group pp_gen /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_y
add wave -noupdate -group pp_gen /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_negy
add wave -noupdate -group pp_gen /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_neg2y
add wave -noupdate -group pp_gen /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_intrm_s
add wave -noupdate -group pp_gen -expand /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_all_s
add wave -noupdate -group pp_gen /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/sign_vec_s
add wave -noupdate /multiplier_top_tb/result_s
add wave -noupdate /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/result_test
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp1
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp2
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp3
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp4
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp5
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp6
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp7
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp8
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp9
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp10
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp11
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp12
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp13
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp14
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp15
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp16
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp17
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/addin_1
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/addin_2
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp_all_s
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/pp_all_init
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage1_sum
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage1_carry
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage1_fix
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage2_sum
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage2_carry
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage2_fix
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage3_sum
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage3_carry
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage3_fix
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage4_sum
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage4_carry
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage4_fix
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage5_sum
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage5_carry
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage5_fix
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage6_sum
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage6_carry
add wave -noupdate -expand -group tree /multiplier_top_tb/multiplier_top_1/pp_gen_rdcn_1/pp_rdcn_1/stage6_fix
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {939 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 214
configure wave -valuecolwidth 100
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
WaveRestoreZoom {100 ns} {256 ns}
