# -*- coding: utf-8 -*-
# ----------------------------------------------------------------------- #
#   Copyright (C) 2017 by Christoph Thelen                                #
#   doc_bacardi@users.sourceforge.net                                     #
#                                                                         #
#   This program is free software; you can redistribute it and/or modify  #
#   it under the terms of the GNU General Public License as published by  #
#   the Free Software Foundation; either version 2 of the License, or     #
#   (at your option) any later version.                                   #
#                                                                         #
#   This program is distributed in the hope that it will be useful,       #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#   GNU General Public License for more details.                          #
#                                                                         #
#   You should have received a copy of the GNU General Public License     #
#   along with this program; if not, write to the                         #
#   Free Software Foundation, Inc.,                                       #
#   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
# ----------------------------------------------------------------------- #

import argparse
import logging
import os
import platform
import re
import shutil
import string
import subprocess
import sys
import tarfile
import tempfile
import time
import urllib2


strDefaultJonchkiVersion = '0.0.1.1'


class ProgressOutput:
    # This is the minimum time between 2 flushes in seconds.
    m_tTimeMinimumFlushIntervall = 1.0
    m_tTimeLastFlushTime = 0

    # This is the size for one dot.
    m_sizDot = None

    # This is the total size of the file. 0 means the total size is unknown.
    m_sizTotal = 0

    # This is an internal state variable which records what has been printed
    # on a line yet.
    # 0 means it is a blank line
    # >0 is the number of dots printed.
    m_uiDotsPrintedInCurrentLine = 0
    m_uiDotsPerLine = 50
    # This is the download position at the start of the line in bytes.
    m_uiLinePositionStart = 0

    m_sizCurrent = None

    def __init__(self, sizTotal):
        # Set the size for one dot according to the total size.
        print('Size in bytes: %d' % sizTotal)
        if sizTotal == 0:
            # Unknown total size -> default to 2048.
            self.m_sizDot = 2048
        else:
            # Try to get a maximum of 20 lines at a maximum of 1MB dots.
            sizMaxLines = 20
            sizDot = sizTotal / self.m_uiDotsPerLine / sizMaxLines
            if sizDot > 1024 * 1024:
                sizDot = 1024 * 1024
            elif sizDot < 2048:
                sizDot = 2048
            self.m_sizDot = sizDot
        self.m_sizTotal = sizTotal
        self.m_tTimeLastFlushTime = time.time()
        self.m_uiDotsPrintedInCurrentLine = None
        self.m_sizCurrent = 0
        self.m_uiLinePositionStart = 0
        self.update(0)

    def update(self, sizData):
        # Print dots or header?
        fPrintDots = (sizData > 0) or (self.m_sizCurrent == 0)
        # Loop over all dots line by line.
        while fPrintDots is True:
            # Print a header if this is the start of the line.
            if self.m_uiDotsPrintedInCurrentLine is None:
                # Only print the percent information if the total size is
                # known.
                if self.m_sizTotal != 0:
                    # Get the new percentage.
                    uiPercent = 100.0 * self.m_sizCurrent / self.m_sizTotal
                    sys.stdout.write('% 3d%% ' % uiPercent)
                else:
                    sys.stdout.write('     ')
                self.m_uiDotsPrintedInCurrentLine = 0

            # Get the end position of the line in bytes.
            sizLineEnd = self.m_uiLinePositionStart
            sizLineEnd += self.m_uiDotsPerLine * self.m_sizDot
            sizDownloaded = self.m_sizCurrent + sizData
            if sizLineEnd > sizDownloaded:
                sizLineEnd = sizDownloaded
            sizChunk = sizLineEnd - self.m_sizCurrent

            # Get the number of bytes in this line.
            sizDotBytes = sizLineEnd - self.m_uiLinePositionStart
            # Get the number of new dots in this line.
            sizDots = int(sizDotBytes / self.m_sizDot)
            sizDots -= self.m_uiDotsPrintedInCurrentLine
            # Print the new dots.
            sys.stdout.write('.' * sizDots)
            # Update the number of dots printed in this line.
            self.m_uiDotsPrintedInCurrentLine += sizDots

            # Print end of line if the maximum number of dots reached.
            if self.m_uiDotsPrintedInCurrentLine >= self.m_uiDotsPerLine:
                # Terminate the line.
                sys.stdout.write('\n')
                # A line feed is also a flush.
                self.m_tTimeLastFlushTime = time.time()
                # The next line has no dots yet.
                self.m_uiDotsPrintedInCurrentLine = None
                # Set the new line start position.
                self.m_uiLinePositionStart += (self.m_uiDotsPerLine *
                                               self.m_sizDot)

            self.m_sizCurrent += sizChunk
            sizData -= sizChunk
            # Print more?
            fPrintDots = (sizData > 0)

        # Flush the output stream.
        tLastFlush = time.time() - self.m_tTimeLastFlushTime
        if tLastFlush >= self.m_tTimeMinimumFlushIntervall:
                sys.stdout.flush()

    def finish(self):
        if self.m_uiDotsPrintedInCurrentLine is not None:
            # Terminate the line.
            sys.stdout.write('\n')


class PlatformDetect:
    def __init__(self):
        self.strHostCpuArchitecture = None
        self.strHostDistributionId = None
        self.strHostDistributionVersion = None
        self.strStandardArchiveFormat = None

    def __windows_get_cpu_architecture_env(self):
        strCpuArchitecture = None
        strEnvProcessorArchitecture = None
        strEnvProcessorArchiteW6432 = None
        if 'PROCESSOR_ARCHITECTURE' in os.environ:
            strEnvProcessorArchitecture = os.environ['PROCESSOR_ARCHITECTURE']
        if 'PROCESSOR_ARCHITEW6432' in os.environ:
            strEnvProcessorArchiteW6432 = os.environ['PROCESSOR_ARCHITEW6432']
        # See here for details: https://blogs.msdn.microsoft.com/david.wang/
        # 2006/03/27/howto-detect-process-bitness/
        if (strEnvProcessorArchitecture == 'amd64') or (strEnvProcessorArchiteW6432 == 'amd64'):
            strCpuArchitecture = 'x86_64'
        elif (strEnvProcessorArchitecture == 'x86') and (strEnvProcessorArchiteW6432 is None):
            strCpuArchitecture = 'x86'
        else:
            print('Failed to detect the CPU architecture on Windows with the ENV variables.')
            print('PROCESSOR_ARCHITECTURE = %s' % (str(strEnvProcessorArchitecture)))
            print('PROCESSOR_ARCHITEW6432 = %s' % (str(strEnvProcessorArchiteW6432)))

        return strCpuArchitecture

    # See here for the output of the "ver" command: https://en.wikipedia.org/wiki/Ver_(command)
    def __windows_get_distribution_ver(self):
        strDistributionId = None
        strDistributionVersion = None

        # Try to parse the output of the 'ver' command.
        strOutput = subprocess.check_output(['ver'])
        tMatch = re.search('\d+\.\d+\.\d+', strOutput)
        if tMatch is None:
            raise Exception('Failed to get the Windows version with "ver".')
        strDistributionId = 'windows'
        strDistributionVersion = tMatch.group(0)

        return strDistributionId, strDistributionVersion

    def __linux_get_cpu_architecture_lscpu(self):
        strCpuArchitecture = None
        astrReplacements = {
            'i386': 'x86',
            'i486': 'x86',
            'i586': 'x86',
            'i686': 'x86'
        }

        # Try to parse the output of the 'lscpu' command.
        strOutput = subprocess.check_output(['lscpu'])
        tMatch = re.search('Architecture: *(\S+)', strOutput)
        if tMatch is None:
            raise Exception('Failed to get the CPU architecture with "lscpu".')

        strCpuArchitecture = tMatch.group(1)
        # Replace the CPU architectures found in the list.
        if strCpuArchitecture in astrReplacements:
            strCpuArchitecture = astrReplacements[strCpuArchitecture]

        return strCpuArchitecture

    def __linux_detect_distribution_etc_lsb_release(self):
        strDistributionId = None
        strDistributionVersion = None

        # Try to open /etc/lsb-release.
        tFile = open('/etc/lsb-release', 'rt')
        if tFile is None:
            raise Exception('Failed to detect the Linux distribution with /etc/lsb-release.')
        for strLine in tFile:
            tMatch = re.match('DISTRIB_ID=(.+)', strLine)
            if tMatch is not None:
                strDistributionId = string.lower(tMatch.group(1))
            tMatch = re.match('DISTRIB_RELEASE=(.+)', strLine)
            if tMatch is not None:
                strDistributionVersion = tMatch.group(1)
        tFile.close()

        # Return both components or none.
        if (strDistributionId is None) or (strDistributionVersion is None):
            strDistributionId = None
            strDistributionVersion = None

        return strDistributionId, strDistributionVersion

    def detect(self):
        strSystem = platform.system()
        if strSystem == 'Windows':
            # This is windows.

            # Detect the CPU architecture.
            self.strHostCpuArchitecture = self.__windows_get_cpu_architecture_env()

            # Get the version with the 'ver' command.
            self.strHostDistributionId, self.strHostDistributionVersion = self.__windows_get_distribution_ver()

            # Windows uses ZIP as standard archive format.
            self.strStandardArchiveFormat = 'zip'
        elif strSystem == 'Linux':
            # This is a Linux.

            # Detect the CPU architecture.
            self.strHostCpuArchitecture = self.__linux_get_cpu_architecture_lscpu()

            # Detect the distribution.
            self.strHostDistributionId, self.strHostDistributionVersion = self.__linux_detect_distribution_etc_lsb_release()

            # Linux uses TAR GZIP as standard archive format.
            self.strStandardArchiveFormat = 'tar.gz'
        else:
            raise Exception('Unknown platform: "%s"' % (strSystem))


#
# Download the URL 'strUrl' to the file tFile.
#
# Returns 'True' on success, 'False' on error.
#
def download_to_file(strUrl, tFile):
    bResult = False
    fOutput = None
    sizDownloaded = 0

    try:
        aSocket = urllib2.urlopen(strUrl)
        aInfo = aSocket.info()
        try:
            sizTotal = int(aInfo['content-length'])
        except KeyError:
            sizTotal = 0
        tProgress = ProgressOutput(sizTotal)

        while 1:
            strChunk = aSocket.read(2048)
            sizChunk = len(strChunk)
            if sizChunk == 0:
                break
            tFile.write(strChunk)
            sizDownloaded += sizChunk
            tProgress.update(sizChunk)

        tProgress.finish()
        bResult = True
    except urllib2.HTTPError as e:
        print('Failed to download %s: %d' % (strUrl, e.code))

    if fOutput:
        fOutput.close()

    return bResult


tParser = argparse.ArgumentParser(description='Install a jonchki version to a local folder.')
tParser.add_argument('strOutputFolder', metavar='OUTPUT_FOLDER',
                     help='Install the jonchki tool to the folder OUTPUT_FOLDER.')
tParser.add_argument('-j', '--jonchki-version', dest='strJonchkiVersion', default=strDefaultJonchkiVersion,
                     metavar='VERSION', help='Install version VERSION of the jonchki tool. (default is %s)' % strDefaultJonchkiVersion)

atArgs = tParser.parse_args()

logging.basicConfig(level=logging.DEBUG)

strOutputFolder = atArgs.strOutputFolder
strJonchkiVersion = atArgs.strJonchkiVersion

logging.info('Install jonchki v%s to %s.' % (strJonchkiVersion, strOutputFolder))

# Create the expected tool path.
fFoundJonchki = False
strJonchkiPath = os.path.join(strOutputFolder, 'jonchki-%s' % (strJonchkiVersion))
strJonchkiTool = os.path.join(strJonchkiPath, 'jonchki')
logging.debug('Jonchki path: %s' % strJonchkiPath)
logging.debug('Jonchki tool: %s' % strJonchkiTool)
if os.path.isdir(strJonchkiPath) is not True:
    logging.info('The jonchki path does not exist.')
else:
    logging.debug('The jonchki path exists.')

    if os.path.isfile(strJonchkiTool) is not True:
        logging.info('The jonchki tool does not point to a file.')
    else:
        try:
            strOutput = string.strip(subprocess.check_output([strJonchkiTool, '--version'], shell=False))
            logging.debug('The jonchki tool reported the version string "%s".' % strOutput)
        except subprocess.CalledProcessError:
            logging.debug('Failed to get the version from the jonchki tool.')
            strOutput = ''
        tMatch = re.match('jonchki V(\d+.\d+.\d+.\d+)', strOutput)
        if tMatch is None:
            logging.debug('Failed to extract the version from the jonchi output.')
        else:
            strFoundVersion = tMatch.group(1)
            logging.debug('The jonchi tool reported version %s.' % strFoundVersion)
            if strJonchkiVersion != strFoundVersion:
                logging.debug('The reported version "%s" does not match the requested version "%s".' % (strFoundVersion, strJonchkiVersion))
            else:
                fFoundJonchki = True
                logging.info('Jonchki v%s is already installed.' % strJonchkiVersion)

    if fFoundJonchki is not True:
        logging.info('The jonchki path "%s" does not contain a useable version.' % strJonchkiPath)
        logging.info('Remove the jonchi path recursively.')

        # Recursively delete the jonchki folder.
        shutil.rmtree(strJonchkiPath)

if fFoundJonchki is not True:
    logging.info('The tool is not yet installed in the requested version.')

    c = PlatformDetect()
    c.detect()
    print('Host CPU architecture: %s' % c.strHostCpuArchitecture)
    print('Host distribution ID: %s' % c.strHostDistributionId)
    print('Host distribution version: %s' % c.strHostDistributionVersion)
    print('Standard archive format: %s' % c.strStandardArchiveFormat)

    astrReplace = {
        'HOST_CPU_ARCHITECTURE': c.strHostCpuArchitecture,
        'HOST_DISTRIBUTION_ID': c.strHostDistributionId,
        'HOST_DISTRIBUTION_VERSION': c.strHostDistributionVersion,
        'JONCHKI_VERSION': strJonchkiVersion,
        'ARCHIVE_EXTENSION': c.strStandardArchiveFormat
    }
    strUrlTemplate = 'https://github.com/muhkuh-sys/org.muhkuh.lua-jonchki/releases/download/v{JONCHKI_VERSION}/jonchki-{JONCHKI_VERSION}-{HOST_DISTRIBUTION_ID}{HOST_DISTRIBUTION_VERSION}_{HOST_CPU_ARCHITECTURE}.{ARCHIVE_EXTENSION}'
    strUrl = strUrlTemplate.format(**astrReplace)
    print(strUrl)

    # Download the archive to a temporary file.
    tFile = tempfile.TemporaryFile()
    tResult = download_to_file(strUrl, tFile)
    tFile.seek(0, 0)

    # Extract the archive contents to the destiation folder.
    if c.strStandardArchiveFormat == 'tar.gz':
        tArchive = tarfile.open(fileobj=tFile, mode='r')
        while 1:
            tInfo = tArchive.next()
            if tInfo is None:
                break
            strDstPath = os.path.join(strOutputFolder, tInfo.name)
            strRel = os.path.relpath(strDstPath, strOutputFolder)
            if strRel[0:2] == '..':
                raise Exception('Invalid archive member: "%s".' % (tInfo.name))
            tArchive.extract(tInfo, path=strOutputFolder)
        tArchive.close()

    tFile.close()
