umask 022

# Clean up existing PATH variable
unsetenv PATH
source /etc/csh.login

# Unset LM_LICENSE_FILE to speed up
unsetenv LM_LICENSE_FILE



################################################################################
# Ensphere Project Specific Env Variables
################################################################################
setenv ENS_PROJ "pluto_ba"

################################################################################
# Choose Tool Versions to be used for this Project
################################################################################
set PROJ_IC5141   =  IC.5.10.41.500.6.141
set PROJ_MMSIM    =  MMSIM.07.20.222
set PROJ_ASSURA   =  Assura.04.10.006-IC5141
# QRC is giving extraction errors. It seems that the deck is not made for QRC
#set PROJ_QRC      =  EXT812000
set PROJ_IUS      =  IUS82_USR4
set PROJ_RC       =  RC810201
set PROJ_SOC      =  SOC0810004
set PROJ_CALIBRE  =  ixl_cal_2009.3_15.12
set PROJ_ICSTATION =  "icstation_v9.0g_linux_x86_64/v9.0g_linux_x86_64"
set PROJ_MGC_AMS  =  ams_2009_2a.aol
set PROJ_MODELSIM =  modelsim_se_6.6b_2010_05
set PROJ_ARTIST_LINK = artist_link_ams_2009_2a.aol_ic.5.10.41.500.6.141

################################################################################
# General Cadence Environment Variables
################################################################################
setenv CDS_LIC_FILE 5280@paris
# Only check CDS_LIC_FILE for feature and not LM_LICENSE_FILE
setenv CDS_LIC_ONLY     1

setenv CDS_DEFAULT_BROWSER "mozilla"

# Defines path for cdsdoc.pth
setenv CDSDOC_PROJECT /tools/cad

# Env variable for printing from Cadence
setenv CDSPLOTINIT /tools/cad/CDSPLOTINIT_FILE

# Cadence applications require the $LANG environment variable to be set to "C"
# for various elements of the user interface to operate correctly
setenv LANG C

# Unset because it was causing a lot of trouble
unsetenv CDS_AUTO_64BIT

# Load ~/.cdsenv followed by CWD/.cdsenv
setenv CDS_LOAD_ENV addCWD

# MMSIM 6.X and higher write large files which cannot be read by IC5141
# with having this set
setenv PSF_WRITE_CHUNK_MODE_ON true

################################################################################
# IC5141 Env Variables
################################################################################
setenv CDSHOME /tools/CADENCE/$PROJ_IC5141
setenv CDS_ROOT $CDSHOME
set    CDSPATH = ( $CDSHOME/tools/bin $CDSHOME/tools/dfII/bin )
setenv CDSLIB ${CDSHOME}/tools/lib:${CDSHOME}/tools/dfII/lib
setenv CDS_Netlisting_Mode Analog

################################################################################
# Assura Env Variables
################################################################################
setenv ASSURAHOME   /tools/CADENCE/$PROJ_ASSURA
set    ASSURAPATH = ( $ASSURAHOME/tools/bin $ASSURAHOME/tools/assura/bin )
set    ASSURALIB  = ${ASSURAHOME}/tools/lib:${ASSURAHOME}/tools/assura/lib

# Disables the pre-"Check and Save" schematic analysis prior to executing the LVS job
# This analysis causes considerable delay
setenv ASSURA_UI_DISABLE_LVS_CNS_WARNING

################################################################################
# QRC Env Variables
################################################################################
#set    QRCHOME = /tools/CADENCE/$PROJ_QRC
#set    QRCPATH = ( $QRCHOME/bin $QRCHOME/tools/bin $QRCHOME/share/extraction/bin )
#setenv QRC_ENABLE_EXTRACTION

################################################################################
# IUS Env Variables
################################################################################
set    IUSHOME = /tools/CADENCE/$PROJ_IUS
set    IUSPATH = ( $IUSHOME/tools/bin $IUSHOME/tools/vtools/vfault/bin )
set    IUSLIB  = ${IUSHOME}/tools/lib

################################################################################
# MMSIM Env Variables
################################################################################
setenv MMSIMHOME   /tools/CADENCE/$PROJ_MMSIM
set    MMSIMPATH = $MMSIMHOME/tools/bin
set    MMSIMLIB  = ${MMSIMHOME}/tools/lib

# The following will turn off default/automatic verilogA compilation errors
setenv CDS_AHDLCMI_ENABLE NO

################################################################################
# RC Env Variables
################################################################################
setenv RCHOME   /tools/CADENCE/$PROJ_RC
set    RCPATH = $RCHOME/tools/synth/bin

################################################################################
# SOC Env Variables
################################################################################
set    SOC_HOME =  /tools/CADENCE/$PROJ_SOC
set    SOC_PATH =  ( $SOC_HOME/tools/bin $SOC_HOME/share/celtic/scripts )
set    SOC_LIB  =  ${SOC_HOME}/tools/lib
setenv ENCOUNTER   $SOC_HOME

################################################################################
# ISCAPE Env Variables
################################################################################
setenv ISCAPE_PATH /tools/CADENCE/iscape/IScape/iscape/bin

################################################################################
# Cadence Documentation Env Aliases
################################################################################
alias cdsdoc    '${CDSHOME}/tools/bin/cdsdoc'
alias assuradoc '${ASSURAHOME}/tools/bin/cdsdoc'
alias mmsimdoc  '${MMSIMHOME}/tools/bin/cdnshelp'
alias rcdoc     '${RCHOME}/tools/bin/cdnshelp'

################################################################################
# Cliosoft Environment Setup
################################################################################
#setenv CLIOSOFT_DIR /tools/CLIOSOFT_NEW_SETUP/install/sos_6.20.p5_linux
# CLIOSOFT_DIR set globally for all projects
setenv CLIOSOFT_DIR_PATH ${CLIOSOFT_DIR}/bin
setenv CLIOSOFT_LIB ${CLIOSOFT_DIR}/lib
setenv CLIOLMD_LICENSE_FILE 21541@paris

setenv GDM_USE_SHLIB_ENVVAR 1

# Automatically exit SOS client when icfb is closed
setenv SOS_CDS_EXIT yes

alias lmcc 'lmstat -c $CLIOLMD_LICENSE_FILE -a | more'

################################################################################
# Calibre Environment Setup
################################################################################
# Setting CALIBRE_HOME is preferred according to documentation, however we need to
# set MGC_HOME otherwise we get strange files not found errors in CIW
setenv MGC_HOME		/tools/MENTOR/install/$PROJ_CALIBRE
setenv CALIBRE_HOME	$MGC_HOME
setenv MGC_AMS_HOME	/tools/MENTOR/install/$PROJ_MGC_AMS
set ARTIST_LINK_HOME =	/tools/MENTOR/install/$PROJ_ARTIST_LINK
setenv ICHOME		/tools/MENTOR/install/icstation/$PROJ_ICSTATION/icstation_home

# Set binary paths
set    CALIBRE_PATH     =  ${CALIBRE_HOME}/bin
set    MGC_AMS_PATH     =  ${MGC_AMS_HOME}/bin
set    MODELSIM_SE_PATH =  /tools/MENTOR/install/$PROJ_MODELSIM/modeltech/linux_x86_64
set    ARTIST_LINK_PATH = ( $ARTIST_LINK_HOME/tools/bin $ARTIST_LINK_HOME/tools/dfII/bin )
set    ICSTATION_PATH	=  ${ICHOME}/bin

# variable to control loading of artist_link.il in .cdsinit
setenv ENS_USE_ARTIST_LINK NO

# Set library paths
setenv CALIBRE_LIB ${MGC_HOME}/lib

# Set env variables used by tools
setenv USE_CALIBRE_64 YES

# To run 32-bit AMS software on 64-bit platforms
#setenv AMS_VCO_MODE 32

setenv MGLS_LICENSE_FILE 1717@dragon:1717@lion

###################################################################################################
# Mentor Documentation Aliases
###################################################################################################
alias lmm 'lmstat -c $MGLS_LICENSE_FILE -a | more'
alias mdoc 'firefox file://$CALIBRE_HOME/docs/infohubs/index.html &'
alias msdoc 'firefox file:///tools/MENTOR/install/$PROJ_MODELSIM/modeltech/docs/infohubs/index.html &'
alias ichelp 'firefox file:///tools/MENTOR/install/icstation/icstation_v9.0g_linux_x86_64/v9.0g_linux_x86_64/icstation_home/docs/infohubs/common/html/index.html &'

###################################################################################################
# Silvaco Env Setup
###################################################################################################
#set SILVACO_PATH = /tools/SILVACO/install/bin
#setenv PSF_WRITE_CHUNKS_MODE_ON true
## Get this variable information from:
##   /tools/SILVACO/install/lib/smartspice
##setenv SMARTSPICE_V "3.11.12.C"
#setenv SMARTSPICE_V "3.17.16.C"

###################################################################################################
# Setup Final LD_LIBRARY_PATH and PATH env variables
###################################################################################################

set path = (				\
		$ICSTATION_PATH		\
		$CALIBRE_PATH		\
		$MODELSIM_SE_PATH	\
		$MGC_AMS_PATH		\
		$MMSIMPATH		\
		$ARTIST_LINK_PATH	\
		$CDSPATH		\
		$ASSURAPATH		\
		$RCPATH			\
		$SOC_PATH		\
		$IUSPATH		\
		$ISCAPE_PATH		\
		$CLIOSOFT_DIR_PATH	\
		/tools/cad/bin		\
		$path )

###################################################################################################################

if ( ! $?LD_LIBRARY_PATH ) then
  setenv LD_LIBRARY_PATH ${CALIBRE_LIB}:${CDSLIB}:${ASSURALIB}:${SOC_LIB}:${IUSLIB}:${MMSIMLIB}:${CLIOSOFT_LIB}
else
  setenv LD_LIBRARY_PATH ${CALIBRE_LIB}:${CDSLIB}:${ASSURALIB}:${SOC_LIB}:${IUSLIB}:${MMSIMLIB}:${CLIOSOFT_LIB}:${LD_LIBRARY_PATH}
endif

###################################################################################################################
# Project Specific Env Variables
###################################################################################################################
setenv MGC_CALIBRE_DRC_RUNSET_LIST calibre_runset_drc_list
setenv MGC_CALIBRE_LVS_RUNSET_LIST calibre_runset_lvs_list


###################################################################################################################
