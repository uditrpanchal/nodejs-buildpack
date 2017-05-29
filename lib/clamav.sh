
get_source(){
    echo "getting clamav source"
    local build_dir=${1:-}
    local old_dir=$(pwd)
    cd $build_dir
    curl --silent -Lo clamav.tar.gz https://www.clamav.net/downloads/production/clamav-0.99.2.tar.gz 
    tar xvf clamav.tar.gz > /dev/null
    cd $old_dir
}



get_llvm(){
       echo "getting llvm source"
       local build_dir=${1:-}
       local old_dir=$(pwd)
       cd $build_dir
       curl --silent -o llvm.tar.xz http://releases.llvm.org/3.6.0/clang+llvm-3.6.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz 
       tar xvf llvm.tar.xz  > /dev/null
       cd $old_dir
}

configure(){
     echo "configre clamav"
    local build_dir=${1:-}
     local old_dir=$(pwd)
    cd $build_dir/clamav-0.99.2
    ./configure --with-user=vcap --prefix=/home/vcap/clamav --disable-clamav --with-system-llvm=$build_dir/clang+llvm-3.6.0-x86_64-linux-gnu/bin/llvm-config  > /dev/null
    cd $old_dir
}

compile(){
      echo "compile clamav"
     local build_dir=${1:-}
     local old_dir=$(pwd)
     cd $build_dir/clamav-0.99.2
     make
     cd $old_dir
}

install(){
    echo "install clamav"
    local build_dir=${1:-}
    local old_dir=$(pwd)
    cd $build_dir/clamav-0.99.2 
    make install
    cd $old_dir
}

clean(){
      local build_dir=${1:-}
    local old_dir=$(pwd)
    cd $build_dir
    rm clamav.tar.gz
    rm -rf clamav-0.99.2
    rm llvm.tar.xz
    rm -rf clang+llvm-3.6.0-x86_64-linux-gnu
    cd old_dir
}
get_clamav_cvds(){
    echo " get cvds"
    local build_dir=${1:-}
    mkdir -p  /home/vcap/clamav/share/clamav/
    wget -O  /home/vcap/clamav/share/clamav/main.cvd http://database.clamav.net/main.cvd
    wget -O  /home/vcap/clamav/share/clamav/daily.cvd http://database.clamav.net/daily.cvd
    wget -O  /home/vcap/clamav/share/clamav/bytecode.cvd http://database.clamav.net/bytecode.cvd
}

