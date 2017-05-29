
get_source(){
    echo "getting clamav source"
    local build_dir=${1:-}
    curl -Lo $build_dir/clamav.tar.gz https://www.clamav.net/downloads/production/clamav-0.99.2.tar.gz > /dev/null
    tar xvf $build_dir/clamav.tar.gz -C $build_dir/ > /dev/null
}



get_llvm(){
       echo "getting llvm source"
       local build_dir=${1:-}
       curl -o $build_dir/llvm.tar.xz http://releases.llvm.org/3.6.0/clang+llvm-3.6.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz > /dev/null
       tar xvf $build_dir/llvm.tar.xz -C $build_dir/ > /dev/null
}

configure(){
     echo "configre clamav"
    local build_dir=${1:-}
    $build_dir/clamav-0.99.2/configure --with-user=vcap --prefix=/home/vcap/app/clamav --disable-clamav --with-system-llvm=$build_dir/clang+llvm-3.6.0-x86_64-linux-gnu/bin/llvm-config  > /dev/null

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

get_clamav_cvds(){
    echo " get cvds"
    local build_dir=${1:-}
    mkdir -p $build_dir/clamav/share/clamav/
    wget -O $build_dir/clamav/share/clamav/main.cvd http://database.clamav.net/main.cvd
    wget -O $build_dir/clamav/share/clamav/daily.cvd http://database.clamav.net/daily.cvd
    wget -O $build_dir/clamav/share/clamav/bytecode.cvd http://database.clamav.net/bytecode.cvd
}

create_symbol_link(){
    echo "create symbolic link for libs"
   local build_dir=${1:-}
   ln -s /home/vcap/app/clamav/lib/libclamav.so.7.1.1 $build_dir/clamav/lib/libclamav.so 
   ln -s /home/vcap/app/clamav/lib/libclamav.so.7.1.1 $build_dir/clamav/lib/libclamav.so.7 
   ln -s /home/vcap/app/clamav/lib/libclamunrar_iface.so.7.1.1 $build_dir/clamav/lib/ibclamunrar_iface.so
   ln -s /home/vcap/app/clamav/lib/libclamunrar_iface.so.7.1.1 $build_dir/clamav/lib/libclamunrar_iface.so.7
   ln -s /home/vcap/app/clamav/lib/libclamunrar.so.7.1.1  $build_dir/clamav/lib/libclamunrar.so.7
   ln -s /home/vcap/app/clamav/lib/libclamunrar.so.7.1.1  $build_dir/clamav/lib/libclamunrar.so

}
