
setup_clamav(){
    echo "pre-install"
    local build_dir=${1:-}
    local old_dir=$(pwd)
    cd $build_dir

    echo "getting clamav source"
    curl --silent -Lo clamav.tar.gz https://www.clamav.net/downloads/production/clamav-0.99.2.tar.gz 
    tar xf clamav.tar.gz 

    echo "getting llvm source"
    curl --silent -o llvm.tar.xz http://releases.llvm.org/3.6.0/clang+llvm-3.6.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz 
    tar xf llvm.tar.xz  
      
    echo "configre clamav"
    cd clamav-0.99.2
    ./configure --with-user=vcap --prefix=$HOME/app/clamav --disable-clamav --with-system-llvm=$build_dir/clang+llvm-3.6.0-x86_64-linux-gnu/bin/llvm-config  > /dev/null

    echo "compile clamav"
    make >  /dev/null

    echo "install clamav"
    make install > /dev/null

    echo " making dir for cvds"
    mkdir -p $HOME/app/clamav/share/clamav/

    echo "post-install"
    cd $old_dir

    echo "cleanning clamav residue"
    rm $build_dir/clamav.tar.gz
    rm -rf $build_dir/clamav-0.99.2
    rm $build_dir/llvm.tar.xz
    rm -rf $build_dir/clang+llvm-3.6.0-x86_64-linux-gnu

}

config_clamav(){

    local build_dir=${1:-}

    echo "config freshclam and clam daemon"
    if [ -f $build_dir/clamd.conf ]
    then
        mv $build_dir/clamd.conf  $HOME/app/clamav/etc/clamd.conf
    else
        echo "TCPSocket 3310" >  $HOME/app/clamav/etc/clamd.conf
        echo "Foreground true" >>  $HOME/app/clamav/etc/clamd.conf
        echo "SelfCheck 3600" >> $HOME/app/clamav/etc/clamd.conf
        echo "LogFile $HOME/app/clamav/etc/clamav.log" >> $HOME/app/clamav/etc/clamd.conf
        echo "LogFileMaxSize 100M" >>  $HOME/app/clamav/etc/clamd.conf
        echo "LogTime true" >> $HOME/app/clamav/etc/clamd.conf
        echo "LogVerbose true" >> $HOME/app/clamav/etc/clamd.conf   
    fi

    if [ -f $build_dir/freshclam.conf ]
    then
        mv $build_dir/freshclam.conf $HOME/app/clamav/etc/freshclam.conf
    else
        echo "Foreground true" > $HOME/app/clamav/etc/freshclam.conf
        echo "NotifyClamd $HOME/app/clamav/etc/clamd.conf" >> $HOME/app/clamav/etc/freshclam.conf
        echo "DatabaseMirror db.ca.clamav.net" >> $HOME/app/clamav/etc/freshclam.conf
        echo "DatabaseMirror database.clamav.net" >> $HOME/app/clamav/etc/freshclam.conf
    fi

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
   ln -s libclamav.so.7.1.1 $build_dir/clamav/lib/libclamav.so 
   ln -s libclamav.so.7.1.1 $build_dir/clamav/lib/libclamav.so.7 
   ln -s libclamunrar_iface.so.7.1.1 $build_dir/clamav/lib/ibclamunrar_iface.so
   ln -s libclamunrar_iface.so.7.1.1 $build_dir/clamav/lib/libclamunrar_iface.so.7
   ln -s libclamunrar.so.7.1.1  $build_dir/clamav/lib/libclamunrar.so.7
   ln -s libclamunrar.so.7.1.1  $build_dir/clamav/lib/libclamunrar.so
   mkdir -p $build_dir/clamav/share/clamav

}