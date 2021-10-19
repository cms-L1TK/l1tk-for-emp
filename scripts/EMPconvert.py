import argparse
import os

def parseArguments():
    # Create argument parser
    parser = argparse.ArgumentParser(description="Convert a IR input dat file into a EMP input file. Link-file mapping is done editing the header of the scirpt.")

 
    # Optional arguments
    parser.add_argument("-e", "--event", dest="EVENT_NUM", help="EMP event number", type=int, default=0)

    # Parse arguments
    args = parser.parse_args()

    return args

mapping = {}
mapping[0] = ["q00c0","000","Link_DL_PS10G_1_A_04.dat"]
mapping[1] = ["q00c1","001","Link_DL_PS10G_2_A_04.dat"]
mapping[2] = ["q00c2","002","Link_DL_PS10G_2_B_04.dat"]
mapping[3] = ["q00c3","003","Link_DL_PS10G_3_A_04.dat"]
mapping[4] = ["q01c0","004","Link_DL_PS10G_3_B_04.dat"]
mapping[5] = ["q01c1","005","Link_DL_PS_1_A_04.dat"]
mapping[6] = ["q01c2","006","Link_DL_PS_1_B_04.dat"]
mapping[7] = ["q01c3","007","Link_DL_PS_2_A_04.dat"]
mapping[8] = ["q02c0","008","Link_DL_PS_2_B_04.dat"]
mapping[9] = ["q02c1","009", "Link_DL_2S_1_A_04.dat"]
mapping[10] = ["q02c2","010", "Link_DL_2S_1_B_04.dat"]
mapping[11] = ["q02c3","011", "Link_DL_2S_2_A_04.dat"]
mapping[12] = ["q03c0","012", "Link_DL_2S_2_B_04.dat"]
mapping[13] = ["q03c1","013", "Link_DL_2S_3_A_04.dat"]
mapping[14] = ["q03c2","014", "Link_DL_2S_3_B_04.dat"]
mapping[15] = ["q03c3","015", "Link_DL_2S_4_A_04.dat"]
mapping[16] = ["q04c0","016", "Link_DL_2S_4_B_04.dat"]
mapping[18] = ["q06c1","025",""]
mapping[19] = ["q06c2","026",""]
mapping[20] = ["q06c3","027",""]
mapping[21] = ["q12c0","048",""]
mapping[22] = ["q12c1","049",""]
mapping[23] = ["q12c2","050",""]
mapping[24] = ["q12c3","051",""]
mapping[25] = ["q13c0","052",""]
mapping[26] = ["q13c1","053",""]
mapping[27] = ["q13c2","054",""]
mapping[28] = ["q13c3","055",""]
mapping[29] = ["q15c0","060",""]
mapping[30] = ["q15c1","061",""]
mapping[31] = ["q15c2","062",""]
mapping[32] = ["q15c3","063",""]
mapping[33] = ["q16c0","064",""]
mapping[34] = ["q16c1","065",""]
mapping[35] = ["q16c2","066",""]
mapping[36] = ["q16c3","067",""]
mapping[37] = ["q17c0","068",""]
mapping[38] = ["q17c1","069",""]
mapping[39] = ["q17c2","070",""]
mapping[40] = ["q17c3","071",""]

if __name__ == '__main__':

   args = parseArguments()

   input_dict = {}

   for idx in mapping:
      if mapping[idx][2]!="":
         file = open(mapping[idx][2], 'r')
         lines = file.readlines()
         input_data = []
         event_temp = []
         for line in lines:
            line_array = line.split()
            if len(line_array) == 6:
               event_temp = line_array
            if len(line_array) == 3:
               event_temp2 = [i for i in event_temp] 
               event_temp2.append(line_array[0])
               event_temp2.append(line_array[2])
               input_data.append(event_temp2)
         #print(input_data)
         input_dict[idx]=input_data


   print("Board apollo.c2c.vu7p")
   print(" Quad/Chan :",end="        ") 
   for idx in mapping:
      if mapping[idx][2]!="":
         print(mapping[idx][0],end="              ")
   print(" ")

   print("      Link :",end="         ")
   for idx in mapping:
      if mapping[idx][2]!="":
         print(mapping[idx][1],end="                ")
   print(" ")

   #
   # finds the initial frame for an event for each input file
   #
   offsets = {}

   for idx in mapping:
      if mapping[idx][2]!="":
         for jdx,frame in enumerate(input_dict[idx]):
            if int(frame[5])==args.EVENT_NUM and (idx not in offsets.keys()):
               offsets[idx]=jdx

   #
   #generates the output text
   #
   # 6 Empty frames to let the FW understanding it's a new events
   for frame_id in range(0,6):
      print("Frame "+str(frame_id).zfill(4)+" : ",end="")
      for idx in mapping:
         if mapping[idx][2]!="":
            print("0v0000000000000000",end=" ")
      print(" ")
   # here the real frames
   for frame_id in range(6,102):
      print("Frame "+str(frame_id).zfill(4)+" : ",end="")
      for idx in mapping:
         if mapping[idx][2]!="":
            if input_dict[idx]==[]:
               print("1v0000000000000000",end=" ")
               continue
            if (len(input_dict[idx])>frame_id+offsets[idx]) and int(input_dict[idx][frame_id +  offsets[idx] ][5])==args.EVENT_NUM:
               output = ((int(input_dict[idx][frame_id + offsets[idx] ][2],base=2)&7)<<61)+(((int(input_dict[idx][frame_id +  offsets[idx] ][5]))&0xfffff)<<41)+int(input_dict[idx][frame_id +  offsets[idx] ][7],base=16)
               print("1v"+hex(output)[2:].rstrip("L").zfill(16),end=" ")
            else:
               print("1v0000000000000000",end=" ")
      print(" ")

