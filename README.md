# Building/Simulating the Summer Chain #

This repository contains the payload project for the Hybrid Summer Chain - compatible with the extensible, modular firmware framework for phase-2 upgrades.

The project can be built against multiple boards, but has so far been implemented for the Apollo (VU7P) and Serenity (KU15P).

## Quick start instructions for developers ##

Make sure that the [Prerequisites](#prerequisites) are satisfied.

##### Step 1: Setup the work area

```
ipbb init work
cd work
kinit myusername@CERN.CH
ipbb add git https://:@gitlab.cern.ch:8443/p2-xware/firmware/emp-fwk.git -b feature/apollo
ipbb add git https://github.com/apollo-lhc/CM_FPGA_FW -b v1.2
cd src/CM_FPGA_FW; make init; cd -
ipbb add git https://gitlab.cern.ch/ttc/legacy_ttc.git -b v2.1
ipbb add git https://:@gitlab.cern.ch:8443/cms-tcds/cms-tcds2-firmware.git -b v0_1_1
ipbb add git https://gitlab.cern.ch/HPTD/tclink.git -r fda0bcf
ipbb add git https://github.com/ipbus/ipbus-firmware -b v1.9
ipbb add git https://github.com/cms-L1TK/l1tk-for-emp.git
```

*Note: You need to be a member of the `cms-tcds2-users` egroup in order to clone the `cms-tcds2-firmware` repository. In order to add yourself to that egroup, go to the "Members" tab of [this page](https://e-groups.cern.ch/e-groups/Egroup.do?egroupId=10380295), and click on the "Add me" button; you may need to wait ~ 24 hours to get access to the GitLab repo.*

##### Step 2: Create an ipbb project area

There is currently two available projects

| Description                                              | `.dep` file name                  |
| -------------------------------------------------------- | --------------------------------- |
| Hybrid Summer Chain                                      | `serenity.dep`                    |
| Hybrid Summer Chain                                      | `apollo.dep`                      |

The project area for Hybrid Summer Chain can be created as follows.

For implementation:
```
ipbb proj create vivado tracklet l1tk-for-emp:tracklet 'apollo.dep'
cd proj/tracklet
```

For questa simulation testbench:
```
ipbb proj create sim qsim l1tk-for-emp:tracklet 'qsim.dep'
ln -s ../src/l1tk-for-emp/tracklet/firmware/emData/ proj/
cd proj/qsim
```

For vivado simulation testbench:
```
ipbb proj create sim vsim l1tk-for-emp:tracklet 'vsim.dep'
ln -s ../src/l1tk-for-emp/tracklet/firmware/emData/ proj/
cd proj/vsim
```

##### Step 3: Implementation and simulation


For implementation:
Note: For the following commands, you need to ensure that can find & use the `gen_ipbus_addr_decode` script - e.g. for a standard uHAL installation:
```
export PATH=/opt/cactus/bin/uhal/tools:$PATH LD_LIBRARY_PATH=/opt/cactus/lib:$LD_LIBRARY_PATH
```
Run the following IPBB commands:
```
ipbb ipbus gendecoders
ipbb vivado generate-project synth -j8 impl -j8 package
```

For questa simulation testbench:
```
ipbb sim setup-simlib
ipbb sim ipcores
ipbb sim generate-project (rerun this if you change VHDL)

./run_sim -c work.top -Gsourcefile=<input.txt> -Gsinkfile=<out.txt> -Gplaylen=xyz -Gcaplen=xyz -do 'run 50.0us' -do quit 
  (where xyz = number of events * 108, where default is 9 events).
```
where `input.txt` follows the standard EMP pattern file convention. 
To create input.txt from InputRouter input files in emData/, run in work/proj/

```
python3 ../src/l1tk-for-emp/script/convert_emData2EMP_Link.py
```

*N.B.* The Xilinx simulation libraries can be shared between different ipbb projects and work areas. By default they are written to `${HOME}/.xilinx_sim_libs`, but they can be written to another directory by defining the environment variable `IPBB_SIMLIB_BASE` before running these two commands, or by adding the `-x` option to end of each command (e.g. `-x /path/to/simlib_directory`).

For vivado simulation testbench:
```
ipbb vivado generate-project
```
and open the project with vivado gui for simulation.

## Comparison with emulation ##

Aside from doing this in CMSSW (for up to 9 consecutive events), can do in proj/work/ 

```
# Convert emulated TrackBuilder output file in emData/ to EMP format
python3 ../src/l1tk-for-emp/script/convert_emData2EMP_FT.py
# Compare this corresponding file from VHDL test-bench 
python3 ../src/l1tk-for-emp/script/compareEMP_FT.py
```


## Prerequisites ##

 * Xilinx Vivado 2020.2 (or later)
 * Python 2.7 - available on most linux distributions, natively or as [miniconda](https://conda.io/miniconda.html) distribution.
 * Python 3 devel
 * ipbb: `dev/2021i` pre-release or greater - the [IPbus Builder Tool](https://github.com/ipbus/ipbb). Note: a single `ipbb` installation is not work area specific and suffices for any number of projects.
 
```
curl -L https://github.com/ipbus/ipbb/archive/dev/2021j.tar.gz | tar xvz
source ipbb-dev-2021i/env.sh
(or if you use tcsh:  bash -c 'source ipbb-dev-2021i/env.sh; tcsh -l')
```

## Guide to firmware ##

````
UTILITIES

common/firmware/hdl/hybrid_config.vhd
  Cfg params (#PS DTC, #2S DTC, num layers ...)

common/firmware/hdl/hybrid_data_formats.vhd:
  Defines tracking bit widths

common/firmware/hdl/hybrid_data_types.vhd:
  Defines tracker data types.

common/firmware/hdl/hybrid_tools.vhd
  Defines functions

/emp-fwk/components/datapath/firmware/hdl/emp_data_types.vhd
/emp-fwk/components/ttc/firmware/hdl/emp_ttc_decl.vhd:
  Define EMP data types (ldata=64b data, start, valid)

CODE

tracklet/ & trackletIP/ are equivalent, but latter uses HLS IP cores, whereas former instead includes VHDL generated by HLS compiler (faster compilation).
N.B. tracklet/ version has more comments in code.

emp_payload.vhd:
  Top-level: converts EMP links I/O data (format ldata) to/from formats t_stubsDTC (hybrid DTC stub format for PS & 2S) / t_trackTracklet (hybrid tracklet format), and calls hybrid_tracklet to run L1 tracking.

````
