#!/bin/bash

SCRIPT_DIR=`dirname ${BASH_SOURCE[0]}`
STOP=""

function execute() 
{
    if [ -z "$STOP" ]; then
        echo -n $@ " ... "
        out=$($@ 2>&1)
        ret=$?

        if [ $ret -eq 0 ]; then
            echo "ok"
        else
            echo "error"
            STOP=$out
            return 1
        fi
    fi
}

function run_setup()
{
    if [[  -z  $1  ]] ; then
        echo 'Usage:'
        echo '  setupEnv_cpuonly.sh <install_dir>'
        return 1
    fi

    dist=`grep DISTRIB_ID /etc/*-release | awk -F '=' '{print $2}'`

    if [ "$dist" != "Ubuntu" ]; then
        if [[ `uname -r` != *".el7."* ]]; then
            echo "EL 7 required - try different node!, e.g. lx03 (imperial) or lxplus005 (CERN)"
            return 1
        fi
    fi

    INSTALL_DIR=$1

    if [ -d "$1" ]; then
        echo "Error - directory "$INSTALL_DIR" exists!"
        return 1
    fi
    echo "Setting up central environment for training under "$INSTALL_DIR

    execute mkdir $INSTALL_DIR || return 1
    
    INSTALL_ABSDIR=`readlink -e $INSTALL_DIR`

    if [ ! -d "$1" ]; then
        echo "Error - failed to create directory "$INSTALL_ABSDIR"!"
        return 1
    fi

    execute wget -P $INSTALL_ABSDIR https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh || return 1
    execute bash $INSTALL_ABSDIR/Miniconda2-latest-Linux-x86_64.sh -b -s -p $INSTALL_ABSDIR/miniconda || return 1

    CONDA_BIN=$INSTALL_ABSDIR/miniconda/bin
    export PATH=$CONDA_BIN:$PATH
    
    conda update -n base conda --yes || return 1
    
    export TMPDIR=$INSTALL_ABSDIR/tmp
    export TMPPATH=$TMPDIR
    export TEMP=$TMPDIR
    mkdir $TMPDIR
   
    
    echo "Create environment for CPU"
    #rm -f /tmp/*
    
    conda create -n tf_cpu python=2.7 --yes || return 1
    source activate tf_cpu || return 1
    
    echo "Installing compilers"
    conda install gcc_linux-64 --yes || return 1
    conda install gxx_linux-64 --yes || return 1
    conda install gfortran_linux-64 --yes || return 1
    source deactivate || return 1
    
    echo "Installing packages"
    source activate tf_cpu || return 1
    conda install cmake=3.9.4 --yes || return 1
    conda install -c nlesc root-numpy=4.4.0 --yes || return 1
    conda install -c conda-forge boost=1.64.0 --yes || return 1
    pip install --no-cache-dir -r $SCRIPT_DIR/packages_cpu.pip || return 1
    
    echo "export PATH="$INSTALL_ABSDIR"/miniconda/bin:\$PATH" > $SCRIPT_DIR/env_cpu.sh
    #echo "export LD_PRELOAD="$INSTALL_ABSDIR"/miniconda/lib/libmkl_core.so:"$INSTALL_ABSDIR"/miniconda/lib/libmkl_sequential.so:\$LD_PRELOAD" >> $SCRIPT_DIR/env_cpu.sh
    echo "source activate tf_cpu" >> $SCRIPT_DIR/env_cpu.sh
    
    conda list
    pip list

    source deactivate || return 1
    
    rm -rf $INSTALL_ABSDIR/tmp

}

run_setup $1



#export PATH=$CONDA_BIN:$PATH

#git clone https://github.com/matt-komm/DeepJet.git

#cd DeepJet/environment

#echo "Setting up CPU usage"
#./setupEnv.sh deepjetLinux3.conda

#echo "Setting up GPU usage"
#./setupEnv.sh deepjetLinux3.conda gpu
