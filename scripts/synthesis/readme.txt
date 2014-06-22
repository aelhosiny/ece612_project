To run the synthesis script :
1-Make sure the following files are present in the current directory:
##  1-synth_param.xls											   
##  2-synth_scrpt.tcl											   
##  3-synth.scr												   
##  4-setup_tsmc.cshrc

2-Update the project parameters in the Excel sheet

3-Run the perl script:
perl synth_param_parse.pl <license>

where <license> could be either 
5280@10.8.0.23
OR
44556@rfx.labs.aucegypt.edu

