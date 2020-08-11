#!/bin/bash

wget http://mirror.hust.edu.cn/gnu/mpfr/mpfr-3.1.4.tar.gz          
wget http://mirrors.nju.edu.cn/gnu/mpc/mpc-1.1.0.tar.gz            
wget http://mirrors.nju.edu.cn/gnu/gcc/gcc-7.1.0/gcc-7.1.0.tar.gz  
wget https://ftp.gnu.org/pub/gnu/gmp/gmp-6.1.0.tar.bz2             
if  [[ -f "mpfr-3.1.4.tar.gz" ]] && [[ -f "mpc-1.1.0.tar.gz" ]] && [[ -f "gcc-7.1.0.tar.gz" ]] && [[ -f "gmp-6.1.0.tar.bz2" ]] ;then
    true
else
  echo  "One of mpfr-3.1.4.tar.gz,mpc-1.1.0.tar.gz,gmp-6.1.0.tar.bz2,gcc-7.1.0.tar.gz is missing."
  exit 1
fi

gcc1=`gcc -dumpversion | awk '{split($0,a,"."); print a[1]}'`

if [ $gcc1 -gt 7 ];then
    echo "GCC version is higher than 7, no need to install gcc-7"
    exit 1
fi
    
read -p "Input installation directory for gcc-7--->" gcc7dir
if [ ! -n "$gcc7dir" ]; then
  echo "Wrong: not a valid directory";
  exit 1
fi
mkdir -p $gcc7dir
if [ ! -d "$gcc7dir" ]; then
  echo "Wrong: no permission or not a valid directory."
  exit 1
fi

read -p "To use gcc-7 after installation: source $gcc7dir/env.sh   hit ENTER to continue!" ok

install_needed(){
    echo "installing gmp ..."
    tar -jxvf  gmp-6.1.0.tar.bz2
    cd gmp-6.1.0

    CC=gcc CXX=g++ ./configure --prefix=$gcc7dir/gmp-6.1.0
    make 
    make install
    export GMP_HOME=$gcc7dir/gmp-6.1.0
    export PATH=$GMP_HOME/bin:$PATH
    export LD_LIBRARY_PATH=$GMP_HOME/lib:$LD_LIBRARY_PATH
    export INCLUDE=$GMP_HOME/include:$INCLUDE

    cd ../
    rm -rf gmp-6.1.0

    echo "installing mpfr ..."
    tar -zxvf mpfr-3.1.4.tar.gz
    cd mpfr-3.1.4
    CC=gcc CXX=g++ ./configure --prefix=$gcc7dir/mpfr-3.1.4 --with-gmp=$GMP_HOME
    make 
    make install

    export MPFR_HOME=$gcc7dir/mpfr-3.1.4
    export PATH=$MPFR_HOME/bin:$PATH
    export LD_LIBRARY_PATH=$MPFR_HOME/lib:$LD_LIBRARY_PATH
    export INCLUDE=$MPFR_HOME/include:$INCLUDE

    cd ../
    rm -rf mpfr-3.1.4

    echo "installing mpc ..."
    tar -zxvf mpc-1.1.0.tar.gz
    cd mpc-1.1.0
    CC=gcc CXX=g++ ./configure --prefix=$gcc7dir/mpc-1.1.0 --with-gmp=$GMP_HOME --with-mpfr=$MPFR_HOME
    make 
    make install

    export MPC_HOME=$gcc7dir/mpc-1.1.0
    export PATH=$MPC_HOME/bin:$PATH
    export LD_LIBRARY_PATH=$MPC_HOME/lib:$LD_LIBRARY_PATH
    export INCLUDE=$MPC_HOME/include:$INCLUDE

    cd ../
    rm -rf mpc-1.1.0
}

install_needed

#to prevent LIBRARY_PATH containing the current directory
unset LIBRARY_PATH
echo "installing gcc-7 ..."
tar -zxvf gcc-7.1.0.tar.gz
cd gcc-7.1.0
CC=gcc CXX=g++ ./configure --prefix=$gcc7dir/gcc-7.1.0 --with-gmp=$GMP_HOME --with-mpfr=$MPFR_HOME --with-mpc=$MPC_HOME --disable-multilib --enable-languages=c,c++,fortran

make 
make install
export GCC_HOME=$gcc7dir/gcc-7.1.0
export PATH=$GCC_HOME/bin:$PATH
export LD_LIBRARY_PATH=$GCC_HOME/lib:$GCC_HOME/lib64:$LD_LIBRARY_PATH
export INCLUDE=$GCC_HOME/include:$INCLUDE
cd ../
rm -rf gcc-7.1.0 

echo "export GMP_HOME=$gcc7dir/gmp-6.1.0" >> $gcc7dir/env.sh
echo 'export PATH=$GMP_HOME/bin:$PATH' >> $gcc7dir/env.sh
echo 'export LD_LIBRARY_PATH=$GMP_HOME/lib:$LD_LIBRARY_PATH' >> $gcc7dir/env.sh
echo 'export INCLUDE=$GMP_HOME/include:$INCLUDE' >> $gcc7dir/env.sh
echo "export MPFR_HOME=$gcc7dir/mpfr-3.1.4" >> $gcc7dir/env.sh
echo 'export PATH=$MPFR_HOME/bin:$PATH' >> $gcc7dir/env.sh
echo 'export LD_LIBRARY_PATH=$MPFR_HOME/lib:$LD_LIBRARY_PATH' >> $gcc7dir/env.sh
echo 'export INCLUDE=$MPFR_HOME/include:$INCLUDE' >> $gcc7dir/env.sh
echo "export MPC_HOME=$gcc7dir/mpc-1.1.0" >> $gcc7dir/env.sh
echo 'export PATH=$MPC_HOME/bin:$PATH' >> $gcc7dir/env.sh
echo 'export LD_LIBRARY_PATH=$MPC_HOME/lib:$LD_LIBRARY_PATH' >> $gcc7dir/env.sh
echo 'export INCLUDE=$MPC_HOME/include:$INCLUDE' >> $gcc7dir/env.sh
echo "export GCC_HOME=$gcc7dir/gcc-7.1.0/" >> $gcc7dir/env.sh
echo 'export PATH=$GCC_HOME/bin:$PATH' >> $gcc7dir/env.sh
echo 'export LD_LIBRARY_PATH=$GCC_HOME/lib:$GCC_HOME/lib64:$LD_LIBRARY_PATH' >> $gcc7dir/env.sh
echo 'export INCLUDE=$GCC_HOME/include:$INCLUDE' >> $gcc7dir/env.sh







