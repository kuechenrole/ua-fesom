#!/bin/csh

#setenv fesomrundir $1
#set ID="$1"
#setenv timmsoutdir $3
#setenv masterdir $cwd
   
date
sleep 10

set ID=`cat $timmsoutdir/$runid.jobid.dat`
echo "current job id is $ID."
set jobfile="$fesomrundir/slurm-$ID.out"
echo "looking for jobfile $jobfile."
ls $jobfile
if ($status == 0) then
  echo "$jobfile exist, now checking for 'not converged' statement." 
  if ( `grep -c "not converged" $jobfile` != 0) then
      echo "found 'not converged' statement in $jobfile. Cancel current Fesom run." 
      scancel $ID
      grep "step_per_day" $fesomrundir/namelist.config | IFS="=" read name value
      if ( $value < 960 ) then
	  let newValue=$value*2    
	  echo "adjusting step_per_day from $value to $newValue."
	  sed -i "s~step_per_day=.*~step_per_day='$newValue'~" $fesomrundir/namelist.config
	  echo "Relaunch fesom with adjusted time step."
	  cd $fesomrundir
          sbatch oce0.slurm.ollie | cut -d ' ' -f4 | tee $timmsoutdir/$runid.jobid.dat
	  echo "Resubmit adaptFesomTS for new job."
	  $masterdir/adaptFesomTS.csh >> $timmsoutdir/adaptFesomTS.log &
	  exit
      else
	  echo "Time step_per_day is already >= 960. AdaptFesomTS does nothing and stops." 
	  exit
      endif
  else
      echo "'not coverged' statement has NOT been found. Resubmit adaptFesomTS for old job $ID."
      $masterdir/adaptFesomTS.csh >> $timmsoutdir/adaptFesomTS.log &
  endif
else
    echo "$jobfile does not yet exist. Checking in 5 min again."
    $masterdir/adaptFesomTS.csh >> $timmsoutdir/adaptFesomTS.log &
endif
exit
