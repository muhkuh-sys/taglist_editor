# -*- coding: utf-8 -*-

import subprocess

# Requires Inno Setup. 
# Include the path to iscc.exe in PATH or include the command with the full path here.
# ISCC="iscc.exe"
ISCC="C:\Program Files (x86)\Inno Setup 5 Unicode\iscc.exe"

#----------------------------------------------------------------------------
#
# Set up the Muhkuh Build System.
#
SConscript('mbs/SConscript')
Import('atEnv')

#----------------------------------------------------------------------------
#
# Get the source code version from the VCS.
#
atEnv.DEFAULT.Version('targets/version.lua', 'templates/version.lua')
atEnv.DEFAULT.Version('targets/version.iss', 'templates/version.iss')
atEnv.DEFAULT.Version('targets/Modulator.cfg', 'templates/Modulator.cfg')

#----------------------------------------------------------------------------
#
# Build the installer.
#

print "Building installer"
subprocess.check_call([ISCC, "installer\inno\muhkuh_nxo_editor.iss"])

