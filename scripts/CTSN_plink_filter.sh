# make binary file
module load plink/1.9b_6.21-x86_64
plink --file plink --make-bed

plink --bfile plink --update-ids iid_names.txt --make-bed --out plink.iid.renamed
plink --bfile plink.iid.renamed --remove iid_CTSN.txt --make-bed --out plink.ind.filt

# remove monomorphics
plink -bfile plink.ind.filt --maf 0.0000001 --make-bed --out plink_no_mono

# resolve Strand flip and Allele switch cases
source $HOME/ENV/bin/activate
snpflip --fasta-genome=/home/lebf3/projects/rrg-glettre/resources/hg19/ucsc.hg19.fasta --bim-file=plink_no_mono.bim --output-prefix=plink_no_mono.snpflip

plink -bfile plink_no_mono --flip plink_no_mono.snpflip.reverse --make-bed --out plink.flipped

# convert to VCF for Michigan imputation server
plink -bfile plink.flipped --recode vcf-iid --out vcf/plink.flipped

# bgzip and index
bgzip vcf/plink.flipped.vcf
module load bcftools
bcftools index vcf/plink.flipped.vcf.gz

# split per chromosome
for i in $(seq 1 22); do bcftools filter -r $i vcf/plink.flipped.vcf.gz -Oz -o vcf/plink.flipped.chr$i.vcf.gz; done

# submit VCFs to Topmep imputation server