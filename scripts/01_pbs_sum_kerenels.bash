#!/bin/bash

#PBS -A GEO111
#PBS -N SUM_KERNELS
#PBS -j oe
#PBS -o sum_kernels.$PBS_JOBID.log
#PBS -l walltime=24:00:00
#PBS -l nodes=24

NPROC=384
iter="M24"
cond_nums=("10")
kernels_dir="/lustre/atlas2/geo111/proj-shared/Wenjie/"$iter"_runbase/archive"
outputbase="/lustre/atlas2/geo111/proj-shared/Wenjie/kernels_"$iter"/new"
runcmd=mpirun

cd $PBS_O_WORKDIR
echo "pwd: `pwd`"
echo "Time:`date`"

# kernel dir(generated by adjoint simulation)
if [ ! -d $kernels_dir ]; then
  echo "Missing kernel dir: $kernels_dir"
  exit
fi
echo "Kernel dir: $kernels_dir"

for cond in ${cond_nums[@]}
do
  echo "=================================================="
  echo "Submit summing kernels at condition number: $cond"
  # weighting file
  eventlist="/ccs/proj/geo111/wenjie/AdjointTomography/M24/source_weights/output/source_weights.txt"
  if [ ! -f $eventlist ]; then
    echo "Missing eventlist file: $eventlist"
    continue
  fi

  output_dir="$outputbase/$cond"
  if [ ! -d $output_dir ]; then
	  echo "mkdir -p $output_dir"
	  mkdir -p $output_dir
  fi
  outputfn=$output_dir/"kernels_sum.bp"

  echo "aprun -n $NPROC ./bin/xsum_kernels $eventlist $kernels_dir $outputfn"
  $runcmd -n $NPROC ./bin/xsum_kernels $eventlist $kernels_dir $outputfn
  echo "done at: `date`"
done

echo
echo "All done at: `date`"