# -*- coding: utf-8 -*-

import os.path

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

