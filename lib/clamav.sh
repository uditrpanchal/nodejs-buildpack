
setup_clamav(){
    echo "pre-install"
    local build_dir=${1:-}
    local old_dir=$(pwd)
    # cd $build_dir

    # echo "getting clamav source"
    # curl --silent -Lo clamav.tar.gz https://www.clamav.net/downloads/production/clamav-0.99.2.tar.gz 
    # tar xvf clamav.tar.gz > /dev/null

    # echo "getting llvm source"
    # curl --silent -o llvm.tar.xz http://releases.llvm.org/3.6.0/clang+llvm-3.6.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz 
    # tar xvf llvm.tar.xz  > /dev/null
      
    # echo "configre clamav"
    # cd clamav-0.99.2
    # ./configure --with-user=vcap --prefix=$build_dir/clamav --disable-clamav --with-system-llvm=$build_dir/clang+llvm-3.6.0-x86_64-linux-gnu/bin/llvm-config  > /dev/null

    # echo "compile clamav"
    # make >  /dev/null

    # echo "install clamav"
    # make install > /dev/null

    # echo " making dir for cvds"
    # mkdir -p $build_dir/clamav/share/clamav/

    # echo "post-install"
    # cd $old_dir

    # echo "cleanning clamav residue"
    # rm $build_dir/clamav.tar.gz
    # rm -rf $build_dir/clamav-0.99.2
    # rm $build_dir/llvm.tar.xz
    # rm -rf $build_dir/clang+llvm-3.6.0-x86_64-linux-gnu

    mkdir $build_dir/clamav
}

