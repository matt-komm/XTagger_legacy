#!/bin/bash

function execute() 
{
    source Training/AnacondaEnv/setupEnv_cpuonly.sh "testenv"
    source env_cpu.sh || return 1
    source activate tf_cpu || return 1
    python Tests/Training/AnacondaEnv/testKeras.py || return 1
    source deactivate tf_cpu || return 1
}

execute
