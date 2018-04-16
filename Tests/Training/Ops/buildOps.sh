
function execute() 
{
    source Training/AnacondaEnv/env_cpu.sh || return 1
    mkdir Training/Ops/build || return 1
    cd Training/Ops/build || return 1
    cmake .. || return 1
    make || return 1
}

execute
