
function execute() 
{
    mkdir Training/Ops/build || return 1
    cd Training/Ops/build || return 1
    cmake .. || return 1
    make || return 1
}

execute
