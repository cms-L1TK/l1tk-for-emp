#!/bin/bash
source ~/anaconda3/etc/profile.d/conda.sh

rm -r dir

conda activate tq_test

python conifer_convert.py

cp dir/firmware/AddReduce.vhd ../firmware/hdl/
cp dir/firmware/Arrays0.vhd ../firmware/hdl/
cp dir/firmware/BDT.vhd ../firmware/hdl/
cp dir/firmware/BDTTop.vhd ../firmware/hdl/
cp dir/firmware/Constants.vhd ../firmware/hdl/
cp dir/firmware/Tree.vhd ../firmware/hdl/
cp dir/firmware/Types.vhd ../firmware/hdl/

sed -i 's/\Types\b/BDTTypes/g' ../firmware/hdl/Types.vhd
sed -i 's/\Types\b/BDTTypes/g' ../firmware/hdl/AddReduce.vhd
sed -i 's/\Types\b/BDTTypes/g' ../firmware/hdl/Arrays0.vhd
sed -i 's/\Types\b/BDTTypes/g' ../firmware/hdl/BDT.vhd
sed -i 's/\Types\b/BDTTypes/g' ../firmware/hdl/BDTTop.vhd
sed -i 's/\Types\b/BDTTypes/g' ../firmware/hdl/Tree.vhd