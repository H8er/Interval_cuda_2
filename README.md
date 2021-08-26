Use:
To receive calculated file and do not visualize data - run "bash calc"
To calcuate and visualize 2d pitcure - "bash full"
To visualize 3d object - calculate with "bash calc" then visualize with "cube.py < in_gpu.txt"

File list:
1.cu - main file to compile
"calc" and "full" - bash scripts to simplify compilation/run
cuda_check_error.cu - as the nema says - some functionality to catch errors on gpu
cuda_interval_lib.h and cuda_interval_rounded_arythmetics - slightly modified Nvidia's library for interval calculations
functions.cu - file with arythmetic functions to analyze/calculate on gpu
