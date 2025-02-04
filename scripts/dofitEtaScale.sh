#!/bin/sh

date

# $1: REGVERSION
# $2: RUN
# $3: MODE
# $4: METHOD
# $5: NTIMES
# $6: ETASCALEREF
# $7: DOEVENODD
# $8: ROOTFILEIN

#NTIMES
NTIMES=$5

#fit mode
MODE=$3

#fit method
METHOD=$4


#Run pieriod
RUN=$2

#Regression version
REGVERSION=$1 #"V5Elec"
#Gaussian Resolution
GAUSRESO="1.5"

#
ETASCALEREF=$6

# 
DOEVENODD=$7

#debug
DEBUG="1"

#initilize working area
TOP=$PWD
SOURCE=/afs/cern.ch/user/h/heli/work/private/calib/2014Jan27/FitEtaScale
DATA=/eos/cms/store/group/alca_ecalcalib/ecalelf/heli/ntuple

alias eos='/afs/cern.ch/project/eos/installation/0.2.31/bin/eos.select'
 

ROOTFILEIN=$8
ROOTFILEOUT=fitzeescale_out_${REGVERSION}_Mode${MODE}_Method${METHOD}_${RUN}_${NTIMES}.root
LOGFILE=fitzeescale_out_${REGVERSION}_Mode${MODE}_Method${METHOD}_${RUN}_${NTIMES}.log

echo "setup" 
cp ${SOURCE}/env_CMSSW_5_3_7_patch5.sh .
source env_CMSSW_5_3_7_patch5.sh
cd ${TOP}


date
#

echo "copy codes"
cd ${SOURCE}
cp calibRecord.h  fitzeescale.cc functions.h  variables.h voigt.h eering.dat ${TOP}/
cp ${ETASCALEREF} ${TOP}/
cd ${TOP}
date

echo "build"
g++ -o fitzeescale.exe fitzeescale.cc \
      -pthread -m64 \
      -I${ROOTSYS}/include \
      -I./  -L${ROOTSYS}/lib \
      -lCore -lCint -lRIO -lNet -lHist -lGraf -lGraf3d \
      -lGpad -lTree -lRint -lPostscript -lMatrix -lPhysics \
      -lMathCore -lThread -lMinuit -lMinuit2 -lpthread \
      -lTreePlayer \
      -Wl,-rpath,${ROOTSYS}/lib -lm -ldl

date

#echo "copy data"
#eos cp ${DATA}/${ROOTFILEIN} ./
#date

date

echo "run"
./fitzeescale.exe ${MODE} \
               root://eoscms/${DATA}/${ROOTFILEIN} \
               ${ROOTFILEOUT} \
               0.9999 \
               ${METHOD} ${GAUSRESO} \
               ${REGVERSION} \
               ${DEBUG} \
               ${DOEVENODD} \
               ${ETASCALEREF}\
           &> ${LOGFILE}


date

echo "copy output"
OUTDIR="${SOURCE}/out_${REGVERSION}_mode${MODE}_method${METHOD}_evenodd${DOEVENODD}_${NTIMES}"
if [ ! -d $OUTDIR ];
then
  mkdir $OUTDIR
fi
cp ${ROOTFILEOUT} ${OUTDIR}/
cp ${LOGFILE} ${OUTDIR}/


date



