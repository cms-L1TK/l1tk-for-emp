import argparse
import os

CRED = '\033[91m'
CGREEN  = '\33[32m'
CEND = '\033[0m'
CBLINK    = '\33[5m'
CBLINK2   = '\33[6m'
CBOLD     = '\33[1m'
CREDBG    = '\33[41m'

def parseArguments():
    # Create argument parser
    parser = argparse.ArgumentParser(description="Compare two specific events in a DAT and an EMP output file. By default events 0 are compared.")

    # Positional mandatory arguments
    parser.add_argument("datfile", help="DAT file", type=str)
    parser.add_argument("empfile", help="EMP file", type=str)
    # Optional arguments
    parser.add_argument("-d", "--datevent", dest="datevent", help="DAT event number", type=int, default=0)
    parser.add_argument("-e", "--empevent", dest="empevent", help="EMP event number", type=int, default=0)

    # Parse arguments
    args = parser.parse_args()

    return args

def decode_dat(bitstr):
  inlist = []
  for element in bitstr.split("|"):
    inlist.append(int(element,2))

 
  out_dict = {}
  out_dict["track.valid"] = inlist[0]
  out_dict["track.seed"] =  inlist[1]
  out_dict["track.Rinv"] =  inlist[2]
  out_dict["track.phi"] =  inlist[3]
  out_dict["track.z"] =  inlist[4]
  out_dict["track.tanL"] =  inlist[5]
  out_dict["track.laymap"] =  inlist[6]

  out_dict["stub1.valid"] =  inlist[7]
  out_dict["stub1.trackIndex"] =  inlist[8]
  out_dict["stub1.stubIndex"] =  inlist[9]
  out_dict["stub1.r"] =  inlist[10]
  out_dict["stub1.phi"] =  inlist[11]
  out_dict["stub1.z"] =  inlist[12]

  out_dict["stub2.valid"] =  inlist[13]
  out_dict["stub2.trackIndex"] =  inlist[14]
  out_dict["stub2.stubIndex"] =  inlist[15]
  out_dict["stub2.r"] =  inlist[16]
  out_dict["stub2.phi"] =  inlist[17]
  out_dict["stub2.z"] =  inlist[18]

  out_dict["stub3.valid"] =  inlist[19]
  out_dict["stub3.trackIndex"] =  inlist[20]
  out_dict["stub3.stubIndex"] =  inlist[21]
  out_dict["stub3.r"] =  inlist[22]
  out_dict["stub3.phi"] =  inlist[23]
  out_dict["stub3.z"] =  inlist[24]

  out_dict["stub4.valid"] =  inlist[25]
  out_dict["stub4.trackIndex"] =  inlist[26]
  out_dict["stub4.stubIndex"] =  inlist[27]
  out_dict["stub4.r"] =  inlist[28]
  out_dict["stub4.phi"] =  inlist[29]
  out_dict["stub4.z"] =  inlist[30]

  out_dict["stub5.valid"] =  inlist[31]
  out_dict["stub5.trackIndex"] =  inlist[32]
  out_dict["stub5.stubIndex"] =  inlist[33]
  out_dict["stub5.r"] =  inlist[34]
  out_dict["stub5.phi"] =  inlist[35]
  out_dict["stub5.z"] =  inlist[36]

  out_dict["stub6.valid"] =  inlist[37]
  out_dict["stub6.trackIndex"] =  inlist[38]
  out_dict["stub6.stubIndex"] =  inlist[39]
  out_dict["stub6.r"] =  inlist[40]
  out_dict["stub6.phi"] =  inlist[41]
  out_dict["stub6.z"] =  inlist[42]

  out_dict["stub7.valid"] =  inlist[43]
  out_dict["stub7.trackIndex"] =  inlist[44]
  out_dict["stub7.stubIndex"] =  inlist[45]
  out_dict["stub7.r"] =  inlist[46]
  out_dict["stub7.phi"] =  inlist[47]
  out_dict["stub7.z"] =  inlist[48]

  out_dict["stub8.valid"] =  inlist[49]
  out_dict["stub8.trackIndex"] =  inlist[50]
  out_dict["stub8.stubIndex"] =  inlist[51]
  out_dict["stub8.r"] =  inlist[51]
  out_dict["stub8.phi"] =  inlist[52]
  out_dict["stub8.z"] =  inlist[53]

  return out_dict

def decode_emp_track(empdata):
  input = int(empdata.split("v")[1],16)

  out_dict = {}
  out_dict["track.valid"] = (input>>59)
  out_dict["track.seed"] =  (input>>56)&0x7
  out_dict["track.Rinv"] =  (input>>42)&0x3FFF
  out_dict["track.phi"] =  (input>>24)&0x3FFFF
  out_dict["track.z"] =  (input>>14)&0x3FF
  out_dict["track.tanL"] =  (input)&0x3FFF
  
  return out_dict

def decode_emp_stub(empdata1,empdata2,empdata3,empdata4):
  input1 = int(empdata1.split("v")[1],16)
  input2 = int(empdata2.split("v")[1],16)
  input3 = int(empdata3.split("v")[1],16)
  input4 = int(empdata4.split("v")[1],16)

  out_dict = {}
  out_dict["stub1.valid"] = (input1>>45)
  out_dict["stub1.trackIndex"] =  (input1>>38)&0x7F
  out_dict["stub1.stubIndex"] =  (input1>>28)&0x3FF
  out_dict["stub1.r"] =  (input1>>21)&0x7F
  out_dict["stub1.phi"] =  (input1>>9)&0xFFF
  out_dict["stub1.z"] =  (input1)&0x1FF

  out_dict["stub2.valid"] = (input2>>45)
  out_dict["stub2.trackIndex"] =  (input2>>38)&0x7F
  out_dict["stub2.stubIndex"] =  (input2>>28)&0x3FF
  out_dict["stub2.r"] =  (input2>>21)&0x7F
  out_dict["stub2.phi"] =  (input2>>9)&0xFFF
  out_dict["stub2.z"] =  (input2)&0x1FF

  out_dict["stub3.valid"] = (input3>>45)
  out_dict["stub3.trackIndex"] =  (input3>>38)&0x7F
  out_dict["stub3.stubIndex"] =  (input3>>28)&0x3FF
  out_dict["stub3.r"] =  (input3>>21)&0x7F
  out_dict["stub3.phi"] =  (input3>>9)&0xFFF
  out_dict["stub3.z"] =  (input3)&0x1FF

  out_dict["stub4.valid"] = (input4>>45)
  out_dict["stub4.trackIndex"] =  (input4>>38)&0x7F
  out_dict["stub4.stubIndex"] =  (input4>>28)&0x3FF
  out_dict["stub4.r"] =  (input4>>21)&0x7F
  out_dict["stub4.phi"] =  (input4>>9)&0xFFF
  out_dict["stub4.z"] =  (input4)&0x1FF
 
  return out_dict

if __name__ == '__main__':
  args = parseArguments()

  file_dat = open(args.datfile, 'r')
  Lines = file_dat.readlines()

  data_dat = {}

  for line in Lines:
    if (len(line.split())==6):
      data_dat[int(line.split()[5])] = []   
    if (len(line.split())==3):
      data_dat[list(data_dat.keys())[-1]].append(line.split())

  file_dat.close()

  file_emp = open(args.empfile, 'r')
  Lines = file_emp.readlines()

  data_emp = {}
  event_count = -1
  header_count = 0

  for idj,line in enumerate(Lines):
    if (len(line.split())==11):
      goodline = False
      header_bool = True
      for idx,element in enumerate(line.split()):
        if (idx>2 and element!="0v0000000000000000" and element!="1v0000000000000000"): 
          goodline = True
          header_count = 0
        if (element.find("1v")>-1 and idj>2):
          header_bool = False
      if header_bool:
        header_count += 1
      if header_count==6:
        header_count = 0 
        event_count += 1
        data_emp[event_count] = []
      if goodline:
        temp_array = []
        for element in line.split():
          temp_array.append(element) 
        data_emp[event_count].append(temp_array)

  file_emp.close()

  if len(data_dat[args.datevent])!=len(data_emp[args.empevent]):
    print("+++++++++++++++++++++++++++++")
    print(CRED+"     Track number mismatch"+CEND)
    print("+++++++++++++++++++++++++++++")


  mismatch = False
  if min([len(data_dat[args.datevent]),len(data_emp[args.empevent])]) == 0: mismatch = True

  for idx in range(min([len(data_dat[args.datevent]),len(data_emp[args.empevent])])):
    print("+++++++++++++++++++++++++++++")
    print("     Track "+str(idx))
    print("+++++++++++++++++++++++++++++")
    print("Var_name\tEMP_value\tDAT_value")
    dat_dict = decode_dat(data_dat[args.datevent][idx][1]) 
    emp_dict = decode_emp_track(data_emp[args.empevent][idx][3]) 
    emp_dict.update(decode_emp_stub(data_emp[args.empevent][idx][4], data_emp[args.empevent][idx][5], data_emp[args.empevent][idx][6], data_emp[args.empevent][idx][7] ))

    for i in emp_dict:

      if (emp_dict[i]!=dat_dict[i]):
        print(" "+str(i)+"\t"+str(emp_dict[i])+"\t"+str(dat_dict[i])+" "+CRED+"<<=== Mismatch"+CEND)
        mismatch = True
      else:
        print(" "+str(i)+"\t"+str(emp_dict[i])+"\t"+str(dat_dict[i])+" ")

  if mismatch:
    print("+++++++++++++++++++++++++++++")
    print(CRED+"         MISMATCH        "+CEND)
    print("+++++++++++++++++++++++++++++")
  else:
    print("+++++++++++++++++++++++++++++")
    print(CGREEN+"         FULL MATCH        "+CEND)
    print("+++++++++++++++++++++++++++++")

