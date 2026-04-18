#!/bin/tcsh
# #########################################################
# EDA Tools Configurations for Viterbi Server
# #########################################################

alias prepend 'if (-d \!:2) if ("$\!:1" \!~ *"\!:2"*) setenv \!:1 "\!:2":${\!:1}'
alias extend  'if (-d \!:2) if ("$\!:1" \!~ *"\!:2"*) setenv \!:1 ${\!:1}:\!:2'

# #########################################################
# License Setup
# #########################################################
setenv LM_LICENSE_FILE 1720@ics-lic2.usc.edu:1721@lic-cadence.usc.edu
setenv SNPSLMD_LICENSE_FILE 27000@lic-synopsys.usc.edu

# #########################################################
# Cadence Tools
# #########################################################
setenv CDS_AUTO_64BIT ALL

setenv CDSBASE /tools/cadence
setenv INC_HOME     $CDSBASE/INCISIVE152
setenv XCELIUM_HOME $CDSBASE/XCELIUM2509

prepend PATH $INC_HOME/tools/bin # SimVision
prepend PATH $XCELIUM_HOME/tools.lnx86/inca/bin/64bit

setenv INV_HOME $CDSBASE/DDI251/INNOVUS251
prepend PATH $INV_HOME/tools/bin

# setenv CFM_HOME $CDSBASE/CONFRML161   # Conformal

# #########################################################
# Synopsys Tools
# #########################################################
setenv SYNBASE /tools/synopsys

setenv DC_HOME  $SYNBASE/syn/Y-2026.03
prepend PATH $DC_HOME/bin

setenv VCS_HOME $SYNBASE/vcs/X-2025.06
prepend PATH $VCS_HOME/bin

setenv PT_HOME $SYNBASE/prime/Y-2026.03
prepend PATH $PT_HOME/bin

# alias
alias vcs "$VCS_HOME/bin/vcs"
alias dve "$VCS_HOME/bin/dve -full64"
# alias vcs "$VCS_HOME/bin/vcs -full64" # VCS 64-bit mode
# alias dve "$VCS_HOME/bin/dve -full64" # VCS GUI Mode 