#!/bin/tcsh

#to be run from $masterdir

setenv runid RG45986

setenv awiuser rtimmerm
setenv hlrnuser hbkratim
setenv mucuser di57hag2
setenv pikuser timmerm

setenv masterdir $HOME/RAnGO-2/$runid/RIO_scripts
setenv idldir $HOME/RAnGO-2/$runid/idl
setenv compiletopodir $HOME/RAnGO-2/$runid/compile_topo


#FESOM @ HLRN:
setenv fesomuser $hlrnuser
setenv fesomhost blogin.hlrn.de
setenv fesommeshdir /scratch/usr/$hlrnuser/mesh/fesom_grid_$runid
setenv fesomrundir /home/$hlrnuser/fesom/$runid
setenv fesomdatadir /scratch/usr/$hlrnuser/data

#FESOM @ ollie:
#setenv fesomuser $awiuser
#setenv fesomhost ollie1.awi.de
#setenv fesommeshdir /work/ollie/$fesomuser/mesh/fesom_grid_$runid
#setenv fesomrundir /home/ollie/$fesomuser/fesom/$runid
#setenv fesomdatadir /work/ollie/$fesomuser/data


#PISM @ SMUC:
setenv HOMEDIRLRZ /dss/dsshome1/01/$mucuser
setenv WORKDIRLRZ /hppfs/work/pn69ru/$mucuser
setenv HOMEDIRTA /dss/dsshome1/08/di73lug3 
setenv WORKDIRTA /hppfs/work/pn69ru/di73lug3
setenv muchost skx.supermuc.lrz.de
setenv mucmaster $HOMEDIRLRZ/RAnGO-2/$runid/director
# setenv pisminputdir $WORKDIRLRZ/RAnGO-2/$runid/pism_input
# setenv pismrundir $HOMEDIRLRZ/RAnGO-2/$runid/pismrun
# setenv pismdatadir $WORKDIRLRZ/RAnGO-2/$runid/pismdata
# setenv condapython $WORKDIRTA/software/py37/bin/python
# setenv remapscript $pismrundir/regrid_fesom_to_pism.py 
# setenv iceresultsdir $pismdatadir/results
# setenv icemodhost $muchost


#PISM @ PIK:
setenv HOMEDIRPIK /home/$pikuser
setenv WORKDIRPIK /p/tmp/$pikuser
#setenv HOMEDIRTA /dss/dsshome1/08/di73lug3 
#setenv WORKDIRTA /hppfs/work/pn69ru/di73lug3
setenv pikhost cluster.pik-potsdam.de
setenv pikmaster $HOMEDIRPIK/RAnGO-2/$runid/director
setenv pisminputdir $WORKDIRPIK/RAnGO-2/$runid/pism_input
setenv pismrundir $HOMEDIRPIK/RAnGO-2/$runid/pismrun
setenv pismdatadir $WORKDIRPIK/RAnGO-2/$runid/pismdata
setenv condapython /home/albrecht/.conda/envs/python_for_pism_calib/bin/python
setenv remapscript $pismrundir/regrid_fesom_to_pism.pik.py 
setenv iceresultsdir $pismdatadir/results
setenv icemodhost $pikhost


setenv run_on_host unknown
if ($HOME == /home/csys/$awiuser) setenv run_on_host AWI
if ($HOME == $HOMEDIRLRZ) setenv run_on_host MUC
if ($HOME == $HOMEDIRPIK) setenv run_on_host PIK
echo 'run on host' $run_on_host


# specific to AWI
setenv idlhost linsrv1.awi.de                    # the machine that IDL runs on
if ($run_on_host == AWI) then 
 setenv archdir /isibhv/netscratch/rtimmerm/fesom4archive
 setenv datadir /isibhv/netscratch/rtimmerm/RAnGO/data/$runid
 setenv datadirin $archdir
 setenv datadirout /isibhv/netscratch/rtimmerm/RAnGO/fesom_remapped/
 setenv meshdir /isibhv/projects/oce_rio/rtimmerm/feiom/grids/fesom_grid_$runid/

 setenv idlcommand "ssh $idlhost "

 touch $archdir/*
endif

# specific to SuperMUC:
if ($run_on_host == MUC) then 
 #module load idl/8.4
 setenv masterdir $mucmaster 
 setenv archdir $WORKDIRLRZ/RAnGO-2/$runid/archive
 setenv datadir $WORKDIRLRZ/RAnGO-2/$runid/fesomdata
 setenv datadirin $datadir/rango_in
 setenv datadirout $datadir/rango_out
 setenv meshdir $WORKDIRLRZ/RAnGO-2/$runid/meshgen
 setenv tmpdir $WORKDIRLRZ/RAnGO-2/$runid/tmp

 #setenv PROJ_LIB $WORKDIRTA/software/proj/proj-6.3.0-intel2019/share/proj
 #setenv LD_LIBRARY_PATH $HOMEDIRTA/software/proj/proj-6.0.0-intel2019/lib64:$LD_LIBRARY_PATH
 #module load matlab-mcr/R2018a-generic

 #setenv idlcommand 

endif


# specific to PIK:
if ($run_on_host == PIK) then 
 setenv masterdir $pikmaster 
 setenv archdir $WORKDIRPIK/RAnGO-2/$runid/archive
 setenv datadir $WORKDIRPIK/RAnGO-2/$runid/fesomdata
 setenv datadirin $datadir/rango_in
 setenv datadirout $datadir/rango_out
 setenv meshdir $WORKDIRPIK/RAnGO-2/$runid/meshgen
 setenv tmpdir $WORKDIRPIK/RAnGO-2/$runid/tmp
 # setenv idlcommand 
endif


setenv icetopodir $meshdir


# no users below this line
echo "====================================================================================================="
echo "                                  Welcome to RAnGO-2"
echo "====================================================================================================="
echo "running on host" $run_on_host


echo 'masterdir='$masterdir
cd $masterdir
echo $runid   > $masterdir/runid.dat

setenv CLOCKFILE $runid.clock                               
echo 'defined CLOCKFILE to be' $CLOCKFILE


echo "========================"
echo "go to" $1
echo "========================"
goto $1

	
#Seiteneinstiege:                            
getclockfile:
echo "========================"
echo "getclockfile"
echo "========================"

echo 'get file from' $fesomhost':'/$fesomdatadir
scp $fesomuser@$fesomhost':'/$fesomdatadir/$CLOCKFILE .
if ($status != 0) then
 echo "--------------------------------------------------------------------------------------"
 echo "Attempt to copy" $fesomuser@$fesomhost':'/$fesomdatadir/$CLOCKFILE " to masterdir failed."
 echo "Exit."
 echo "--------------------------------------------------------------------------------------"
 exit
endif



start:
ocean2ice:
echo "======================================="
echo "extract data from clockfile "
echo "======================================="
#VAR11=`awk -F";" 'NR == [ZEILE] { print $1}' $FILE | awk '{print $[SPALTE]}'`
setenv OLDTIME `awk -F";" 'NR == 1 { print $1}' $CLOCKFILE | awk '{print $1}'`
setenv OLDDAY `awk -F";" 'NR == 1 { print $1}' $CLOCKFILE | awk '{print $2}'`
setenv OLDYEAR `awk -F";" 'NR == 1 { print $1}' $CLOCKFILE | awk '{print $3}'`
setenv NEWTIME `awk -F";" 'NR == 2 { print $1}' $CLOCKFILE | awk '{print $1}'`
setenv NEWDAY `awk -F";" 'NR == 2 { print $1}' $CLOCKFILE | awk '{print $2}'`
setenv NEWYEAR `awk -F";" 'NR == 2 { print $1}' $CLOCKFILE | awk '{print $3}'`
echo "$OLDTIME"
echo "$OLDDAY"
echo "$OLDYEAR"
echo "$NEWTIME"
echo "$NEWDAY"
echo "$NEWYEAR"

if ($NEWDAY != 1 || $OLDYEAR == $NEWYEAR || ($OLDDAY != 360 && $OLDDAY != 365)) then
 echo "--------------------------------------------"
 echo "ERROR: invalid clock file - RAnGO terminates"
 echo "--------------------------------------------"
endif

echo $OLDYEAR > $masterdir/$runid.yeartoicemod.dat
echo $NEWYEAR > $masterdir/$runid.yearfromicemod.dat
echo $OLDYEAR > $masterdir/yeartoicemod.dat
echo $NEWYEAR > $masterdir/yearfromicemod.dat

if ($2 == 'only') then
 echo "==========================================="
 echo "exit after getclockfile has been completed"
 echo "==========================================="
 exit
endif



getdata:
echo "======="
echo "getdata"
echo "======="
setenv OLDYEAR `cat $masterdir/$runid.yeartoicemod.dat`
setenv NEWYEAR `cat $masterdir/$runid.yearfromicemod.dat`
echo create $datadir
mkdir -p $datadir
mkdir -p $datadirin
mkdir -p $datadirout
cd $datadir
pwd
cp $masterdir/$runid.yeartoicemod.dat $datadir
cp $masterdir/$runid.yearfromicemod.dat $datadir
echo $runid > $datadir/runid.dat


echo on $fesomhost, move $runid.$OLDYEAR data to rangosave and copy from there
ssh -t $fesomuser@$fesomhost mv $fesomdatadir/$runid.$OLDYEAR.'*' $fesomdatadir/rangosave
if ($status != 0) then
 echo "---------------------------------------------------------------------------------------------------------"
 echo "Attempt to move" $fesomuser@$fesomhost':'/$fesomdatadir/$runid.$OLDYEAR.forcing.diag.nc " to rangosave failed."
 echo "Exit."
 echo "---------------------------------------------------------------------------------------------------------"
 exit
endif


scp $fesomuser@$fesomhost':'/$fesomdatadir/rangosave/$runid.$OLDYEAR.forcing.diag.nc $datadir  # to extract melt rates
if ($status != 0) then
 echo "---------------------------------------------------------------------------------------------------------"
 echo "Attempt to copy" $fesomuser@$fesomhost':'/$fesomdatadir/$runid.$OLDYEAR.forcing.diag.nc " to " $datadir "failed."
 echo "Exit."
 echo "---------------------------------------------------------------------------------------------------------"
 exit
endif
scp $fesomuser@$fesomhost':'/$fesomdatadir/rangosave/$runid.$OLDYEAR.oce.mean.nc $datadir      # to extract temperatures
if ($status != 0) then
 echo "---------------------------------------------------------------------------------------------------------"
 echo "Attempt to copy" $fesomuser@$fesomhost':'/$fesomdatadir/$runid.$OLDYEAR.oce.mean.nc " to " $datadir "failed."
 echo "Exit."
 echo "---------------------------------------------------------------------------------------------------------"
 exit
endif


echo "======================================="
echo "launch getfesomdata.csh into background"
echo "======================================="
cd $masterdir
./getfesomdata.csh $fesomuser $fesomhost $fesomdatadir $runid $OLDYEAR $archdir &

if ($2 == 'only') then
 echo "==========================================="
 echo "exit after getdata has been completed"
 echo "==========================================="
 exit
endif



tempmelt4pism:
echo "========================"
echo " run tempmelt4pism"
echo "========================"
echo $runid > $idldir/runid.dat
echo $datadir > $idldir/datadir.dat
echo $meshdir/ > $idldir/meshdir.dat
cp $masterdir/yeartoicemod.dat $idldir/yeartopism.dat
$idlcommand $idldir/tempmelt4pism.csh $idldir

if ($2 == 'only') then
 echo "==========================================="
 echo "exit after ismelt4pism has been completed"
 echo "==========================================="
 exit
endif




prepare4pism:
echo "================================================"
echo "prepare for pism, first remap melt rate data"
echo "================================================"

echo 'we are on host' $run_on_host
echo 'and read' $masterdir/yeartoicemod.dat
setenv yeartoicemod `cat $masterdir/yeartoicemod.dat`
echo 'yeartoicemod is' $yeartoicemod

if ($run_on_host == 'AWI') then
 echo "================================================"
 echo "first transfer" $datadir/$runid.$yeartoicemod.tempmelt.extfris.aym.nc "to" $pikuser@$pikhost':'$pisminputdir
 echo "================================================"
 scp $datadir/$runid.$yeartoicemod.tempmelt.extfris.aym.nc $pikuser@$pikhost':'$pisminputdir
 echo "=========================="
 echo "then push RAnGO.csh to pik" 
 echo "=========================="
 scp RAnGO.csh $pikuser@$pikhost':'$pikmaster
 scp yeartoicemod.dat $pikuser@$pikhost':'$pikmaster
 scp yearfromicemod.dat $pikuser@$pikhost':'$pikmaster
 echo "====================="
 echo "now call RAnGO on pik"
 echo "====================="
 ssh $pikuser@$pikhost $pikmaster/RAnGO.csh prepare4pism all
 echo "======================="
 echo "RAnGO returned from PIK"
 echo "======================="
endif 
if ($run_on_host == 'PIK') then
echo 'now remap' $datadir/$runid.$yeartoicemod.tempmelt.extfris.aym.nc
echo 'to' $pisminputdir/fesom2pism.shelfmelt.$yeartoicemod.nc
 $condapython $remapscript -i $pisminputdir/$runid.$yeartoicemod.tempmelt.extfris.aym.nc -o $pisminputdir/fesom2pism.shelfmelt.$yeartoicemod.nc -y $yeartoicemod
 if ($status != 0) then
  echo "-----------------------------------------------------------------------------"
  echo "Attempt to remap" fesom.shelfmelt.$yeartoicemod.nc "to " fesom2pism.shelfmelt.$yeartoicemod.nc " failed."
  echo "RAnGO terminates before calling PISM."
  echo "-----------------------------------------------------------------------------"
  exit
 endif
endif
if ($2 == 'only') then
 echo "==========================================="
 echo "exit after prepare4pism has been completed"
 echo "==========================================="
 exit
endif

launchpism:                          # !!does not work as an entry on AWI!!
if ($run_on_host == 'PIK') then
 echo "==============="
 echo "now launch PISM"
 echo "==============="
 setenv yeartoicemod `cat $masterdir/yeartoicemod.dat`
 cd $pismrundir
 rm -f pism_ok_file
 sbatch submit_pism1p2_pik.sh
# if ($2 == 'only') then
 echo "======================================================"
 echo "exit" $run_on_host "after startpism has been completed"
 echo "======================================================"
 exit
# endif
endif


launchpismlookup:
date
echo ========================================
echo 'launch pism lookup job on' $run_on_host
echo ========================================
setenv yearfromicemod `cat $masterdir/yearfromicemod.dat`
cd $masterdir
./check4pismdata.csh $pikuser $pikhost $pismdatadir/results $runid $yearfromicemod yes > check4pismdata_first.log &
sleep 2

echo "=========================================================================="
echo "Ocan2ice part of RAnGO script completed; PISM is supposed to run for year"
cat $masterdir/yearfromicemod.dat
echo "=========================================================================="

exit

# end of ocean to ice
#######################################################################################################
# start of ice to ocean       


ice2ocean:
extracticemoddata:
setenv yearfromicemod `cat $masterdir/yearfromicemod.dat`
echo "================================================================================================="
echo "Extract icemod data into pism_to_fesom_1km_$yearfromicemod.nc "
echo "from "$iceresultsdir
echo "to" $icetopodir
echo "================================================================================================="
if ($run_on_host == AWI) then 
 echo "push RAnGO.csh to MUC" 
 scp RAnGO.csh $pikuser@$pikhost':'$pikmaster
 scp yeartoicemod.dat $pikuser@$pikhost':'$pikmaster
 scp yearfromicemod.dat $pikuser@$pikhost':'$pikmaster
 echo "now call RAnGO on MUC"
 ssh $pikuser@$pikhost $pikmaster/RAnGO.csh extracticemoddata all
endif

if ($run_on_host == PIK) then 
 module load nco
 echo "do conversion of enthalpy to temperature at z-level 1"
 #cdo -sellevel,3.1484375 -selname,enthalpy $iceresultsdir/result_forc_1km_$yearfromicemod.nc $tmp    ! keep this line commented
 setenv tmp $iceresultsdir/pism_enthalpy_$yearfromicemod.nc
 echo create tmp file $tmp
 ncks -A -v enthalpy,thk,z -d z,1 $iceresultsdir/result_forc_1km_$yearfromicemod.nc $tmp
 ncap2 -O -s "temp_cold=(enthalpy/2009.0)+223.15-273.15;temp_pm=-7.9e-8*(917.0*9.81*(thk-z));enth_cts=2009.0*(temp_pm-223.15+273.15);T_i=temp_pm;where(enthalpy<enth_cts) T_i=temp_cold;" $tmp $tmp
 ncatted -O -a long_name,T_i,o,c,"ice temperature at z(1) level from base" -a units,T_i,o,c,"Celsius" -a standard_name,T_i,d,, -a valid_min,T_i,d,, $tmp
 ncks -A -v T_i $tmp $iceresultsdir/pism_to_fesom_1km_$yearfromicemod.nc
 rm $tmp
 echo "conversion of enthalpy to temperature completed"
 echo "time after enthalpy conversion"
 time


 echo "now extract geometry"
 ncks -A -v topg,usurf,thk,lon,lat,y,x,mask $iceresultsdir/result_forc_1km_$yearfromicemod.nc $iceresultsdir/pism_to_fesom_1km_$yearfromicemod.nc
 cp $iceresultsdir/pism_to_fesom_1km_$yearfromicemod.nc $icetopodir
 if ($status != 0) then
  echo "----------------------------------------------------------------------"
  echo "Attempt to copy" result_forc_1km_$yearfromicemod.nc "to icetopodir failed."
  echo "RAnGO terminates failing."
  echo "----------------------------------------------------------------------"
  exit
 endif
 cp $masterdir/yearfromicemod.dat $datadir
 if ($2 == 'only') then
  echo "================================================"
  echo "exit after extracticemoddata has been completed "
  echo "================================================"
  exit
 endif
 exit
endif



geticemoddata:
echo "================================================================================================="
echo "copy icemod data from " $icemodhost':'$iceresultsdir "to" $icetopodir
echo "================================================================================================="
setenv yearfromicemod `cat $masterdir/yearfromicemod.dat`
echo yearfromicemod=$yearfromicemod
echo "try to copy " $icemodhost':'$iceresultsdir/pism_to_fesom_1km_$yearfromicemod.nc "to" $icetopodir
scp $pikuser@$icemodhost':'$iceresultsdir/pism_to_fesom_1km_$yearfromicemod.nc $icetopodir
if ($status != 0) then
 echo "----------------------------------------------------------------------"
 echo "Attempt to copy" result_forc_1km_$yearfromicemod.nc "to icetopodir failed."
 echo "RAnGO terminates failing."
 echo "----------------------------------------------------------------------"
 exit
endif
cp $masterdir/yearfromicemod.dat $datadir
if ($2 == 'only') then
 echo "==========================================="
 echo "exit after geticemoddata has been completed"
 echo "==========================================="
 exit
endif




compile_topo:
setenv yearfromicemod `cat $masterdir/yearfromicemod.dat`
echo "====================================="
echo "compile topo for " $yearfromicemod
echo "====================================="
echo $meshdir/ > $compiletopodir/meshdir.asc
echo $datadir/ > $compiletopodir/datadir.asc
cp $masterdir/yearfromicemod.dat $compiletopodir
#awi ssh $idlhost $compiletopodir/compile_topo.csh $compiletopodir
#$compiletopodir/compile_topo.csh $compiletopodir   # SuperMUC
$idlcommand $compiletopodir/compile_topo.csh $compiletopodir   # universal
setenv yearfromicemod `cat $masterdir/yearfromicemod.dat`# end of ocean to ice
if (-e $meshdir/mergedbathy-$yearfromicemod.bin) then 
 echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 echo $meshdir/mergedbathy-$yearfromicemod.bin "exists:"
 echo 'new mergedbathy files have been compiled'
 echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
else
 echo "--------------------------------------------------"
 echo $meshdir/mergedbathy-$yearfromicemod.bin "does not exist: "
 echo "RAnGO is forced to terminate"
 echo "--------------------------------------------------"
 exit
endif 
if ($2 == 'only') then
 echo "==========================================="
 echo "exit after compile_topo has been completed"
 echo "==========================================="
 exit
endif




meshgen:
echo =============================
echo 'first call clearmeshdata.csh'
echo =============================
cd $meshdir
./clearmeshdata.csh
echo ======================
echo 'now call meshgen.csh'
echo ======================
setenv yearfromicemod `cat $masterdir/yearfromicemod.dat`
cp $masterdir/yearfromicemod.dat $meshdir
#cd $meshdir
#./meshgen.csh start $idlhost $meshdir
ssh linsrv1.awi.de $meshdir/meshgen.csh start $idlhost $meshdir
if (-e $meshdir/meshgen.goodfile.$yearfromicemod) then 
 echo "||||||||||||||||||||||||||||"
 echo "returned from meshgen.csh ok"
 echo "||||||||||||||||||||||||||||"
else 
 echo ----------------------------------------------
 echo 'returned from meshgen.csh accidentally: stop'
 echo ----------------------------------------------
 exit
endif
if ($2 == 'only') then
 echo "==========================================="
 echo "exit after meshgen has been completed"
 echo "==========================================="
 exit
endif


meshdatamove:
setenv NEWYEAR `cat $masterdir/yearfromicemod.dat`
echo ==========================================
echo 'move mesh data to' 
echo $meshdir/$NEWYEAR
echo ==========================================
cd $meshdir
mkdir $meshdir/$NEWYEAR
mv nod2d.out $meshdir/$NEWYEAR
mv nod3d.out $meshdir/$NEWYEAR
mv elem2d.out $meshdir/$NEWYEAR
mv elem3d.out $meshdir/$NEWYEAR
mv aux3d.out $meshdir/$NEWYEAR
mv cavity_flag_nod2d.out $meshdir/$NEWYEAR
mv icetemp.out $meshdir/$NEWYEAR
mv grid_type_elem2d.out $meshdir/$NEWYEAR
mv sigma_grid_slope_elem.out $meshdir/$NEWYEAR
mv depth.out $meshdir/$NEWYEAR
mv shelf.out $meshdir/$NEWYEAR
if ($2 == 'only') then
 echo "==========================================="
 echo "exit after meshdatamove has been completed"
 echo "==========================================="
 exit
endif


remap_data:
echo =================================================
echo 'now remap fesom data to new mesh'
echo =================================================
setenv yeartoicemod `cat $masterdir/yeartoicemod.dat`
echo 'yeartoicemod=' $yeartoicemod
echo $runid > $idldir/runid.dat
echo $meshdir/ > $idldir/meshdir.dat
echo $datadir > $idldir/datadir.dat
echo $datadirin > $idldir/datadirin.dat
echo $datadirout > $idldir/datadirout.dat
cp $masterdir/yeartoicemod.dat $idldir
cp $masterdir/yearfromicemod.dat $idldir
$idlcommand $idldir/remap_data.csh $idldir
if ($2 == 'only') then
 echo "==========================================="
 echo "exit after remap_data has been completed"
 echo "==========================================="
 exit
endif


if ($run_on_host == MUC) then 
 echo "========================================================================="
 echo "The following bit does not work from SuperMuc, which is why we exit here."
 echo "=========================================================================" 
 exit
endif



meshdatacopy:
setenv NEWYEAR `cat $masterdir/yearfromicemod.dat`
echo ==========================================
echo 'copy mesh data to fesom server directory'
echo $fesomhost':'/$fesommeshdir/$NEWYEAR
echo ==========================================	
ssh -t $fesomuser@$fesomhost mkdir -p $fesommeshdir/$NEWYEAR
scp $meshdir/$NEWYEAR/*2d.out $fesomuser@$fesomhost':'/$fesommeshdir/$NEWYEAR
setenv status1 $status
scp $meshdir/$NEWYEAR/*3d.out $fesomuser@$fesomhost':'/$fesommeshdir/$NEWYEAR
setenv status2 $status
scp $meshdir/$NEWYEAR/sigma_grid_slope_elem.out $fesomuser@$fesomhost':'/$fesommeshdir/$NEWYEAR
setenv status3 $status
scp $meshdir/$NEWYEAR/icetemp.out $fesomuser@$fesomhost':'/$fesommeshdir/$NEWYEAR
setenv status4 $status
if ($status1 != 0 || $status2 != 0 || $status3 || $status4 != 0 ) then
 echo "-------------------------------------------------------------"
 echo "Attempt to copy mesh data files to fesom server failed."
 echo "RAnGO decides to terminate."
 echo "-------------------------------------------------------------"
 exit
endif
scp $masterdir/yearfromicemod.dat $fesomuser@$fesomhost':'/$fesomrundir
if ($2 == 'only') then
 echo "==========================================="
 echo "exit after meshdatacopy has been completed"
 echo "==========================================="
 exit
endif



upload_data:
echo =====================================================================
echo 'upload remapped fesom T/S data from ' $datadirout ' to fesom server'
echo =====================================================================
setenv yeartoicemod `cat $masterdir/yeartoicemod.dat` 
scp $datadirout/$runid.$yeartoicemod.ice.nc $fesomuser@$fesomhost':'$fesomdatadir
scp $datadirout/$runid.$yeartoicemod.oce.nc $fesomuser@$fesomhost':'$fesomdatadir
if ($status != 0) then
 echo "-----------------------------------------------------"
 echo "Attempt to copy ice/oce files to FESOM server failed."
 echo "RAnGO is forced to terminate."
 echo "-----------------------------------------------------"
 exit
else
 echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 echo "T/S data have successfully been uploaded to FESOM server."
 echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
endif
if ($2 == 'only') then
 echo "==========================================="
 echo "exit after upload_data has been completed"
 echo "==========================================="
 exit
endif


arrange_mesh_and_go:
echo =============
echo 'arrange mesh'
echo =============
setenv yeartoicemod `cat $masterdir/yeartoicemod.dat`
setenv yearfromicemod `cat $masterdir/yearfromicemod.dat`
setenv CLOCKFILE $runid.clock
echo 'first check correctness of' $CLOCKFILE
scp $fesomuser@$fesomhost':'/$fesomdatadir/$CLOCKFILE ./$CLOCKFILE.tmp
if ($status != 0) then
 echo "--------------------------------------------------------------------------"
 echo "Attempt to copy" $fesomuser@$fesomhost':'/$fesomdatadir/$CLOCKFILE failed."
 echo "FESOM server is probably unavailable. With tears in our eyes, RAnGO is terminated."
 echo "--------------------------------------------------------------------------"
 exit
endif
setenv VAR11 `awk -F";" 'NR == 1 { print $1}' ./$CLOCKFILE.tmp | awk '{print $1}'`
setenv VAR12 `awk -F";" 'NR == 1 { print $1}' ./$CLOCKFILE.tmp | awk '{print $2}'`
setenv OLDYEAR `awk -F";" 'NR == 1 { print $1}' ./$CLOCKFILE.tmp | awk '{print $3}'`
setenv NEWTIME `awk -F";" 'NR == 2 { print $1}' ./$CLOCKFILE.tmp | awk '{print $1}'`
setenv NEWDAY `awk -F";" 'NR == 2 { print $1}' ./$CLOCKFILE.tmp | awk '{print $2}'`
setenv NEWYEAR `awk -F";" 'NR == 2 { print $1}' ./$CLOCKFILE.tmp | awk '{print $3}'`
echo "$VAR11"
echo "$VAR12"
echo "$OLDYEAR"
echo "$NEWTIME"
echo "$NEWDAY"
echo "$NEWYEAR"
if ($NEWDAY != 1 || $OLDYEAR == $NEWYEAR || $OLDYEAR != $yeartoicemod || $NEWYEAR != $yearfromicemod) then
 echo "--------------------------------------------"
 echo "ERROR: invalid clock file - RAnGO terminates"
 echo "--------------------------------------------"
 exit
else 
 echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
 echo "$CLOCKFILE is ok: We are GO for FESOM launch sequence."
 echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
endif
echo ==========================================
echo 'create clean'  $fesommeshdir/year2run
echo ==========================================
ssh -t $fesomuser@$fesomhost rm -f -r $fesommeshdir/year2run
ssh -t $fesomuser@$fesomhost mkdir -p $fesommeshdir/year2run/dist
echo ==========================================
echo 'copy data from' $fesommeshdir/$yearfromicemod ' to '  $fesommeshdir/year2run
echo ==========================================
ssh -t $fesomuser@$fesomhost cp $fesommeshdir/$yearfromicemod/'*'.out $fesommeshdir/year2run
if ($status == 0) then
 echo "++++++++++++++++++++++++++++++++++++++++++++++"
 echo "Mesh files have been arranged on FESOM server."
 echo "++++++++++++++++++++++++++++++++++++++++++++++"
endif
if ($status != 0) then
 echo "-------------------------------------------------------------"
 echo "Attempt to copy mesh files to "$fesommeshdir"/year2run failed."
 echo "RAnGO is forced to terminate."
 echo "-------------------------------------------------------------"
 exit
endif

echo ==========================================
echo 'cp yearfromicemod.dat to' $fesomuser@$fesomhost':'/$fesommeshdir/year2run
echo ==========================================
scp $masterdir/yearfromicemod.dat $fesomuser@$fesomhost':'/$fesommeshdir/year2run


launch_fesom:
echo ==========================================
echo 'now launch fesom'
echo ==========================================
ssh -t $fesomuser@$fesomhost $fesomrundir/launch_fesom_newyear.bash $fesomrundir
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


launch_lookupjob:
date
echo ==========================================
echo 'now launch sleeping lookup job'
echo ==========================================
setenv yearfromicemod `cat $masterdir/yearfromicemod.dat`
cd $masterdir
./check4fesomdata.csh $fesomuser $fesomhost $fesomdatadir $runid $yearfromicemod yes > check4fesomdata_first.log &
sleep 2


echo =================================================
echo 'RAnGO script completed; FESOM now runs for year'
cat $masterdir/yearfromicemod.dat
echo =================================================

exit

#################################################################################################


launchfesomlookup_short:
date
echo ==========================================
echo 'now launch shortly sleeping lookup job'
echo ==========================================
setenv yearfromicemod `cat $masterdir/yearfromicemod.dat`
cd $masterdir
check4fesomdata.csh $fesomuser $fesomhost $fesomdatadir $runid $yearfromicemod no > check4fesomdata_short.log &
sleep 2
exit











