#!/bin/bash

#SBATCH -t 0-1:59               # hours:minutes runlimit after which job will be killed
#SBATCH -c 10           # number of cores requested -- this needs to be greater than or equal to the number of cores you plan to use to run your job
#SBATCH --mem 32G
#SBATCH --job-name Kallisto.quant.stranded         # Job name
#SBATCH -o %j.Kallisto.quant.stranded.out                       # File to which standard out will be written
#SBATCH -e %j.Kallisto.quant.stranded.err               # File to which standard err will be written
#SBATCH --mail-user=soyezenforme@hotmail.com    # send mail to this address
#SBATCH --mail-type=END         # mail alert at the end


module load kallisto

cd /home/lebf3/projects/rrg-glettre/lebf3/Human_AF/geno_AF/data/linc01629/kallisto


merged='CM_LINC01629_1
CM_LINC01629_2
CM_LINC01629_3
CM_NTC_1
CM_NTC_2
CM_NTC_3
'

for i in $merged; do
        kallisto quant \
        -i /home/lebf3/projects/rrg-glettre/lebf3/Human_AF/hg38_transcriptome/gencode.v32-hg38.idx \
        -o /home/lebf3/projects/rrg-glettre/lebf3/Human_AF/geno_AF/data/linc01629/kallisto/${i} \
        -t 10 \
        -b 100 \
        --rf-stranded \
        /home/lebf3/projects/rrg-glettre/lebf3/Human_AF/geno_AF/data/linc01629/fastq/*${i}_1.fastq.gz \
        /home/lebf3/projects/rrg-glettre/lebf3/Human_AF/geno_AF/data/linc01629/fastq/*${i}_2.fastq.gz
done