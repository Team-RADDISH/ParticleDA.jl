#!/bin/bash
#=======================================================================
# ensfcst.sh
#   This script runs the SPEEDY model with subdirectory $PROC
#=======================================================================

# Input for this shell
SPEEDY=$1
OUTPUT=$2
YMDH=$3
TYMDH=$4
rank=$5
particle=$6

TMPDIR=$2/DATA/tmp
OUTPUT=$2/DATA/ensemble
echo "Updating ensemble member $6 on rank $5"
cd $TMPDIR/ensfcst

# Create directory for this process
rm -rf $rank
mkdir ${rank}
mkdir ${rank}/${particle}
cd ${rank}
# cp $SPEEDY/DATA/tmp/letkf/ensfcst/imp $MEM
cp $SPEEDY/DATA/nature/imp $particle
# Set up boundary files
SB=$SPEEDY/model/data/bc/t30/clim
SC=$SPEEDY/model/data/bc/t30/anom
ln -s $SB/sfc.grd   $particle/fort.20
ln -s $SB/sst.grd   $particle/fort.21
ln -s $SB/icec.grd  $particle/fort.22
ln -s $SB/stl.grd   $particle/fort.23
ln -s $SB/snowd.grd $particle/fort.24
ln -s $SB/swet.grd  $particle/fort.26
cp    $SC/ssta.grd  $particle/fort.30

# Run
cd $particle
ln -fs $OUTPUT/anal/${rank}/${particle}/${YMDH}.grd fort.90
ln -fs $OUTPUT/gues/${rank}/${particle}/fluxes.grd fluxes.grd
FORT2=2
echo $FORT2 > fort.2
echo $YMDH | cut -c1-4 >> fort.2
echo $YMDH | cut -c5-6 >> fort.2
echo $YMDH | cut -c7-8 >> fort.2
echo $YMDH | cut -c9-10 >> fort.2
./imp > out.lis 2> out.lis.2
mv ${TYMDH}.grd $OUTPUT/gues/${rank}/${particle}
exit 0
