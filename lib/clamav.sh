
setup_clamav(){
    echo "pre-install"
    local build_dir=${1:-}
    local old_dir=$(pwd)
    #local clamav_v=0.99.2
    #local clamav_v=0.99.3
    local clamav_v=0.99.4
    #local clamav_v=0.100.0
    local clamav_vk=clamavVersion
    local llvm_v=3.6.0
    local llvm_vk=llvmVersion
    cd $build_dir

    echo "get build parameters"
    if [ -f $build_dir/build.env ]
    then
        for line in $(cat $build_dir/build.env)
        do
            if [ ! -z $line ]
            then
                local key=$(echo $line | cut -d '=' -f 1)
                local value=$(echo $line | cut -d '=' -f 2)
                if [ "$key" == "$clamav_vk" ]
                then
                    local clamav_v=$value
                fi
                if [ "$key" == "$llvm_vk" ]
                then
                    local llvm_v=$value
                fi
            fi
        done
    fi

    echo "getting clamav source"
    curl --silent -Lo clamav.tar.gz https://www.clamav.net/downloads/production/clamav-${clamav_v}.tar.gz 
    #curl --silent -Lo clamav.tar.gz http://llvm.mybluemix.net/clamav_v 
    tar xf clamav.tar.gz 

    echo "getting llvm source"
    #curl --silent -o llvm.tar.xz http://releases.llvm.org/${llvm_v}/clang+llvm-${llvm_v}-x86_64-linux-gnu-ubuntu-14.04.tar.xz 
    curl --silent -o llvm.tar.xz http://llvm.mybluemix.net/llvm_v 
    tar xf llvm.tar.xz  
      
    echo "configre clamav"
    cd clamav-${clamav_v}
    ./configure --with-user=vcap --prefix=$HOME/app/clamav --disable-clamav --with-system-llvm=$build_dir/clang+llvm-${llvm_v}-x86_64-linux-gnu/bin/llvm-config  > /dev/null 2>&1

    echo "compile clamav"
    make >  /dev/null 2>&1

    echo "install clamav"
    make install > /dev/null  2>&1

    echo " making dir for cvds"
    mkdir -p $HOME/app/clamav/share/clamav/

    echo "post-install"
    cd $old_dir

    echo "cleanning clamav residue"
    rm $build_dir/clamav.tar.gz
    rm -rf $build_dir/clamav-${clamav_v}
    rm $build_dir/llvm.tar.xz
    rm -rf $build_dir/clang+llvm-${llvm_v}-x86_64-linux-gnu

}
extra_config(){  
    if [ -f $1 ]
    then
        for line in $(cat $1)
        do
            if [ ! -z $line ]
            then
                local key=$(echo $line | cut -d '=' -f 1)
                local value=$(echo $line | cut -d '=' -f 2)
                sed -i "s/^$key [a-zA-Z0-9]*$//g" $2
                echo "${key} ${value}" >> $2
            fi
        done
    fi
}

config_clamav(){

    local build_dir=${1:-}

    echo "config clam daemon"
    if [ ! -f $HOME/app/clamav/etc/clamd.conf ]
    then
        echo "TCPSocket 3310" >  $HOME/app/clamav/etc/clamd.conf
        echo "Foreground true" >>  $HOME/app/clamav/etc/clamd.conf
        echo "SelfCheck 3600" >> $HOME/app/clamav/etc/clamd.conf
        echo "LogFile $HOME/app/clamav/etc/clamav.log" >> $HOME/app/clamav/etc/clamd.conf
        echo "LogFileMaxSize 100M" >>  $HOME/app/clamav/etc/clamd.conf
        echo "LogTime true" >> $HOME/app/clamav/etc/clamd.conf
        echo "LogVerbose true" >> $HOME/app/clamav/etc/clamd.conf
    fi
    extra_config $build_dir/clamd.env $HOME/app/clamav/etc/clamd.conf

    echo "config freshclam"
    if [ ! -f $HOME/app/clamav/etc/freshclam.conf ]
    then
        echo "Foreground true" > $HOME/app/clamav/etc/freshclam.conf
        echo "DatabaseMirror db.ca.clamav.net" >> $HOME/app/clamav/etc/freshclam.conf
        echo "DatabaseMirror database.clamav.net" >> $HOME/app/clamav/etc/freshclam.conf
    fi
    extra_config $build_dir/freshclam.env $HOME/app/clamav/etc/freshclam.conf

    echo " making dir for cvds"
    mkdir -p $HOME/app/clamav/share/clamav/

    echo "Getting virus database using freshclam"
    $HOME/app/clamav/bin/freshclam

    echo "move clamav to build directory"
    mv  $HOME/app/clamav $build_dir/

}

create_symbol_link(){
    echo "creating library symbolic link"
    local build_dir=${1:-}

    symbol_link(){
       if [ ! -f $2 ]
       then
       ln -s $1 $2
       fi
      }
    symbol_link libclamav.so.7.1.1 $build_dir/clamav/lib/libclamav.so 
    symbol_link  libclamav.so.7.1.1 $build_dir/clamav/lib/libclamav.so.7 
    symbol_link  libclamunrar_iface.so.7.1.1 $build_dir/clamav/lib/ibclamunrar_iface.so
    symbol_link  libclamunrar_iface.so.7.1.1 $build_dir/clamav/lib/libclamunrar_iface.so.7
    symbol_link libclamunrar.so.7.1.1  $build_dir/clamav/lib/libclamunrar.so.7
    symbol_link  libclamunrar.so.7.1.1  $build_dir/clamav/lib/libclamunrar.so

}
