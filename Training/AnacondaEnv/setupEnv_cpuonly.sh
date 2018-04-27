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
    echo "STATUS: Script directory "$SCRIPT_DIR
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
    echo "STATUS: Setting up central environment under "$INSTALL_DIR

    execute mkdir $INSTALL_DIR || return 1
    
    INSTALL_ABSDIR=`readlink -e $INSTALL_DIR`

    if [ ! -d "$1" ]; then
        echo "Error - failed to create directory "$INSTALL_ABSDIR"!"
        return 1
    fi

    execute wget -P $INSTALL_ABSDIR https://repo.continuum.io/miniconda/Miniconda2-4.3.31-Linux-x86_64.sh || return 1
    execute bash $INSTALL_ABSDIR/Miniconda2-4.3.31-Linux-x86_64.sh -b -s -p $INSTALL_ABSDIR/miniconda || return 1

    CONDA_BIN=$INSTALL_ABSDIR/miniconda/bin
    export PATH=$CONDA_BIN:$PATH
    
    #conda update -n base conda --yes || return 1
    
    export TMPDIR=$INSTALL_ABSDIR/tmp
    export TMPPATH=$TMPDIR
    export TEMP=$TMPDIR
    mkdir $TMPDIR
   
    
    echo "STATUS: Create environment for CPU"
    #rm -f /tmp/*
    
    conda create -n tf_cpu python=2.7 --yes || return 1
    source activate tf_cpu || return 1
    
    #pip install tensorflow==1.6.0 || return 1
    #conda install -c conda-forge cmake --yes || return 1
    #conda install -c nlesc root-numpy=4.4.0 --yes || return 1
    #conda install -c conda-forge boost=1.64.0 --yes || return 1
    echo "STATUS: Installing root"
    conda install -c nlesc root-numpy=4.4.0 --yes || return 1
    echo "STATUS: Installing pip packages"
    pip install --no-cache-dir -r $SCRIPT_DIR/packages_cpu.pip || return 1
    
    echo "export PATH="$INSTALL_ABSDIR"/miniconda/bin:\$PATH" > env_cpu.sh
    #echo "export LD_PRELOAD="$INSTALL_ABSDIR"/miniconda/lib/libmkl_core.so:"$INSTALL_ABSDIR"/miniconda/lib/libmkl_sequential.so:\$LD_PRELOAD" >> $SCRIPT_DIR/env_cpu.sh
    echo "source activate tf_cpu" >> env_cpu.sh

    echo "STATUS: Create script for environment: env_cpu.sh "`ll env_cpu.sh`

    source deactivate || return 1
    
    rm -rf $INSTALL_ABSDIR/tmp

}

run_setup $1


