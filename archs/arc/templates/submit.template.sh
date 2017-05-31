#!/usr/bin/env bash

# set gpu mode
#SBATCH --partition={{ partition }}

# set the number of nodes
#SBATCH --nodes=1

# set max wallclock time
#SBATCH --time=100:00:00

# set name of job
#SBATCH --job-name={{ job_name }}

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=cs@robots.ox.ac.uk

# set environment variables

# load modules

{{ load_modules }}

#module load cuda/8.0.44
module load gpu/cuda/8.0.44
# module load python/3.5
module load python/anaconda3/4.3.0
module load vizdoom/1.1.1/python3
module load cmake/3.8.0

# activate conda
#source {{ venv_path }}/{{ venv_name }}/bin/activate
source activate cmap

{{ set_env_variables }}

cd {{ lib_dir }} && export PYTHONPATH=`pwd`:$PYTHONPATH
cd {{ exp_dir }} && export PYTHONPATH=`pwd`:$PYTHONPATH

# run the application
{{ run_application}}
