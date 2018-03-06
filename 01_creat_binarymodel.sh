#!/bin/bash
xsmooth=10000;
zsmooth=2000;

read -p "Do you wish to create the binary model from tomo_xyz (y/n)?" yn
if [ $yn == 'y' ]; then

echo "create the model_init_bin start:"

cp tomo_xyz/*init*  ./DATA/tomo_file.xyz
./bin/xmeshfem2D > model_create.txt
mpirun -n 4 ./bin/xspecfem2D > model_create.txt
#./bin/xspecfem2D > model_create.txt


if [ ! -d "./model_init_bin_org" ]; then
  mkdir model_init_bin_org
fi
mv DATA/pro*bin  ./model_init_bin_org

echo "create the model_init_bin end"


echo "create the model_true_bin start:"

cp tomo_xyz/*true*  ./DATA/tomo_file.xyz
./bin/xmeshfem2D > model_create.txt
mpirun -n 4 ./bin/xspecfem2D > model_create.txt

#./bin/xspecfem2D > model_create.txt

if [ ! -d "./model_true_bin_org" ]; then
  mkdir model_true_bin_org
fi
mv DATA/pro*bin  ./model_true_bin_org

echo "create the model_true_bin end"

fi


read -p "Do you wish to smooth the binary model (y/n)?" yn
if [ $yn == 'y' ]; then

if [ ! -d "./model_init_bin_smooth" ]; then
  mkdir model_init_bin_smooth
fi

if [ ! -d "./model_true_bin_smooth" ]; then
  mkdir model_true_bin_smooth
fi

rm -rf ./model_init_bin_smooth/*
rm -rf ./model_true_bin_smooth/*

cp ./smooth_model_scipt/change.csh   ./model_init_bin_smooth
cp ./smooth_model_scipt/change.csh   ./model_true_bin_smooth




mpirun -n 4  ./bin/xsmooth_sem $xsmooth $zsmooth  0.0  vs,vp,rho  ./model_init_bin_org ./model_init_bin_smooth  false
mpirun -n 4  ./bin/xsmooth_sem $xsmooth $zsmooth  0.0  vs,vp,rho  ./model_true_bin_org ./model_true_bin_smooth  false

cd ./model_init_bin_smooth
csh change.csh
cd ../

cd ./model_true_bin_smooth
csh change.csh
cd ../



if [ ! -d "./model_init_bin" ]; then
  mkdir model_init_bin
fi

if [ ! -d "./model_true_bin" ]; then
  mkdir model_true_bin
fi

rm -rf ./model_init_bin/*
rm -rf ./model_true_bin/*


cp ./model_init_bin_org/pro*    ./model_init_bin
cp ./model_true_bin_org/pro*    ./model_true_bin

mv ./model_init_bin_smooth/pro* ./model_init_bin
mv ./model_true_bin_smooth/pro* ./model_true_bin

fi
