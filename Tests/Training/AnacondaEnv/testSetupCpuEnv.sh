
function execute() 
{
    ./Training/AnacondaEnv/setupEnv_cpuonly.sh Training/AnacondaEnv/testenv || return 1
    source Training/AnacondaEnv/env.sh || return 1
    source activate tf_cpu || return 1
    python -c "import tensorflow as tf"
    python -c "import keras"
}

execute
