import argparse
import os

# Run with python3 in work/proj/
# Converts TrackBuilder output data from emData to EMP format

def parseArguments():
    # Create argument parser
    parser = argparse.ArgumentParser(description="Convert an emData/ memory data file into a EMP format file. Link-file mapping is done editing the header of the script.")

    # Optional arguments
    parser.add_argument("-d", "--directory", dest="inputDir", help="directory containing input data", type=str, default="emData/MemPrintsReduced/FT/FT_L1L2/")
    parser.add_argument("-o","--outFile", dest="outFile", help="output file name", type=str, default="FT_EMP.txt")

    # Parse arguments
    args = parser.parse_args()

    return args

# TrackBuilder output track parameter bit width & stub width
trackNbits = int(84)
stubNbitsBarrel = int(46)
stubNbitsEndcap = int(49)

# Files in order in which they are referred to in memUtil_pkg.vhd.
# Integers refer to min and max channel of each file onto which the track params + 4 barrel + 4 endcap layers are mapped.
mapping = {}
mapping[0]  = [0, 7, "TrackFit_TF_L1L2_04.dat"]
#mapping[1]  = [8, 15, "TrackFit_TF_L3L4_04.dat"]

channels = ["q00c0","q00c1","q00c2","q00c3","q01c0","q01c1","q01c2","q01c3","q02c0","q02c1","q02c2","q02c3","q03c0","q03c1","q03c2","q03c3","q04c0","q04c1","q04c2","q04c3"]

empWordLen=16 # Hex chars in an EMP data word
clksInTM=108 # Length of TM period in clock cycles
clksInGap=6  # Gap when no valid data sent.

if __name__ == '__main__':

  args = parseArguments()

  outFile = open(args.outFile, 'w')

  allData = {}

  nChan = 0
  outFileLink = []
  for j in mapping:
    chanLow  = mapping[j][0]
    chanHigh = mapping[j][1]
    nChan += (chanHigh - chanLow + 1)

    file = open(args.inputDir + mapping[j][2], 'r')
    lines = file.readlines()

    for line in lines: 
      words = line.split()
      if len(words) == 6:
        eventNumber = int(words[5])
        for chan in range(chanLow, chanHigh + 1):
          allData[(eventNumber,chan)] = []
      if len(words) == 3:
        addr = words[0]
        data = words[2]
        dataBinary = bin(int(data,16))[-(trackNbits+4*stubNbitsBarrel+4*stubNbitsEndcap):] # Remove initial "0b" and any padding to full hex digits.
        bitHigh = 0
        for chan in range(chanLow, chanHigh + 1):
          bitLow = bitHigh
          if chan - chanLow == 0: # Track
            bitHigh = bitLow + trackNbits
            valid = "1v"
          elif chan - chanLow <= 4: # Stub barrel
            bitHigh = bitLow + stubNbitsBarrel
            valid = "1v"
          else: # Stub endcap
            bitHigh = bitLow + stubNbitsEndcap
            valid = "0v"
          # Part of word corresponding to track or stub
          dataBin = dataBinary[bitLow:bitHigh]

          if chan - chanLow == 0:
            # Bodge: EMP interface drops track hit pattern
            nBitsHitPattern = 24
            dataBin = dataBin[:-nBitsHitPattern]
          else:
            # Bodge: EMP interface drops track & stub index from stub word
            nBitsTrkIndex = 7
            nBitsStubIndex = 10
            dataBin = dataBin[0] + dataBin[1+nBitsTrkIndex+nBitsStubIndex:]

          subWord = hex(int(dataBin,2))
          empData = valid + subWord[2:].zfill(empWordLen)
          allData[(eventNumber,chan)].append(empData)

  outFile.write("Board apollo.c2c.vu7p\n")
  outFile.write(" Quad/Chan :        ") 
  for chan in range(nChan):
    outFile.write("%s              " %(channels[chan]))
  outFile.write("\n")
  outFile.write("      Link :         ")
  for chan in range(nChan):
    outFile.write("%s                " %(str(chan).zfill(3)))
  outFile.write("\n")

  gapData  = "0v0000000000000000"
  nullData1V = "1v0000000000000000"
  nullData0V = "0v0000000000000000"
  iClk = -1
  for event in range(1+eventNumber):
    for iFrame in range(0,clksInTM):
      iFrameCorr = iFrame - clksInGap
      iClk += 1
      outFile.write("Frame %s : " %(str(iClk).zfill(4)))
      for chan in range(nChan):
        theKey = (event,chan)
        empDataList = allData[theKey]
        if (iFrame < clksInGap):
          outFile.write("%s " %gapData)
        elif (iFrameCorr < len(empDataList)):
          outFile.write("%s " %empDataList[iFrameCorr])
        else:
          if chan <= 4: # track or barrel stub
            outFile.write("%s " %nullData1V)
          else: # endcap stub
            outFile.write("%s " %nullData0V)
      outFile.write("\n")
    
  print("Output written to file ",args.outFile)
