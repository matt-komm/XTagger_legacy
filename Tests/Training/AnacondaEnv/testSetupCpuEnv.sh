
function execute() 
{
    ./Training/AnacondaEnv/setupEnv_cpuonly.sh testenv || return 1
    source Training/AnacondaEnv/env.sh || return 1
    python -c "import tensorflow as tf"
    python -c "import keras"
}

execute
