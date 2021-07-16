import argparse
import os

# Run with python3 in work/proj/
#
# Compare the TrackBuilder output EMP file from VHDL test-bench 
# with that expected from emulation,
# where you have previously derived the latter from emData/ with
# convert_emData2EMP_FT.py

def parseArguments():
    # Create argument parser
    parser = argparse.ArgumentParser(description="Compare EMP file from VHDL test-bench to that expected from emulation, derived from emData/")

 
    # Optional arguments
    parser.add_argument("-tb", "--tbEMPfile", dest="tbEMPfile", help="EMP file written by VHDL testbench", type=str, default="qsim/out.txt")
    parser.add_argument("-em", "--emulationEMPfile", dest="emEMPfile", help="EMP file derived from emData/", type=str, default="./FT_EMP.txt")

    # Parse arguments
    args = parser.parse_args()

    return args

empWordLen=16 # Hex chars in an EMP data word
clksInTM=108 # Length of TM period in clock cycles
clksInGap=6  # Gap when no valid data sent.

# Define enum for test-bench & emulation results
TB, EM = range(2)

if __name__ == '__main__':

  args = parseArguments()

  fileNames = [args.tbEMPfile, args.emEMPfile]

  numLines = []
  listAllData = []
  listAllClks = []

  for fileName in fileNames:

    allData = {} 
    allClks = {}
    file = open(fileName, 'r')
    lines = file.readlines()[3:] # Skip header
    numLines.append(len(lines))

    for line in lines:
      wordsAll = line.split()
      frame = int(wordsAll[1])
      event = frame//clksInTM
      clk   = frame%clksInTM
      words = wordsAll[3:]
      valid = False
      for word in words:
        w = word[2:] # Prune "1v"
        if int(w,16) != 0:
          valid = True

      allData.setdefault(event,[])
      allClks.setdefault(event,[])
      if valid:
        # Store non-zero data & clk it occured in
        allData[event].append(words)
        allClks[event].append(clk)

    listAllData.append(allData)
    listAllClks.append(allClks)

  # Read emulation data


  if numLines[TB] != numLines[EM]:
    print("Files have inconsistent number of lines ",numLines[TB],numLines[EM])
    exit(1)

  nEvents = numLines[TB]//clksInTM

  ievBad = -1
  for iev in range(nEvents):
    if listAllData[TB][iev] == listAllData[EM][iev]:
      if listAllClks[TB][iev] == listAllClks[EM][iev]:
        if len(listAllData[TB][iev]) > 0: # Non-trivial event
          print("=== Event ",iev," OK") 
      else:
        if ievBad != iev:
          print("=== Event ",iev)
          ievBad = iev
        print("Consistent data, but in inconsistent frame nos.: TB=",listAllClks[TB][iev]," EM=",listAllClks[EM][iev])                                             

    else:
      if ievBad != iev:
        print("=== Event ",iev)
        ievBad = iev
      print("Inconsistent data:")
      for d in listAllData[TB][iev]:
        print("  TB=",d)
      for d in listAllData[EM][iev]:
        print("  EM=",d)
        
