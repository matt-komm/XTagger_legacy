
function execute() 
{
    source Training/AnacondaEnv/env.sh || return 1
    source activate tf_cpu || return 1
    mkdir Training/Ops/build || return 1
    cd Training/Ops/build || return 1
    cmake .. || return 1
    make || return 1
}

execute
