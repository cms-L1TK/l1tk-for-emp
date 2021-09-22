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

For simulation testbench:
```
ipbb proj create sim sim l1tk-for-emp:tracklet 'sim.dep'
ln -s src/l1tk-for-emp/tracklet/firmware/emData/ proj/
cd proj/sim
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

For simulation testbench:
```
ipbb sim setup-simlib
ipbb sim generate-project

./vsim -c work.top -Gsourcefile=<input.txt> -Gsinkfile=<out.txt> 
```
where `input.txt` follows the standard pattern file convention.
*N.B.* The Xilinx simulation libraries can be shared between different ipbb projects and work areas. By default they are written to `${HOME}/.xilinx_sim_libs`, but they can be written to another directory by defining the environment variable `IPBB_SIMLIB_BASE` before running these two commands, or by adding the `-x` option to end of each command (e.g. `-x /path/to/simlib_directory`).

## Prerequisites ##

 * Xilinx Vivado 2020.2 (or later)
 * Python 2.7 - available on most linux distributions, natively or as [miniconda](https://conda.io/miniconda.html) distribution.
 * Python 3 devel
 * ipbb: `dev/2021h` pre-release or greater - the [IPbus Builder Tool](https://github.com/ipbus/ipbb). Note: a single `ipbb` installation is not work area specific and suffices for any number of projects.
 
```
curl -L https://github.com/ipbus/ipbb/archive/dev/2021h.tar.gz | tar xvz
source ipbb-dev-2021h/env.sh
(or if you use tcsh:  bash -c 'source ipbb-dev-2021h/env.sh; tcsh -l')
```
