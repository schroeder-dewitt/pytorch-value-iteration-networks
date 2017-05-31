#!/usr/bin/env bash

# set environment variables

# load modules

#cd {{ lib_dir }} && export PYTHONPATH=`pwd`:$PYTHONPATH
#cd {{ exp_dir }} && export PYTHONPATH=`pwd`:$PYTHONPATH

export PATH="/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
export PYTHONPATH="{{ lib_dir }}":$PYTHONPATH
export PYTHONPATH="{{ exp_dir }}":$PYTHONPATH
export PYTHONPATH="/root/cmap":$PYTHONPATH
export LD_LIBRARY_PATH="/usr/local/nvidia/lib:/usr/local/nvidia/lib64"



# nvidia-smi > nvidia.log

cd {{ exp_dir }}

# run the application
{{ run_application}} 2>stderr.out >stdout.out
