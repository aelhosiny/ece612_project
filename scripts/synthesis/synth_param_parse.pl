#!/usr/bin/perl
################################# Synthesis Parameters Parsing Script ########################################
##                                                                                                          ##
##  This script is used to parse synthesis parameters from excel sheet synth_param.xls and modify the 	    ##
##  RTL compiler Tcl script accordingly. It also sources the tools and sources the environment variables    ##
##  used in the synthesis script. Finally it runs the generated script on RC				    ##
##													    ##
##  This script should be placed in the following directory : $ROOT_DIR/scripts/backend/synth where    	    ##
##  $ROOT is the project root  directory  								    ##
## 													    ##
##  The following files should be present in same directory :						    ##
##  1-synth_param.xls											    ##
##  2-synth_scrpt.tcl											    ##
##  3-synth.scr												    ##
##  4-setup_tsmc.cshrc											    ##
##													    ##
##  The script is run as follows : perl synth_param_parse.pl <license>					    ##
##  where <license> could be either                                                                         ##
##  5280@10.8.0.23                                                                                          ##
##  (5280@ejustece.noip.me)            									    ##
##  OR													    ##
##  44556@rfx.labs.aucegypt.edu										    ##
##													    ##
##############################################################################################################

use strict;
use warnings;
use Data::Dumper; 
use Spreadsheet::ParseExcel;
use Cwd;
use File::Copy;
my $license=$ARGV[0];
my $workbook =Spreadsheet::ParseExcel::Workbook->Parse("./synth_param.xls");
#Opening Worksheets
my $std_cell_library=$workbook->{Worksheet}[0];
my $parameters_sheet=$workbook->{Worksheet}[1];
my $clock_sheet=$workbook->{Worksheet}[2];
my $dft_sheet=$workbook->{Worksheet}[3];
my $io_delays_sheet=$workbook->{Worksheet}[4];
my $false_paths_sheet=$workbook->{Worksheet}[5];
my $black_box_sheet=$workbook->{Worksheet}[6];
my $env_vars_sheet=$workbook->{Worksheet}[7];

my $hdl_search_path;
my $ROOT_DIR=lc getcwd;
my $ROOT_DIR2=$ROOT_DIR;
   $ROOT_DIR2=~s/(.*)\/scripts\/backend.*/$1/;

if ($ROOT_DIR=~".*/scripts/backend/.*") #Default directory structure
{
    $hdl_search_path="$ROOT_DIR2/source/rtl";
}
else                                    #all(rtl,scripts,reports) in 1 directory
{
    $hdl_search_path=$ROOT_DIR2
}

$ROOT_DIR=$ROOT_DIR2;


#Opening script template to read from and the generated script template to write to

open(SYNTH_SCRIPT,"<./synth_scrpt_template.tcl") || die ("Could not open synth_scrpt.tcl file for reading\n");

################################################################################################
#Reading the script into 1 scalar
################################################################################################

my @whole_script = <SYNTH_SCRIPT>;
my $whole_script = join("",@whole_script);

################################################################################################
#User-specified environment variables
################################################################################################
my @arr_env_vars;
foreach my $row('1' .. $env_vars_sheet->{MaxRow})
{   
    if (defined($env_vars_sheet->Cell($row,0)))
    {
	my $indent=16-length($env_vars_sheet->{Cells}[$row][0]->Value);
	push(@arr_env_vars, "set ".$env_vars_sheet->{Cells}[$row][0]->Value." "x$indent.$env_vars_sheet->{Cells}[$row][1]->Value );
    }
}
my $arr_env_vars=join("\n",@arr_env_vars);

$whole_script=~s/(#Defining user-specific environment variables).*(#End of defining user-specific environment variables)/$1\n$arr_env_vars\n$2/s;

################################################################################################
#Modifying the project root directory
################################################################################################
$whole_script=~s/(set ROOT_DIR).*/$1 $ROOT_DIR/;

################################################################################################
#Modifying the HDL search path
################################################################################################
$whole_script=~s/(set_attribute hdl_search_path).*/$1 $hdl_search_path/;

################################################################################################
#Modifying the standard_cell_library Tcl variables
################################################################################################

my $std_cell_lib_search_path=$parameters_sheet->{Cells}[7][1]->Value;
my $blackbox_enable=$parameters_sheet->{Cells}[8][1]->Value if(defined($parameters_sheet->Cell(8,1)));

my $default_library;
$whole_script=~s/(#Defining standard cell library search path).*(#Defining standard cell libraries used)/$1\nset_attribute lib_search_path $std_cell_lib_search_path\n$2/s;
my @arr_std_cell;
foreach my $row('1' .. $std_cell_library->{MaxRow})
{   my $indent=34-length($std_cell_library->{Cells}[$row][0]->Value);
    push(@arr_std_cell, "set ".$std_cell_library->{Cells}[$row][0]->Value." "x$indent.$std_cell_library->{Cells}[$row][1]->Value );
    if (defined($std_cell_library->Cell($row,5)) && $std_cell_library->{Cells}[$row][5]->Value eq "yes")
    {
	$default_library=$std_cell_library->{Cells}[$row][0]->Value;
    }
}

my $arr_std_cell=join("\n",@arr_std_cell);
$whole_script=~s/(#Defining standard cell libraries used).*(#End of defining variables for STD Cell Library\n)/$1\n$arr_std_cell\n$2\n/s;
################################################################################################
#Defining design blackboxes
################################################################################################

my @blackbox_arr_set;
my @blackbox_arr;
my @lef_definition;
my $lef_definition;
my @lef_attribute;
my $lef_attribute;
my $use_lef=$parameters_sheet->{Cells}[9][1]->Value if(defined($parameters_sheet->Cell(9,1)));

if ((defined($use_lef) && lc $use_lef eq "yes") || (defined($blackbox_enable) && lc $blackbox_enable eq "yes"))
{
    my $tech_lef=$parameters_sheet->{Cells}[10][1]->Value if(defined($parameters_sheet->Cell(10,1)));
    push(@lef_definition,"set tech_lef $tech_lef");
    push(@lef_attribute,"\$tech_lef");
}

my $cell_lef=$parameters_sheet->{Cells}[11][1]->Value if(defined($parameters_sheet->Cell(11,1)));

if (defined($use_lef) && lc $use_lef eq "yes")
{
    push(@lef_definition,"set cell_lef $cell_lef");
    push(@lef_attribute,"\$cell_lef");
}

if(defined($blackbox_enable) && lc $blackbox_enable eq "yes")
{
    foreach my $row('1' .. $black_box_sheet->{MaxRow})
    {
	my $bb_name=$black_box_sheet->{Cells}[$row][0]->Value;
	my $bb_path=$black_box_sheet->{Cells}[$row][1]->Value;
	my $bb_lef =$black_box_sheet->{Cells}[$row][2]->Value;
	push(@blackbox_arr_set,"set $bb_name $bb_path");
	push(@blackbox_arr,"\$$bb_name");	
	push(@lef_definition,"set $bb_name"."_LEF $bb_lef");
	push(@lef_attribute,"\$$bb_name"."_LEF");
    }

    my $blackbox_arr_set=join("\n",@blackbox_arr_set);
    my $blackbox_arr=join(" ",@blackbox_arr);

    $whole_script=~s/(#Defining design blackboxes if exist\s*\n).*(#End of defining design blackboxes if exist\s*\n)/$1$blackbox_arr_set\n$2/s;
    $whole_script=~s/(#specify the target technology library for synthesis using the library attribute)\s*\n.*(#end of specifying the target technology library)/$1\nset_attribute library "\$$default_library $blackbox_arr"\n$2/s;
    $whole_script=~s/(#restoring back the default corner before saving database).*\n(#end of restoring back the default corner before saving database)/$1\nset_attribute library "\$$default_library $blackbox_arr"\n$2/s;
}
else
{
    $whole_script=~s/(#Defining design blackboxes if exist\s*\n).*(#End of defining design blackboxes if exist\s*\n)/$1$2/s;
    $whole_script=~s/(#specify the target technology library for synthesis using the library attribute)\s*\n.*(#end of specifying the target technology library)/$1\nset_attribute library \$$default_library \n$2/s;
    $whole_script=~s/(#restoring back the default corner before saving database).*\n(#end of restoring back the default corner before saving database)/$1\nset_attribute library \$$default_library \n$2/s;

}
    $lef_definition=join("\n",@lef_definition);
    $lef_attribute=join(" ",@lef_attribute);
if ((defined($use_lef) && lc $use_lef eq "yes") || (defined($blackbox_enable) && lc $blackbox_enable eq "yes"))
{
    $whole_script=~s/(#Defining LEF files if exist\s*\n).*(#End of defining LEF files\s*\n)/$1$lef_definition\n$2/s;
    $whole_script=~s/(#Defining LEF library to use\s*\n).*(#End of defining LEF library to use\s*\n)/$1set_attribute lef_library "$lef_attribute"\n$2/s;
}
else
{
    $whole_script=~s/(#Defining LEF files if exist\s*\n).*(#End of defining LEF files\s*\n)/$1$2/s;
    $whole_script=~s/(#Defining LEF library to use\s*\n).*(#End of defining LEF library to use\s*\n)/$1$2/s;
}

################################################################################################
#Modifying LEF file if exists
################################################################################################

################################################################################################
#Modifying the file defining the design parameters
################################################################################################

my $hdl_language=$parameters_sheet->{Cells}[1][1]->Value;
my $top_level=$parameters_sheet->{Cells}[2][1]->Value;

my $generated_script=$top_level."_synth.tcl";
$whole_script=~s/(echo\s*\necho ############################################\s*\necho # DEFINING Top-level name\s*\necho ############################################\s*\necho\s*\n).*(#End of defining top-level name\s*\n)/$1set DESIGN $top_level\n\n$2/s;

my $design_lib=$parameters_sheet->{Cells}[3][1]->Value;
my $design_pkg=$parameters_sheet->{Cells}[4][1]->Value if(defined($parameters_sheet->Cell(4,1)));;
my $clk_gating=$parameters_sheet->{Cells}[5][1]->Value;
my $dft_enable=$parameters_sheet->{Cells}[6][1]->Value if(defined($parameters_sheet->Cell(6,1)));

my $vhdl_list_file;
my $verilog_list_file;
my $output_dir;


if(defined($parameters_sheet->Cell(12,1)))
{
    $output_dir=$parameters_sheet->{Cells}[12][1]->Value;
}
else
{
    $output_dir="$ROOT_DIR/backend\/synth\/$top_level\/"
}

if(defined($parameters_sheet->Cell(13,1)))
{
    $vhdl_list_file=$parameters_sheet->{Cells}[13][1]->Value;
}
else
{
    $vhdl_list_file="$output_dir/top_vhdl.f"
}

if(defined($parameters_sheet->Cell(14,1)))
{
    $verilog_list_file=$parameters_sheet->{Cells}[14][1]->Value;
}
else
{
    $verilog_list_file="$output_dir/top_v.f"
}


################################################################################################
#Changing the output synthesis directory
################################################################################################
$whole_script=~s/(set SYNTH_DIR).*/$1 $output_dir/;



if(lc $design_lib eq "none")
{
    $whole_script=~s/(#Defining design library and package if exist\s*\n).*(#End of defining design library and package\s*\n)/$1$2\n/;
    $whole_script=~s/(#Compiling design package into design library if exists).*(#Reading RTL code)/$1\n$2/s;

}
else
{
    $whole_script=~s/(#Defining design library and package if exist\s*\n).*(#End of defining design library and package\s*\n)/$1set DESIGN_LIB $design_lib\nset DESIGN_PKG $design_pkg\n$2\n/;
    $whole_script=~s/(#Compiling design package into design library if exists).*(#Reading RTL code)/$1\nread_hdl -vhdl  -library \$DESIGN_LIB \$DESIGN_PKG\n$2/s;
}

if (lc $hdl_language eq "vhdl")
{
    $whole_script=~s/(#Reading the RTL list files and concatenating them in a single variable)\s*\n.*(#Compiling design package into design library if exists)\s*\n/$1\nset rtl_list_vhdl [exec cat $vhdl_list_file]\n$2\n/s;
    $whole_script=~s/(#Reading RTL code)\s*\n.*(#end of reading RTL code)\s*\n/$1\nread_hdl -vhdl   \$rtl_list_vhdl\n$2\n/s;
}
elsif (lc $hdl_language eq "verilog")
{
    $whole_script=~s/(#Reading the RTL list files and concatenating them in a single variable)\s*\n.*(#Compiling design package into design library if exists)\s*\n/$1\nset rtl_list_v [exec cat $verilog_list_file]\n$2\n/s;
    $whole_script=~s/(#Reading RTL code)\s*\n.*(#end of reading RTL code)\s*\n/$1\nread_hdl -v2001   \$rtl_list_v\n$2\n/s;
}
elsif (lc $hdl_language eq "mixed")
{
    $whole_script=~s/(#Reading the RTL list files and concatenating them in a single variable)\s*\n.*(#Compiling design package into design library if exists)\s*\n/$1\nset rtl_list_vhdl [exec cat $vhdl_list_file]\nset rtl_list_v    [exec cat $verilog_list_file]\n$2\n/s;
    $whole_script=~s/(#Reading RTL code)\s*\n.*(#end of reading RTL code)\s*\n/$1\nread_hdl -vhdl   \$rtl_list_vhdl\nread_hdl -v2001   \$rtl_list_v\n$2\n/s;
}

if(lc $clk_gating eq "yes")
{
    $whole_script=~s/set_attribute\s+lp_insert_clock_gating\s+.*/set_attr lp_insert_clock_gating true \//;
    $whole_script=~s/(echo
echo #############################################
echo # Clock gating declone and share
echo #############################################
echo).*(#end of Clock gating declone and share)/$1
#Declone merges clock-gating instances driven by the same inputs
#Share extracts the enable function shared by clock-gating logic and inserts shared clock-gating logic with the common enable sub function as the enable signal

clock_gating declone -hierarchical 
clock_gating share -hierarchical

$2/s;
}
else
{
    $whole_script=~s/set_attribute\s+lp_insert_clock_gating\s+.*/set_attr lp_insert_clock_gating false \//;
    $whole_script=~s/(echo
echo #############################################
echo # Clock gating declone and share
echo #############################################
echo).*(#end of Clock gating declone and share)/$1\n$2/s;
}


if(defined($blackbox_enable) && lc $blackbox_enable eq "yes")
{
    $whole_script=~s/(#generate error on blackbox\s*\n).*(#end of generate error on blackbox\s*\n)/$1$2/s;
}
else
{
    $whole_script=~s/(#generate error on blackbox\s*\n).*(#end of generate error on blackbox\s*\n)/$1set_attribute hdl_error_on_blackbox true\n$2/s;
}


################################################################################################
#Modifying the clock constraints in the synthesis script
#Collecting the clock domains from the spreadsheet
################################################################################################
my @arr_clk;

foreach my $row('1' .. $clock_sheet->{MaxRow})
{
    my $clock_name=$clock_sheet->{Cells}[$row][0]->Value;
    my $clock_domain=$clock_name."_dom";
    my $clock_period=$clock_sheet->{Cells}[$row][1]->Value;
    push(@arr_clk, "define_clock -period ".$clock_period." -domain ".$clock_domain." -name ".$clock_name. " -design \${DESIGN} [find / -port ".$clock_name."]");
}
my $arr_clk=join("\n",@arr_clk);


#Substituting the clocks part with the updated data

$whole_script=~s/(.*#### Time unit : ps\n#Define clock periods, each define corresponds to a clock domain\n).*(#DC command used to  tell synthesizer to not optimize the clock tree. This is best done during placement & routing when you actually know the physical locations of the design.\n.*)/$1$arr_clk\n$2/s;

################################################################################################
#Modifying the clock uncertainities
################################################################################################
my @arr_setup_uncertain;
my @arr_hold_uncertain;

foreach my $row('1' .. $clock_sheet->{MaxRow})
{
    my $clock_name=$clock_sheet->{Cells}[$row][0]->Value;
    my $setup_rising=$clock_sheet->{Cells}[$row][2]->Value;
    my $setup_falling=$clock_sheet->{Cells}[$row][3]->Value;
    my $hold_rising=$clock_sheet->{Cells}[$row][4]->Value;
    my $hold_falling=$clock_sheet->{Cells}[$row][5]->Value;    
    push(@arr_setup_uncertain, "set_attribute clock_setup_uncertainty {$setup_rising $setup_falling} [find /* -clock $clock_name]");
    push(@arr_hold_uncertain, "set_attribute clock_hold_uncertainty {$hold_rising $hold_falling} [find /* -clock $clock_name]");
}
my $arr_setup_uncertain=join("\n",@arr_setup_uncertain);
my $arr_hold_uncertain =join("\n",@arr_hold_uncertain);

$whole_script=~s/(#Constraining negative clocks uncertainity \(the maximum negative skew for {rising falling} edge\)\s*\n).*(#Constraining positive clocks uncertainity \(the maximum positive skew for {rising falling} edge\)\s*\n)/$1$arr_setup_uncertain\n$2\n/s;

$whole_script=~s/(#Constraining positive clocks uncertainity \(the maximum positive skew for {rising falling} edge\))\s*\n.*(#end of clock uncertainty constraints\s*\n)/$1\n$arr_hold_uncertain\n$2\n/s;

################################################################################################
#Modifying the false paths if any
################################################################################################

my @arr_false_paths;
foreach my $row('1' .. $false_paths_sheet->{MaxRow})
{ 
    my $source_signal=$false_paths_sheet->{Cells}[$row][0]->Value if(defined($false_paths_sheet->Cell($row,0)));
    my $source_bus=$false_paths_sheet->{Cells}[$row][1]->Value if(defined($false_paths_sheet->Cell($row,1)));
    my $dest_signal=$false_paths_sheet->{Cells}[$row][2]->Value if(defined($false_paths_sheet->Cell($row,2)));
    my $dest_bus=$false_paths_sheet->{Cells}[$row][3]->Value if(defined($false_paths_sheet->Cell($row,3)));
    
    if(defined($source_signal) && defined($dest_signal))
    {
	if(lc $source_bus eq "single" && lc $dest_bus eq "single")
	{
	    push(@arr_false_paths,"dc::set_false_path -from ".$source_signal." -to ".$dest_signal);
	}
	elsif(lc $source_bus eq "bus" && lc $dest_bus eq "single")
	{
	    push(@arr_false_paths,"dc::set_false_path -from ".$source_signal."[*] -to ".$dest_signal);
	}
	elsif(lc $source_bus eq "single" && lc $dest_bus eq "bus")
	{
	    push(@arr_false_paths,"dc::set_false_path -from ".$source_signal." -to ".$dest_signal."[*]");
	}
	else
	{
	    push(@arr_false_paths,"dc::set_false_path -from ".$source_signal."[*] -to ".$dest_signal."[*]");     
	}
    }
    elsif(defined($source_signal))
    {
	if(lc $source_bus eq "single")
	{
	    push(@arr_false_paths,"dc::set_false_path -from ".$source_signal);  
	}
	else
	{
	    push(@arr_false_paths,"dc::set_false_path -from ".$source_signal."[*]");
	}  
    }
    else #defined($dest_signal)
    {
	if(lc $dest_bus eq "single")
	{
	    push(@arr_false_paths,"dc::set_false_path -to ".$dest_signal);  
	}
	else
	{
	    push(@arr_false_paths,"dc::set_false_path -to ".$dest_signal."[*]");
	}  
    }
}

my $arr_false_paths=join("\n",@arr_false_paths);

$whole_script=~s/(#define false paths on clock domain crossing signals to avoid showing timing violations on them\s*\n#By default, any signal crossing 2 different domains defined in the clocks constraints will be false_path\s*\n).*(#End of false path definitions\s*\n)/$1$arr_false_paths\n\n$2/s;


################################################################################################
#Modifying the Input/Output delays
################################################################################################

my @arr_io_delays;
foreach my $row('1' .. $io_delays_sheet->{MaxRow})
{ my $port_name=$io_delays_sheet->{Cells}[$row][0]->Value;
  #my $port_name="gg";
  my $port_dir=$io_delays_sheet->{Cells}[$row][1]->Value;
  my $port_delay=$io_delays_sheet->{Cells}[$row][2]->Value;
  my $clock_name=$io_delays_sheet->{Cells}[$row][3]->Value;
  my $clock_edge=$io_delays_sheet->{Cells}[$row][4]->Value;
  
  #my $indent=34-length($std_cell_library->{Cells}[$row][0]->Value);
#external_delay -input 300 -edge_fall -clock [find / -clock clock1] [find / -port a*]
  push(@arr_io_delays, "external_delay -".lc $port_dir."put ".$port_delay." -edge_".lc $clock_edge." -clock [find / -clock ".$clock_name."] [find / -port ".lc $port_name."*]");
}  
my $arr_io_delays=join("\n",@arr_io_delays);

$whole_script=~s/(echo\s*\necho ############################################\s*\necho #   Input and Output delays\s*\necho ############################################\s*\necho\s*\n).*(#End of input and output delays)/$1$arr_io_delays\n\n$2/s;



################################################################################################
#Generating Reports and SDF's
################################################################################################
my @arr_reports;
my @arr_reports2;

foreach my $row('1' .. $std_cell_library->{MaxRow})
{   #my $indent=34-length($std_cell_library->{Cells}[$row][0]->Value);
    my $lib_name=$std_cell_library->{Cells}[$row][0]->Value;
    my $report_timing=$std_cell_library->{Cells}[$row][2]->Value if(defined($std_cell_library->Cell($row,2)));
    my $report_power=$std_cell_library->{Cells}[$row][3]->Value if(defined($std_cell_library->Cell($row,3)));
    my $sdf=$std_cell_library->{Cells}[$row][4]->Value if(defined($std_cell_library->Cell($row,4)));
    #print $sdf;
    @arr_reports="";
    if(($sdf && lc $sdf eq "yes") || ($report_power && lc $report_power eq "yes") || ($report_timing && lc $report_timing eq "yes"))
    {
	push(@arr_reports,"\n\n#Setting library to $lib_name\nset_attribute library \$$lib_name\n");
	push(@arr_reports,"#Reporting power for $lib_name\nreport power > \$SYNTH_DIR/rpt/\${DESIGN}.power_$lib_name.rpt\n") if ($report_power && lc $report_power eq "yes");   
	push(@arr_reports,"#Reporting timing for $lib_name\nreport timing > \$SYNTH_DIR/rpt/\${DESIGN}.timing_$lib_name.rpt\n") if ($report_timing && lc $report_timing eq "yes");   
	push(@arr_reports,"echo\necho #############################################\necho # WRITING SDF for $lib_name\necho #############################################\necho\n\nwrite_sdf -version 2.1 -edges check_edge -nonegchecks -nosplit_timing_check -no_empty_cells -interconn interconnect > \$SYNTH_DIR/gates/\${DESIGN}.$lib_name.sdf\n\nwrite_sdf -version 2.1 -edges check_edge -nonegchecks -nosplit_timing_check > \$SYNTH_DIR/gates/\${DESIGN}_no_interconnect.$lib_name.sdf\n") if ($sdf && lc $sdf eq "yes");   

	my $arr_reports=join("",@arr_reports);
	push(@arr_reports2,$arr_reports);
    }
}
my $arr_reports2=join("\n",@arr_reports2);

$whole_script=~s/(echo\s*\necho #############################################\s*\necho # Generating Reports and SDF's for other corners\s*\necho #############################################\necho\s*\n).*(#end of Generating Reports and SDF's for other corners)/$1$arr_reports2\n$2/s;

$whole_script=~s/(echo\s*\necho #############################################\s*\necho # WRITING SDF for default case\s*\necho #############################################\necho\s*\n).*(#end of writing SDF for default case)/$1write_sdf -version 2.1 -edges check_edge -nonegchecks -nosplit_timing_check -no_empty_cells -interconn interconnect > \$SYNTH_DIR\/gates\/\${DESIGN}.$default_library.sdf\n\nwrite_sdf -version 2.1 -edges check_edge -nonegchecks -nosplit_timing_check > \$SYNTH_DIR\/gates\/\${DESIGN}_no_interconnect.$default_library.sdf\n\n$2/s;


################################################################################################
#Adding or removing DFT depending on DFT enable
################################################################################################
if (defined($dft_enable) && lc $dft_enable eq "yes")
{
    $whole_script=~s/(#DFT marker1\s*
).*(#end of DFT marker1\s*
)/$1 echo
echo #############################################
echo # DFT :- Setup for DFT Rule Checker 
echo #############################################
echo
#dft_scan_style attribute chooses the scan style either : muxed_scan(default) or lssd
#set_attribute dft_scan_style muxed_scan
#Define DFT pins shift_enable, scan_en, scan_clk
define_dft shift_enable -name shift_enable   -active high                   -design \${DESIGN} shift_enable
#shared_in option is used only if the test_mode is shared with an existing functional pin, no need for it if the test_mode is dedicated for test, scan_shift specifies to define this signal as a clock for ATPG.
define_dft test_mode    -name scan_mode -active high -shared_in -scan_shift -design \${DESIGN} scan_en
define_dft test_clock   -name scan_clk  -period 35714                       -design \${DESIGN} scan_clk
#set_compatible_test_clocks -all -design \${DESIGN}
$2/s;
    $whole_script=~s/(#DFT marker2\s*
).*(#end of DFT marker2\s*
)/$1 #Defining the test signal used for clock gating
set_attribute lp_clock_gating_test_signal shift_enable \/designs\/\${DESIGN}
$2/s;

    $whole_script=~s/(#DFT marker3\s*\n).*(#end of DFT marker3\s*\n)/$1echo
echo #############################################
echo # DFT :- Run DFT Rule Checker
echo #############################################
echo
#DFT rule checker need to be run on the design to determine if Clock pins to the flip-flops are directly controllable from a primary input or from a user-defined test clock pin, Asynchronous set\/reset pins to the flip-flops can be held to their inactive state during scan-shift mode
#check_dft_rules Identifies constructs in the design that prevent the flops from being included into the
#scan chains, print all violations to a report
check_dft_rules -max_print_fanin -1 -max_print_violations -1  \${DESIGN} > \$SYNTH_DIR\/dft\/\${DESIGN}.rules.rpt
#General design rule checker that identifies problems in the circuit, such as
#unconnected nets, multidriven nets that impact the DFT coverage
check_design    -all       \${DESIGN} > \$SYNTH_DIR\/rpt\/\${DESIGN}.info.pre.insertion.rpt
#Disable auto-identification of test clocks and test-mode signals during the DFT
#rule checking.
set_attribute dft_identify_top_level_test_clocks false
#If the clock path contains multi-input combinational gates that are controllable under
#test-mode setup and that are mapped to technology components, the tool can
#automatically create separate test clocks in the same test-clock domain for these
#internal clock nets if you set the following attribute
set_attribute dft_identify_internal_test_clocks no_cgic_hier
#Specify the minimum number of scan chains to be created (recommended for block-level
#approach to DFT):
set_attribute dft_min_number_of_scan_chains 1          \${DESIGN}
#To specify that the scan flip-flops triggered by different active edges of the same test
#clock can be mixed along the same scan chain, set the following design attribute
set_attribute dft_mix_clock_edges_in_scan_chains  true \${DESIGN}
#Specify the type of lockup element to include in the scan chain(preferred_edge_sensitive\/ preferred_level_sensitive\/
#edge_sensitive\/ level_sensitive), Note: This could cause skew problems
set_attribute dft_lockup_element_type preferred_edge_sensitive   \${DESIGN}
#Specify the prefix to be used to name user-defined scan chains and scan data ports
set_attribute dft_prefix DFT_
#You can control the scan flip-flop output pin to be used for the scan data path connection (inverted\/non-inverted\/auto(default) #REDUNDANT
set_attribute dft_scan_output_preference auto                \${DESIGN}
#To come up with a conservative area and timing metrics for the design during
#prototyping, you can map all non-scan flip-flops which pass or fail the DFT rule checks
#to their scan-equivalent flip-flops using the dft_scan_map_mode (default is trdc_pass)
set_attr dft_scan_map_mode force_all                         \${DESIGN}
#Connect scan-out to scan-in during mapping (default is loopback #REDUNDANT), could be set to (ground\/floating)
set_attr dft_connect_scan_data_pins_during_mapping loopback  \${DESIGN}
#tie low the shift_enable during mapping (default #REDUNDANT), could be set to floating 
set_attr dft_connect_shift_enable_during_mapping tie_off     \${DESIGN}

#Generate scripts to run Encounter Test (ET-ATPG) rule checker to ensure that the
#design is ATPG ready.
check_atpg_rules -directory \$SYNTH_DIR\/dft -library \${DESIGN}

#A.N report further violations :
report dft_violations \${DESIGN} > \$SYNTH_DIR\/dft\/\${DESIGN}.dft.violations.rpt
#report DFT setup (basic DFT info) before actual scan insertion
report dft_setup \${DESIGN} > \$SYNTH_DIR\/dft\/\${DESIGN}.dft.setup.pre.synthesis.rpt
#enable using scan flops
#set_attribute avoid false SDF*
$2/s;

    $whole_script=~s/(#DFT marker4\s*\n).*(#end of DFT marker4\s*\n)/$1echo
echo ##############################################
echo # DFT:- ATPG Analysis and Test Point Insertion 
echo ##############################################
echo
#To analyze the testability of your design by performing an Automatic Test Pattern Generator
#(ATPG)-based analysis, (currently disabled as it gives error : (Error - unable to invoke 'et')) 
#analyze_testability -library \$$default_library -effort high -directory \$SYNTH_DIR\/dft \${DESIGN}

echo
echo ##############################################
echo # DFT:- Set Up DFT Configuration Constraints 
echo ##############################################
echo
#define the used scan chains with all the scan ports (sdi : scan input, sdo : scan output, shift_enable) . The scan output is shared with internal functional signal "-shared-out" and multiplexed using the test signal defined by "-shared_select" argument)
define_dft scan_chain -name scan_chain0 -configure_pad scan_mode -sdi scan_input -sdo scan_output -shift_enable shift_enable

echo
echo ##############################################
echo # DFT:- Set Up DFT Configuration Constraints 
echo ##############################################
echo
#The scan configuration engine always creates a top-level chain for each user-defined chain.
#If the number of user-defined chains is less than the global minimum number of scan chains
#constraint, the scan configuration engine creates additional top-level chains (if requested
#through the -auto_create_chains option of the connect_scan_chains command)

#preview scan insertion, auto create new chains if needed 
connect_scan_chains -preview -auto_create_chains  -pack \${DESIGN}
#actual scan insertion, auto create new chains if needed 
connect_scan_chains -auto_create_chains -incremental -pack \${DESIGN}
#preview scan insertion into the specified scan chain(s)
#connect_scan_chains -preview -chains scan_chain0  -pack \${DESIGN}
#actual scan insertion  into the specified scan chain(s)
#connect_scan_chains -chains scan_chain0 -pack \${DESIGN}
#report the scan chains in the design
report dft_chains  > \$SYNTH_DIR\/dft\/\${DESIGN}.dft.chains.pre.map.rpt
#report dft_setup after scan insertion
report dft_setup \${DESIGN} > \$SYNTH_DIR\/dft\/\${DESIGN}.dft.setup.post.chain.rpt
#report summary of different scan registers , their status(PASS\/FAIL)
report dft_registers \${DESIGN} > \$SYNTH_DIR\/dft\/\${DESIGN}.dft.registers.rpt
echo
echo #############################################
echo # post DFT Incremental synthesis 
echo #############################################
echo
#synthesize to mapped again after scan insertion
synthesize -to_mapped -incremental -effort high

$2/s;
$whole_script=~s/(#DFT marker5\s*\n).*(#end of DFT marker5\s*\n)/$1#Write description of design scan chains
write_scandef > \$SYNTH_DIR\/dft\/\${DESIGN}.scandef
#writing abstract model for scan chain(s)
write_dft_abstract_model > \$SYNTH_DIR\/dft\/\${DESIGN}.dft.abstract.model
#Writes out the scan-chain information for an Automatic Test Pattern Generator (ATPG) tool in
#a format readable by the designated ATPG tool.
#The ATPG tool uses this information to generate appropriate test patterns
write_atpg -mentor -apply_inputs_at 0 -strobe_outputs_at 30 -test_clock_waveform scan_clk \/designs\/\${DESIGN} 
write_atpg -mentor > \$SYNTH_DIR\/dft\/\${DESIGN}.mentor.dft.atpg
write_atpg -cadence > \$SYNTH_DIR\/dft\/\${DESIGN}.cadence.dft.atpg
write_atpg -stil    > \$SYNTH_DIR\/dft\/\${DESIGN}.stil.dft.atpg
#Report DFT chains after mapping
report dft_chains  > \$SYNTH_DIR\/dft\/\${DESIGN}.dft.chains.post.map.rpt
$2/s;
$whole_script=~s/(#DFT marker6\s*\n).*(#end of DFT marker6\s*\n)/$1#Reports the estimated average power consumption or average switching activities of the
#design during test.
report scan_power >  \$SYNTH_DIR\/rpt\/scan.power.rpt
$2/s;
}
else
{
    $whole_script=~s/(#DFT marker1\s*\n).*(#end of DFT marker1\s*\n)/$1$2/s;
    $whole_script=~s/(#DFT marker2\s*\n).*(#end of DFT marker2\s*\n)/$1$2/s;
    $whole_script=~s/(#DFT marker3\s*\n).*(#end of DFT marker3\s*\n)/$1$2/s;
    $whole_script=~s/(#DFT marker4\s*\n).*(#end of DFT marker4\s*\n)/$1$2/s;
    $whole_script=~s/(#DFT marker5\s*\n).*(#end of DFT marker5\s*\n)/$1$2/s;
    $whole_script=~s/(#DFT marker6\s*\n).*(#end of DFT marker6\s*\n)/$1$2/s;


}
################################################################################################
#Modifying the DFT parameters
################################################################################################

my $shift_enable=$dft_sheet->{Cells}[4][1]->Value;
my $shared_in=$dft_sheet->{Cells}[6][1]->Value;
my $scan_mode=$dft_sheet->{Cells}[5][1]->Value;
my $scan_clk=$dft_sheet->{Cells}[2][1]->Value;
my $scan_clk_period=$dft_sheet->{Cells}[3][1]->Value;
my $scan_in=$dft_sheet->{Cells}[0][1]->Value;
my $scan_out=$dft_sheet->{Cells}[1][1]->Value;
my $shared_out=$dft_sheet->{Cells}[7][1]->Value;

$whole_script=~s/(define_dft\s+shift_enable\s+-name\s+shift_enable\s+-active high\s+-design\s+\${DESIGN}\s+).*/$1$shift_enable/;
if(lc $shared_in eq "yes")
{
    $whole_script=~s/(define_dft\s+test_mode\s+-name\s+scan_mode\s+-active\s+high).*/$1 -shared_in -scan_shift -design \${DESIGN} $scan_mode/;
}
else
{
    $whole_script=~s/(define_dft\s+test_mode\s+-name\s+scan_mode\s+-active\s+high).*/$1 -scan_shift -design \${DESIGN} $scan_mode/;
}

$whole_script=~s/(define_dft\s+test_clock\s+-name\s+scan_clk).*/$1 -period $scan_clk_period -design \${DESIGN} $scan_clk/;
if(lc $shared_out eq "yes")
{
    $whole_script=~s/(define_dft\s+scan_chain\s+-name\s+scan_chain0\s+-configure_pad\s+scan_mode).*/$1 -sdi $scan_in -sdo $scan_out -shift_enable shift_enable -shared_select scan_mode -shared_out/;
}
else
{
    $whole_script=~s/(define_dft\s+scan_chain\s+-name\s+scan_chain0\s+-configure_pad\s+scan_mode).*/$1 -sdi $scan_in -sdo $scan_out -shift_enable shift_enable/;
}
################################################################################################
#Opening and Writing the modified script
################################################################################################
open(SYNTH_SCRIPT_MOD,">$generated_script") || die ("Could not open synth_scrpt_mod.tcl file for writing\n");
print SYNTH_SCRIPT_MOD $whole_script;

################################################################################################
#Run script which sources some variables and run modified RC script
################################################################################################
system("./synth.scr $generated_script $top_level $license $output_dir");

