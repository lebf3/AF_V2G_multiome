module load plink/1.9b_6.21-x86_64

# merge files
plink --file ../geno_raw/part1/forward_plink/PLINK_240321_0402/forward_plink --merge ../geno_raw/part2/forward_plink/PLINK_060421_1107/forward_plink --make-bed --out merged.plink

# filter ind duplicated and with high missingness
plink --bfile merged.plink --remove sample.removed.txt --make-bed --out plink.ind.filt
plink --bfile plink.ind.filt --update-ids iid_Harbin.txt --make-bed --out plink.iid.renamed

# filter monomorphics variants and significant for HWE test
plink -bfile plink.iid.renamed --maf 0.0000001 --hwe 0.000001 --make-bed --out plink.filtered

# resolve Strand flip and Allele switch cases
source $HOME/ENV/bin/activate
snpflip --fasta-genome=/home/lebf3/projects/rrg-glettre/resources/hg19/ucsc.hg19.fasta --bim-file=plink.filtered.bim --output-prefix=plink.filtered.snpflip

plink -bfile plink.filtered --flip plink.filtered.snpflip.reverse --make-bed --out plink.flipped

# convert to VCF for Michigan imputation server
plink -bfile plink.flipped --recode vcf-iid --out vcf/plink.flipped

# bgzip and index
bgzip vcf/plink.flipped.vcf
module load bcftools
bcftools index vcf/plink.flipped.vcf.gz

# split per chromosome
for i in $(seq 1 22); do bcftools filter -r $i vcf/plink.flipped.vcf.gz -Oz -o vcf/plink.flipped.chr$i.vcf.gz; done

# submit VCFs to Topmep imputation servers