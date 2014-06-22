################################# RTL compiler Synthesis Script ########################################
##                                                                                                    ##
## This script should be placed in the following directory : $ROOT_DIR/scripts/backend/synth where    ##
## $ROOT is the project root  directory                                                               ##
## The directory should also have the following files : synth_param.xls, synth_param_parse.pl,        ##
## synth.scr, setup_tsmc.cshrc                                                                        ##
## To run, fill the excel sheet synth_param.xls with the corresponding data, then run the perl        ##
## script synth_param_parse.pl									      ##
##												      ##
## The RTL list files should be placed in $ROOT_DIR/backend/synth/$TOP_LEVEL_NAME/		      ##
########################################################################################################
# Defines Environment Variables for Digital Design


echo
echo ############################################
echo # DEFINING Environment variables
echo ############################################
echo
#Defining user-specific environment variables

#End of defining user-specific environment variables

echo
echo ############################################
echo # DEFINING Variables for STD Cell Library
echo ############################################
echo

#Defining standard cell library search path
set_attribute lib_search_path /tools/PDK/tsmc/CL018G/std/arm/2004q3v1/synopsys/
#Defining standard cell libraries used
set ENS_STD_TIMING_TYP                /tools/PDK/tsmc/CL018G/std/arm/2004q3v1/synopsys/typical.lib
set ENS_STD_TIMING_SLOW               /tools/PDK/tsmc/CL018G/std/arm/2004q3v1/synopsys/slow.lib
set ENS_STD_TIMING_FAST               /tools/PDK/tsmc/CL018G/std/arm/2004q3v1/synopsys/fast.lib
#End of defining variables for STD Cell Library

#Defining project root directory
set ROOT_DIR /scratch3/aelhosiny/masters/ece612_project/scripts/synthesis
#End of defining project root directory

#Defining design library and package if exist
#End of defining design library and package

#Defining design blackboxes if exist
#End of defining design blackboxes if exist
#Defining LEF files if exist
#End of defining LEF files





#Specify the default language version to read HDL designs using the following attribute:
set_attribute hdl_language verilog
#The directories in the path are searched for HDL files when you issue a read_hdl command
#script path : project/scripts/backend/synth
set_attribute hdl_search_path /scratch3/aelhosiny/masters/ece612_project/scripts/synthesis
set_attribute information_level 4
            
                 
echo
echo ############################################
echo # DEFINING Top-level name
echo ############################################
echo

set DESIGN multiplier_top

#End of defining top-level name                 


echo
echo ############################################
echo # DEFINING Synthesis directory
echo ############################################
echo

set SYNTH_DIR ../../synth
set_attribute command_log  $SYNTH_DIR/logs/rc_cmd

echo
echo ############################################
echo # Sourcing Automatic Tie insertion script
echo ############################################
echo
source /tools/CADENCE/RC/etc/synth/ae_utils/toolbox/insert_tiehilo_cells.tcl


echo
echo ############################################
echo # DEFINING LIRARY AND ITS CELLS USAGE 
echo ############################################
echo
#specify the target technology library for synthesis using the library attribute
set_attribute library $ENS_STD_TIMING_SLOW 
#end of specifying the target technology library

echo
echo ############################################
echo # DEFINING LEF AND Interconnects mode 
echo ############################################
echo
#Defining LEF library to use
#End of defining LEF library to use

#RTL Compiler has two modes: wireload and ple. These modes are set using the
#interconnect_mode attribute. The default mode is wireload In wireload mode, you use
#wire-load models to drive synthesis. In ple mode, you use Physical Layout Estimators (PLE)
#to drive synthesis. PLE is the process of using physical information, such as LEF libraries, to
#provide better closure with back-end tools
set_attribute interconnect_mode ple



echo
echo ############################################
echo # DEFINING CELLS that shall not be used 
echo ############################################
echo
#avoid using the following cells during synthesis
#set_attribute avoid true { scancell*  delaycell* }

echo
echo ############################################
echo # Synthesis settings
echo ############################################
echo
#generate error on blackbox
set_attribute hdl_error_on_blackbox true
#end of generate error on blackbox
#generate error on latch
set_attribute hdl_error_on_latch false
#set_attribute boundary_opto false [find /* -subdesign *]
#set_attribute delete_unloaded_seqs false [ /]
#set_attribute endpoint_slack_opto true /

echo
echo ############################################
echo # Clock Gating  settings
echo ############################################
echo
#enable clock gating
set_attr lp_insert_clock_gating false /
#set_att lp_clock_gating_test_signal  /de*/design
#set_attribute lp_clock_gating_exceptions_aware true

#by default RTL Compiler tries to fix all DRC errors, but not at the expense of timing
echo # Giving higher priority to DRC (e.g max transition)
set_attribute drc_first  true

#respect preserve attributes (keep assigns define with preserve attributes)
echo # avoid editing preserved objects
#set_attribute ui_respects_preserve true

echo
echo ############################################
echo # READING RTL CODE 
echo ############################################
echo
#Reading the RTL list files and concatenating them in a single variable
set rtl_list_vhdl [exec cat ./vhdl_src.f]
#Compiling design package into design library if exists
#Reading RTL code
read_hdl -vhdl   $rtl_list_vhdl
#end of reading RTL code
echo
echo ############################################
echo # Elaborating Design
echo ############################################
echo

elaborate ${DESIGN}
#--------------------------------------------------------------------------
#check_syntax and send output to checkdesign report
#--------------------------------------------------------------------------
check_design ${DESIGN}
check_design ${DESIGN} -all > $SYNTH_DIR/rpt/checkdesign.rpt

echo
echo ############################################
echo # Clock Gating  settings
echo ############################################
echo
set_attribute lp_clock_gating_style latch ${DESIGN}
set_attribute lp_clock_gating_add_reset false ${DESIGN}
#set_attribute lp_clock_gating_cell [find / -libcell cklhqd1] ${DESIGN}

echo
echo ############################################
echo # Maximum leakage constraint (unit: nW)
echo ############################################
echo
#--------------------------------------------------------------------------
#The max_leakage_power attribute specifies the maximum leakage-power constraint of the
#design. When the leakage power constraint is set, RTL Compiler performs timing and leakage
#power optimization simultaneously during mapping and incremental optimization.
#--------------------------------------------------------------------------
set_attribute max_leakage_power 50000 designs\/${DESIGN}


echo
echo ############################################
echo # clock definitions   
echo ############################################
echo
#rm [find / -clock clock_name]

#### Time unit : ps
#Define clock periods, each define corresponds to a clock domain
define_clock -period 5550 -domain clk_dom -name clk -design ${DESIGN} [find / -port clk]
#DC command used to  tell synthesizer to not optimize the clock tree. This is best done during placement & routing when you actually know the physical locations of the design.
dc::set_dont_touch_network   [find /des* -clock * ]

echo
echo ############################################
echo # clock uncertainity constraints 
echo ############################################
echo

#Constraining negative clocks uncertainity (the maximum negative skew for {rising falling} edge)
set_attribute clock_setup_uncertainty {50 50} [find /* -clock clk]
#Constraining positive clocks uncertainity (the maximum positive skew for {rising falling} edge)
set_attribute clock_hold_uncertainty {5 5} [find /* -clock clk]
#end of clock uncertainty constraints


echo
echo ############################################
echo # Transitions and Capacitances constraints 
echo ############################################
echo

## time unit ps  
set_attribute max_transition 1000 ${DESIGN}
set_attribute min_transition 5 ${DESIGN}

set_attribute max_transition 500 [find /* -port ports_out/* ]

#cap is in fF
#To specify a maximum capacitance limit for all input ports
set_attribute max_capacitance 50 [find /* -port ports_in/* ]
#To specify a maximum fanout limit for all design 
set_attribute max_fanout 20 ${DESIGN}

echo
echo ############################################
echo # False paths (if applicable)
echo ############################################
echo
#define false paths on clock domain crossing signals to avoid showing timing violations on them
#By default, any signal crossing 2 different domains defined in the clocks constraints will be false_path



#End of false path definitions

echo
echo ############################################
echo #   OUTPUT constraints 
echo ############################################
echo
#default load units for DC are in pF, set output loads to 100 fF
dc::set_load 0.1 [dc::all_outputs] 

echo
echo ############################################
echo #   Input and Output delays
echo ############################################
echo



#End of input and output delays

echo
echo #############################################
echo # CONDITIONING
echo #############################################
echo
#dc::remove_unconnected_ports  find ( -hierarchy cell, * )


echo
echo #############################################
echo # CHECKING BERORE synthesis 
echo #############################################
echo

check_design ${DESIGN} -all > $SYNTH_DIR/rpt/sv_checkdesign_before_syn.rc

#Use the -lint option to generate timing reports at different stages of synthesis. This option
#provides a list of possible timing problems due to over constraining the design or incomplete
#timing constraints, such as not defining all multicycle or false paths
report timing -lint -verbose > $SYNTH_DIR/rpt/timing_lint_before_syn.rc
#report clock_gating
report clock_gating -preview -gated_ff -clock [find /* -clock clk ]  > $SYNTH_DIR/rpt/clock_gated.rpt
#disable using scan flops (that start with SDF in std_cell library)
#set_attribute avoid true  SDF*

#DFT marker1
#end of DFT marker1
echo
echo #############################################
echo # synthesize 
echo #############################################
#The synthesize -to_generic command performs RTL optimization on your design.
synthesize -to_generic -csa_effort high -effort high
#DFT marker2
#end of DFT marker2


echo #############################################
echo # Post synthesis editing/optimization
echo #############################################
echo #############################################
echo # flattening sub-modules units (for better optimization)
echo #############################################

#delete_unloaded_undriven 

# Removing assignments as Some place and route tools cannot recognize assign statements. For example, the
#generated gate-level netlist could contain assign
set_attribute remove_assigns true
#DFT marker3
#end of DFT marker3
echo #############################################
echo # Incremental synthesis 
echo #############################################
#synthesize to library gates with incremental optimizations and high effort (aggressive redundancy identification and removal)
synthesize -to_mapped -incremental -effort high


#DFT marker4
#end of DFT marker4

echo
echo #############################################
echo # Clock gating declone and share
echo #############################################
echo
#end of Clock gating declone and share



echo
echo ############################################################
echo # Adding any needed post-syntheis design specific constraint
echo # to be included in the sdc file
echo ###########################################################
echo







echo
echo #############################################
echo ## Modify Naming scheme in netlist
echo #############################################
echo
#Specifying naming scheme for the generated netlist (allowed characters, restricted characters not to be used as first letters  and their replacements) , apply this on net names and instance names
change_names -allowed ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789[]_ -net -instance -first_restricted "\\" -replace_str "_"
#Specifying maximum length of design and subdesign for instance names
change_names -instance -design -subdesign -max_length 50

echo
echo #############################################
echo # WRITING SDF
echo #############################################
echo
#Writing standard delay format to be used for post-synthesis simulation
#-edges check_edge :Keeps edge specifiers on timing check arcs but does not add edge specifiers on combinational arcs
#-nonegchecks :  Converts all negative timing check values to 0.0
#-nosplit_timing_check : only maximum delay values are used
#-no_empty_cells : Suppresses writing out empty cell descriptions
#-interconn interconnect : Writes out the net delays using the INTERCONNECT construct.
write_sdf -version 2.1 -edges check_edge -nonegchecks -nosplit_timing_check -no_empty_cells -interconn interconnect > $SYNTH_DIR/gates/${DESIGN}.sdf
#Writing standard delay format without interconnect
write_sdf -version 2.1 -edges check_edge -nonegchecks -nosplit_timing_check > $SYNTH_DIR/gates/${DESIGN}_no_interconnect.sdf


echo
echo #############################################
echo # Automatic insertion of tie cells
echo #############################################
echo
#Tie all 1'b0 to tie_lo cell, all 1'b1 to tie_hi cell
insert_tiehilo_cells /designs/${DESIGN}/ -all -verbose -maxfanout 3

echo
echo #############################################
echo # WRITING NETLIST
echo #############################################
echo
#Write the gate level netlist
write_hdl ${DESIGN} > $SYNTH_DIR/gates/${DESIGN}.vg
#Write script with all attributes set
write_script > $SYNTH_DIR/gates/${DESIGN}.stag
#Write design constraints
write_sdc > $SYNTH_DIR/gates/${DESIGN}.sdc
#DFT marker5
#end of DFT marker5
echo
echo #############################################
echo ## reports
echo #############################################
echo
#report net_cap_calculation [dc::all_inputs] >  $SYNTH_DIR/rpt/${DESIGN}.input_caps.rpt
#report net_res_calculation [dc::all_outputs] >  $SYNTH_DIR/rpt/${DESIGN}.output_res.rpt
#report port -driver  [dc::all_outputs] > $SYNTH_DIR/rpt/${DESIGN}.output_drivers.rpt
#---------------------------------------------------------------------------------------
#Generates a set of load values, which were obtained from the physical layout estimator (PLE)
#or wire-load model, for all the nets in the specified design.
write_set_load ${DESIGN} > $SYNTH_DIR/gates/${DESIGN}_set_load.sdc
#report worst 100 timing paths with heirarchichal pin names
report timing -worst 300 -full_pin_names > $SYNTH_DIR/rpt/${DESIGN}.timing.rpt
#Reports the technology library cells that were implemented, their area, can add power with -power option
report gates > $SYNTH_DIR/rpt/${DESIGN}.gates.rpt
#Reports the total count of cells mapped against the hierarchical blocks in the current design,
#the wireload model adopted for each of the blocks, and the combined cell area in each of the
#blocks and the top level design (hierarchical breakup).
report area > $SYNTH_DIR/rpt/${DESIGN}.area.rpt
#report leakage and dynamic power for SLOW corner (least power case)
report power > $SYNTH_DIR/rpt/${DESIGN}.power_wc.rpt
#abbreviated timing report with (possible timing problems, ports with no external delays $SYNTH_DIRetc)
report timing -lint > $SYNTH_DIR/rpt/${DESIGN}.timing2.rpt
#Reports the critical path slack, total negative slack (TNS), number of gates on the critical path,
#and number of violating paths for each cost group. It also gives the instance count, total area
#(net and cell area), cell area, leakage power, dynamic power, runtime, and host name information.
report qor -levels_of_logic > $SYNTH_DIR/rpt/${DESIGN}.qor.rpt

#report timing -worst 100 -exceptions [find / -exception post_filt_multi_*] > $SYNTH_DIR/rpt/${DESIGN}.timing_multi_cycle.rpt

#Generates a report on the generated clocks/clocks of the current design
report clocks -generated  > $SYNTH_DIR/rpt/${DESIGN}.clock_gen.rpt
report clocks  > $SYNTH_DIR/rpt/${DESIGN}.clock.rpt
#Reports any design rule violations
report design_rules
report design_rules  >  $SYNTH_DIR/rpt/drc.rpt
#Total negative slack
#get_attribute tns
#get_attribute tns    >  $SYNTH_DIR/rpt/tns.rpt
get_attribute max_trans_cost ${DESIGN}
#get_attributes max_trans_cost ${DESIGN} >$SYNTH_DIR/rpt/transitions.rpt
#

#report timing -num_paths 10
#DFT marker6
#end of DFT marker6

##### reporting specific delay paths in the design if needed
#report timing -from   dmac_u1/OTPADRSDEL/AI[0]  -to  dmac_u1/OTPADRSDEL/AY[0]


#reporting maximum power in fast corner (highest power)
#note that in this technology worst case power is obtained in fast corner. Other technologies provides a ml corner for maximum leakage
#set_attribute library $ENS_STD_TIMING_FAST_m40
 
echo
echo #############################################
echo # Generating Reports and SDF's for other corners
echo #############################################
echo



#Setting library to ENS_STD_TIMING_TYP
set_attribute library $ENS_STD_TIMING_TYP
#Reporting power for ENS_STD_TIMING_TYP
report power > $SYNTH_DIR/rpt/${DESIGN}.power_ENS_STD_TIMING_TYP.rpt
#Reporting timing for ENS_STD_TIMING_TYP
report timing > $SYNTH_DIR/rpt/${DESIGN}.timing_ENS_STD_TIMING_TYP.rpt
echo
echo #############################################
echo # WRITING SDF for ENS_STD_TIMING_TYP
echo #############################################
echo

write_sdf -version 2.1 -edges check_edge -nonegchecks -nosplit_timing_check -no_empty_cells -interconn interconnect > $SYNTH_DIR/gates/${DESIGN}.ENS_STD_TIMING_TYP.sdf

write_sdf -version 2.1 -edges check_edge -nonegchecks -nosplit_timing_check > $SYNTH_DIR/gates/${DESIGN}_no_interconnect.ENS_STD_TIMING_TYP.sdf



#Setting library to ENS_STD_TIMING_SLOW
set_attribute library $ENS_STD_TIMING_SLOW
#Reporting power for ENS_STD_TIMING_SLOW
report power > $SYNTH_DIR/rpt/${DESIGN}.power_ENS_STD_TIMING_SLOW.rpt
#Reporting timing for ENS_STD_TIMING_SLOW
report timing > $SYNTH_DIR/rpt/${DESIGN}.timing_ENS_STD_TIMING_SLOW.rpt
echo
echo #############################################
echo # WRITING SDF for ENS_STD_TIMING_SLOW
echo #############################################
echo

write_sdf -version 2.1 -edges check_edge -nonegchecks -nosplit_timing_check -no_empty_cells -interconn interconnect > $SYNTH_DIR/gates/${DESIGN}.ENS_STD_TIMING_SLOW.sdf

write_sdf -version 2.1 -edges check_edge -nonegchecks -nosplit_timing_check > $SYNTH_DIR/gates/${DESIGN}_no_interconnect.ENS_STD_TIMING_SLOW.sdf



#Setting library to ENS_STD_TIMING_FAST
set_attribute library $ENS_STD_TIMING_FAST
#Reporting power for ENS_STD_TIMING_FAST
report power > $SYNTH_DIR/rpt/${DESIGN}.power_ENS_STD_TIMING_FAST.rpt
#Reporting timing for ENS_STD_TIMING_FAST
report timing > $SYNTH_DIR/rpt/${DESIGN}.timing_ENS_STD_TIMING_FAST.rpt
echo
echo #############################################
echo # WRITING SDF for ENS_STD_TIMING_FAST
echo #############################################
echo

write_sdf -version 2.1 -edges check_edge -nonegchecks -nosplit_timing_check -no_empty_cells -interconn interconnect > $SYNTH_DIR/gates/${DESIGN}.ENS_STD_TIMING_FAST.sdf

write_sdf -version 2.1 -edges check_edge -nonegchecks -nosplit_timing_check > $SYNTH_DIR/gates/${DESIGN}_no_interconnect.ENS_STD_TIMING_FAST.sdf

#end of Generating Reports and SDF's for other corners

#restoring back the default corner before saving database
set_attribute library $ENS_STD_TIMING_SLOW 
#end of restoring back the default corner before saving database
echo
echo #############################################
echo # WRITING SDF for default case
echo #############################################
echo

write_sdf -version 2.1 -edges check_edge -nonegchecks -nosplit_timing_check -no_empty_cells -interconn interconnect > $SYNTH_DIR/gates/${DESIGN}.ENS_STD_TIMING_SLOW.sdf

write_sdf -version 2.1 -edges check_edge -nonegchecks -nosplit_timing_check > $SYNTH_DIR/gates/${DESIGN}_no_interconnect.ENS_STD_TIMING_SLOW.sdf

#end of writing SDF for default case

#report summary for area, timing critical paths, slack, DRC
report summary

echo ############################################################
echo # Writing Encounter configuration files
echo ############################################################
echo
#Write files required by Encounter (netlist,configuration file, scripts ..etc)
write_encounter design  -basename $SYNTH_DIR/enc/${DESIGN} -gzip_files ${DESIGN}
#    [-reference_config_file config_file] 
#    [-ignore_scan_chains] [-ignore_msv] 
 #   [-floorplan string] [-lef lef_files] [design] 

echo
echo ############################################################
echo # Writing RC Database
echo ############################################################
echo

#write_design [-basename string] [-gzip_files] [-encounter] [design] 
#Generates all the files needed to reload the session in RTL Compiler (for example, .g, .v.
#and .tcl files).
write_design -basename $SYNTH_DIR/RC/${DESIGN} -gzip_files ${DESIGN}


echo
echo ############################################################
echo # DONE #
echo ############################################################
echo

echo
echo ############################################################
echo # Any user-defined Remarks or notes                        #
echo ############################################################
echo
#exit
