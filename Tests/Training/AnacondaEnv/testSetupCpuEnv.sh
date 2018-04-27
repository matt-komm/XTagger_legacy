
function execute() 
{
    source Training/AnacondaEnv/setupEnv_cpuonly.sh "testenv"  2>&1 | tee env.build | grep STATUS
    if [ $? -eq 0 ]
    then
      echo "Successfully setup environment"
    else
      tail -n 300 env.build
      return 1
    fi
    ll -h Training/AnacondaEnv
    source Training/AnacondaEnv/env_cpu.sh || return 1
    source activate tf_cpu || return 1
    python Tests/Training/AnacondaEnv/testKeras.py || return 1
    source deactivate tf_cpu || return 1
}

execute
