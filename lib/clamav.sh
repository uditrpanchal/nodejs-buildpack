
setup_clamav(){
    echo "pre-install"
    local build_dir=${1:-}
    local old_dir=$(pwd)
    cd $build_dir

    echo "getting clamav source"
    curl --silent -Lo clamav.tar.gz https://www.clamav.net/downloads/production/clamav-0.99.2.tar.gz 
    tar xvf clamav.tar.gz > /dev/null

    echo "getting llvm source"
    curl --silent -o llvm.tar.xz http://releases.llvm.org/3.6.0/clang+llvm-3.6.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz 
    tar xvf llvm.tar.xz  > /dev/null
      
    echo "configre clamav"
    cd clamav-0.99.2
    ./configure --with-user=vcap --prefix=$build_dir/clamav --disable-clamav --with-system-llvm=$build_dir/clang+llvm-3.6.0-x86_64-linux-gnu/bin/llvm-config  > /dev/null

    echo "compile clamav"
    make >  /dev/null

    echo "install clamav"
    make install > /dev/null

    echo " making dir for cvds"
    mkdir -p $build_dir/clamav/share/clamav/

    echo "post-install"
    cd $old_dir

    echo "cleanning clamav residue"
    rm $build_dir/clamav.tar.gz
    rm -rf $build_dir/clamav-0.99.2
    rm $build_dir/llvm.tar.xz
    rm -rf $build_dir/clang+llvm-3.6.0-x86_64-linux-gnu

    echo "config freshclam and clam daemon"
    if [ -f $build_dir/freshclam.conf ]
    then
        mv $build_dir/freshclam.conf $build_dir/clamav/etc/freshclam.conf
    else
        mv $build_dir/clamav/etc/freshclam.conf.sample $build_dir/clamav/etc/freshclam.conf
        sed -i 's/^Foreground .*$/Foreground true/g' $build_dir/clamav/etc/freshclam.conf
        sed -i 's/^Example *$//g'  $build_dir/clamav/etc/freshclam.conf
    fi

    if [ -f $build_dir/clamd.conf ]
    then
        mv $build_dir/clamd.conf $build_dir/clamav/etc/clamd.conf
        sed -i
    else
        mv $build_dir/clamav/etc/clamd.conf.sample $build_dir/clamav/etc/clamd.conf
        echo "TCPSocket 3310" >> $build_dir/clamav/etc/clamd.conf
        sed -i 's/^Foreground .*$/Foreground true/g' $build_dir/clamav/etc/clamd.conf
        sed -i 's/^Example *$//g' $build_dir/clamav/etc/clamd.conf
    fi


    echo "Getting virus database using freshclam"
    $build_dir/clamav/bin/freshclam

}


create_symbol_link(){
   local build_dir=${1:-}
   ln -s libclamav.so.7.1.1 $build_dir/clamav/lib/libclamav.so 
   ln -s lib/libclamav.so.7.1.1 $build_dir/clamav/lib/libclamav.so.7 
   ln -s libclamunrar_iface.so.7.1.1 $build_dir/clamav/lib/ibclamunrar_iface.so
   ln -s libclamunrar_iface.so.7.1.1 $build_dir/clamav/lib/libclamunrar_iface.so.7
   ln -s libclamunrar.so.7.1.1  $build_dir/clamav/lib/libclamunrar.so.7
   ln -s lib/libclamunrar.so.7.1.1  $build_dir/clamav/lib/libclamunrar.so
   mkdir -p $build_dir/clamav/share/clamav

}