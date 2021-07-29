#!/bin/tcsh

#to be run from $homedir

setenv runid iceOceanE
setenv finyear 1100

setenv masterdir $HOME/timms_linRemap_adaptTS
setenv timmsoutdir $WORK/MisomipPlus/timms/$runid

setenv fesommeshdir $WORK/MisomipPlus/fesommesh/$runid
setenv fesomrundir $WORK/MisomipPlus/fesomrun/$runid
setenv fesomdatadir $WORK/MisomipPlus/fesomdata/$runid
setenv uadir $WORK/MisomipPlus/ua/$runid

# no users below this line
printf '%s\n' "=====================================================================  ;,//;,    ,;/ ================"
printf '%s\n' "                                  Welcome to Mr. Timms                o:::::::;;///                  "
printf '%s\n' "==================================================================== >::::::::;;\\\ ================="
printf '%s\n' "                                                                       ''\\\\\'' ';\                 "

echo 'masterdir='$masterdir
#cd $masterdir
echo $runid   > $timmsoutdir/$runid.dat

setenv CLOCKFILE $runid.clock
echo 'defined CLOCKFILE to be' $fesomdatadir/$CLOCKFILE


echo "========================"
echo "go to" $1
echo "========================"
goto $1


#Seiteneinstiege:                            
#getclockfile:
#echo "========================"
#echo "getclockfile"
#echo "========================"

#echo 'get file from' $fesomdatadir
#cp $fesomdatadir/$CLOCKFILE .
#if ($status != 0) then
# echo "--------------------------------------------------------------------------------------"
# echo "Attempt to copy" $fesomdatadir/$CLOCKFILE " to masterdir failed."
# echo "Exit."
# echo "--------------------------------------------------------------------------------------"
# exit
#endif

start:
ocean2ice:
echo "======================================="
echo "extract data from clockfile "
echo "======================================="
#VAR11=`awk -F";" 'NR == [ZEILE] { print $1}' $FILE | awk '{print $[SPALTE]}'`
setenv OLDTIME `awk -F";" 'NR == 1 { print $1}' $fesomdatadir/$CLOCKFILE | awk '{print $1}'`
setenv OLDDAY `awk -F";" 'NR == 1 { print $1}' $fesomdatadir/$CLOCKFILE | awk '{print $2}'`
setenv OLDYEAR `awk -F";" 'NR == 1 { print $1}' $fesomdatadir/$CLOCKFILE | awk '{print $3}'`
setenv NEWTIME `awk -F";" 'NR == 2 { print $1}' $fesomdatadir/$CLOCKFILE | awk '{print $1}'`
setenv NEWDAY `awk -F";" 'NR == 2 { print $1}' $fesomdatadir/$CLOCKFILE | awk '{print $2}'`
setenv NEWYEAR `awk -F";" 'NR == 2 { print $1}' $fesomdatadir/$CLOCKFILE | awk '{print $3}'`
echo "$OLDTIME"
echo "$OLDDAY"
echo "$OLDYEAR"
echo "$NEWTIME"
echo "$NEWDAY"
echo "$NEWYEAR"

if ($NEWDAY != 1 || $OLDYEAR == $NEWYEAR || ($OLDDAY != 360 && $OLDDAY != 365)) then
 echo "--------------------------------------------"
 echo "ERROR: invalid clock file - Mr. Timms terminates"
 echo "--------------------------------------------"
endif

echo $OLDYEAR > $timmsoutdir/$runid.yeartoicemod.dat
echo $NEWYEAR > $timmsoutdir/$runid.yearfromicemod.dat

if ($2 == 'only') then
 echo "==========================================="
 echo "exit after getclockfile has been completed"
 echo "==========================================="
 exit
endif


prepare4ua:
echo "========================"
echo " run prepare4ua"
echo "========================"

setenv OLDYEAR `cat $timmsoutdir/$runid.yeartoicemod.dat`
setenv NEWYEAR `cat $timmsoutdir/$runid.yearfromicemod.dat`
echo "using years" $OLDYEAR" and" $NEWYEAR" for current ua step."
sed -i "s/CtrlVar.TotalTime=.*/CtrlVar.TotalTime=$NEWYEAR;/" $uadir/DefineInitialInputs.m
#sed -i "s/CtrlVar.RestartTime=.*/CtrlVar.RestartTime=$OLDYEAR;/" $uadir/DefineInitialInputs.m

setenv fesommeltfile $fesomdatadir/$runid.$OLDYEAR.forcing.diag.nc
setenv fesomcoordfile $fesommeshdir/$OLDYEAR/nod2d.out
echo "using" $fesommeltfile " and" $fesomcoordfile " for current ua melt rates."
sed -i "s~fesomMeltPath=.*~fesomMeltPath= '$fesommeltfile';~" $uadir/DefineMassBalance.m
sed -i "s~fesomCoordPath=.*~fesomCoordPath= '$fesomcoordfile';~" $uadir/DefineMassBalance.m


if ($status != 0) then
 echo "--------------------------------------------------------------------------------------"
 echo "Attempt to configure DefineInitialInputs.m failed. "
 echo "Exit."
 echo "--------------------------------------------------------------------------------------"
 exit
endif

if ($2 == 'only') then
 echo "==========================================="
 echo "exit after prepare4ua has been completed"
 echo "==========================================="
 exit
endif

launchua:                          # !!does not work as an entry on AWI!!
echo "==============="
echo "now launch Ua"
echo "==============="

setenv OLDYEAR `cat $timmsoutdir/$runid.yeartoicemod.dat`
setenv NEWYEAR `cat $timmsoutdir/$runid.yearfromicemod.dat`

cd $uadir
cp ice.log ice.$OLDYEAR.log
sbatch ua.run

if ($2 == 'only') then
 echo "======================================================"
 echo "exit after launchua has been completed"
 echo "======================================================"
 exit
endif

if ($NEWYEAR >= $finyear) then
 echo "==================================================================================="
 echo "exit after launchua has been completed. Final year ("$finyear") has been reached."
 echo "==================================================================================="
 exit
endif


launchualookup:
date
echo "========================================"
echo "launch ua lookup job"
echo "========================================"
cd $masterdir
setenv yearfromicemod `cat $timmsoutdir/$runid.yearfromicemod.dat`

./check4uadata.csh $uadir/ResultsFiles $yearfromicemod yes $timmsoutdir > $timmsoutdir/check4uadata.log &
sleep 2

echo "=========================================================================="
echo "Ocan2ice part of Mr. Timms script completed; Ua is supposed to run for year"
cat $timmsoutdir/$runid.yearfromicemod.dat
echo "=========================================================================="

exit

# end of ocean to ice
# #######################################################################################################
# # start of ice to ocean    



ice2ocean:
meshgen:
echo "======================"
echo 'call meshgen.m'
echo "======================"
setenv yearfromicemod `cat $timmsoutdir/$runid.yearfromicemod.dat`
setenv newmeshdir $fesommeshdir/$yearfromicemod
setenv uaresultfile $uadir/ResultsFiles/0${yearfromicemod}00-Nodes*.mat
setenv goodfile $fesommeshdir/meshgen.goodfile.$yearfromicemod

sed -i "s~meshOutPath=.*~meshOutPath='$newmeshdir/';~" meshgen.m
sed -i "s~Ua_path=.*~Ua_path='$uaresultfile';~" meshgen.m
sed -i "s~goodfile_path=.*~goodfile_path='$goodfile';~" meshgen.m
mkdir -p $newmeshdir/dist
matlab.sh -s -S"-wprod-0304" -M"-nojvm -r run('meshgen.m')"  #> meshgen.$yearfromicemod.log
 #matlab.sh -s -M" -nodisplay -r run('~/test.m')" -S"--time=6:00:00 -c4 --mem=10000"

if (-e $goodfile) then
 echo "||||||||||||||||||||||||||||"
 echo "returned from meshgen.m ok"
 echo "||||||||||||||||||||||||||||"
else
 echo ----------------------------------------------
 echo 'returned from meshgen.m accidentally: stop'
 echo ----------------------------------------------
 exit
endif
if ($2 == 'only') then
 echo "==========================================="
 echo "exit after meshgen has been completed"
 echo "==========================================="
 exit
endif

remap_data:
echo =================================================
echo 'now remap fesom data to new mesh'
echo =================================================
setenv yeartoicemod `cat $timmsoutdir/$runid.yeartoicemod.dat`
setenv yearfromicemod `cat $timmsoutdir/$runid.yearfromicemod.dat`
echo 'yeartoicemod=' $yeartoicemod
echo 'yearfromicemod=' $yearfromicemod

setenv oldocefile $fesomdatadir/arch/$runid.$yeartoicemod.oce.nc
setenv oldicefile $fesomdatadir/arch/$runid.$yeartoicemod.ice.nc
setenv newocefile $fesomdatadir/$runid.$yeartoicemod.oce.nc
setenv newicefile $fesomdatadir/$runid.$yeartoicemod.ice.nc

mkdir $fesomdatadir/arch

setenv newmeshdir $fesommeshdir/$yearfromicemod
setenv oldmeshdir $fesommeshdir/$yeartoicemod

sed -i "s~oldOceFile=.*~oldOceFile='$oldocefile';~" remap3.m
sed -i "s~newOceFile=.*~newOceFile='$newocefile';~" remap3.m
sed -i "s~oldIceFile=.*~oldIceFile='$oldicefile';~" remap3.m
sed -i "s~newIceFile=.*~newIceFile='$newicefile';~" remap3.m
sed -i "s~oldMeshPath=.*~oldMeshPath='$oldmeshdir/';~" remap3.m
sed -i "s~newMeshPath=.*~newMeshPath='$newmeshdir/';~" remap3.m
#matlab.sh -s -M"-nojvm -r run('remap3.m')"
matlab.sh -s -S"-wprod-0304" -M"-nojvm -r run('remap3.m')"


if ($2 == 'only') then
 echo "==========================================="
 echo "exit after remap_data has been completed"
 echo "==========================================="
 exit
endif

prepare4fesom:
echo =============
echo 'prepare fesom'
echo =============
setenv yeartoicemod `cat $timmsoutdir/$runid.yeartoicemod.dat`
setenv yearfromicemod `cat $timmsoutdir/$runid.yearfromicemod.dat`
setenv CLOCKFILE $runid.clock
echo 'first check correctness of' $fesomdatadir/$CLOCKFILE
setenv VAR11 `awk -F";" 'NR == 1 { print $1}' $fesomdatadir/$CLOCKFILE | awk '{print $1}'`
setenv VAR12 `awk -F";" 'NR == 1 { print $1}' $fesomdatadir/$CLOCKFILE | awk '{print $2}'`
setenv OLDYEAR `awk -F";" 'NR == 1 { print $1}' $fesomdatadir/$CLOCKFILE | awk '{print $3}'`
setenv NEWTIME `awk -F";" 'NR == 2 { print $1}' $fesomdatadir/$CLOCKFILE | awk '{print $1}'`
setenv NEWDAY `awk -F";" 'NR == 2 { print $1}' $fesomdatadir/$CLOCKFILE | awk '{print $2}'`
setenv NEWYEAR `awk -F";" 'NR == 2 { print $1}' $fesomdatadir/$CLOCKFILE | awk '{print $3}'`
echo "$VAR11"
echo "$VAR12"
echo "$OLDYEAR"
echo "$NEWTIME"
echo "$NEWDAY"
echo "$NEWYEAR"
if ($NEWDAY != 1 || $OLDYEAR == $NEWYEAR || $OLDYEAR != $yeartoicemod || $NEWYEAR != $yearfromicemod) then
 echo "--------------------------------------------"
 echo "ERROR: invalid clock file - Mr. Timms terminates"
 echo "--------------------------------------------"
 exit
else 
 echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 echo "$CLOCKFILE is ok: We are GO for FESOM launch sequence."
 echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
endif

setenv newmeshdir $fesommeshdir/$yearfromicemod
setenv configfile $fesomrundir/namelist.config
echo 'now modify namelist.config using' $OLDYEAR'(I know, its strange) and' $newmeshdir
cp $configfile $configfile.$yeartoicemod
sed -i "s~yearnew=.*~yearnew=$OLDYEAR~" $configfile
sed -i "s~MeshPath=.*~MeshPath='$newmeshdir/'~" $configfile
sed -i "s~runid=.*~runid='$runid'~" $configfile



launchfesom:
echo ==========================================
echo 'now launch fesom'
echo ==========================================
cd $fesomrundir
sbatch oce0.slurm.ollie | cut -d ' ' -f4 | tee $timmsoutdir/$runid.jobid.dat
if ($status != 0) then
 echo "-----------------------------------------"
 echo "Attempt to launch FESOM has failed. Exit."
 echo "-----------------------------------------"
 exit
endif
if ($2 == 'only') then
 echo "==========================================="
 echo "exit after launch_fesom has been completed"
 echo "==========================================="
 exit
endif

launchfesomlookup:
date
echo ==========================================
echo 'now launch sleeping lookup job'
echo ==========================================
setenv yearfromicemod `cat $timmsoutdir/$runid.yearfromicemod.dat`
cd $masterdir
./check4fesomdata.csh $fesomdatadir $runid $yearfromicemod yes $timmsoutdir > $timmsoutdir/check4fesomdata.log &
sleep 2


echo =================================================
echo 'Mr. Timms script completed; FESOM now runs for year'
cat $timmsoutdir/$runid.yearfromicemod.dat
echo =================================================

exit

