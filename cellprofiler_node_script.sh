#!/bin/bash

#SBATCH --job-name=CellProfiler_Batch 	# job name (shows in queue)
#SBATCH --time=12:00:00			# wait time (HH:MM:SS)
#SBATCH --partition=UNLIMITED 		# specify a partition
#SBATCH --cpus-per-task=1		# number of cores per task
#SBATCH --mem-per-cpu=4gb		# memory per core
#SBATCH --nodes=1			# number of nodes
#SBATCH --nodelist=node1		# specify node name
#SBATCH --ntasks=112			# number of parallel tasks
#SBATCH --output=parallel_%j.log	# standard output and error log

conda activate cp4

for i in $(seq 1 40 4441); do
    BATCH_START=$i
    BATCH_END=$((i+39))
    srun --ntasks=1 cellprofiler -p Batch_data.h5 -c -r -f $BATCH_START -l $BATCH_END -o output/batch_${i}_out &
done
wait

cp -r output/batch_*_out/Images output/
mkdir output/Sheets
{ head -n1 -q output/batch_1_out/Sheets/MyExpt_Experiment.csv && tail -n+2 -q output/batch_*_out/Sheets/MyExpt_Experiment.csv; } > output/Sheets/Combined_Experiment.csv &
{ head -n1 -q output/batch_1_out/Sheets/MyExpt_Image.csv && tail -n+2 -q output/batch_*_out/Sheets/MyExpt_Image.csv; } > output/Sheets/Combined_Image.csv &
{ head -n1 -q output/batch_1_out/Sheets/MyExpt_Nuclei.csv && tail -n+2 -q output/batch_*_out/Sheets/MyExpt_Nuclei.csv; } > output/Sheets/Combined_Nuclei.csv &
{ head -n1 -q output/batch_1_out/Sheets/MyExpt_Cytoplasm.csv && tail -n+2 -q output/batch_*_out/Sheets/MyExpt_Cytoplasm.csv; } > output/Sheets/Combined_Cytoplasm.csv &
{ head -n1 -q output/batch_1_out/Sheets/MyExpt_Cell.csv && tail -n+2 -q output/batch_*_out/Sheets/MyExpt_Cell.csv; } > output/Sheets/Combined_Cell.csv &
wait

rm -rf output/batch_*_out
