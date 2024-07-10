######## On beluga ######### 20/03/2023
#unzip *.zip password in email
for zipfile in *.zip; do unzip -P xxx "$zipfile"; done

# Cat all VCF from imputation (run as job, it takes a while)
module load bcftools
bcftools concat *dose.vcf.gz -o imputed.vcf

# Compress (takes ~ 1h)
bgzip imputed.vcf

# Convert to plink files from VCF
module load plink/1.9b_6.21-x86_64
plink --vcf imputed.vcf.gz --const-fid --out ../plink/imputed
cd ../plink/

# Remove "chr" from first line
sed 's/chr//g' imputed.bim > nochr.imputed.bim

# Create a list of unique identifiers in alphabetical order to be retreived in 1000G
cat nochr.imputed.bim | awk '{ if ($5 < $6) print $1 "\t" $1 "_" $4 "_" $5 "_" $6 "\t0\t" $4 "\t" $5 "\t" $6; else print $1 "\t" $1 "_" $4 "_" $6 "_" $5 "\t0\t" $4 "\t" $5 "\t" $6; }' > imputed.bim_alphaOrder

# Get only identifiers from AIMs list (hg38)
plink --bed imputed.bed --bim imputed.bim_alphaOrder --fam imputed.fam --extract ../../external/aimList.passPositions_alphaOrder_wHG38 --make-bed --out aim.harbin

# merge with 1000G
plink -bfile ../../external/1000G_overlap_hg38 --merge-list ../../merge_aims_files.txt --out ../../aim.ctsn_harbin_1000G
cd ../../

# compute PCs
plink -bfile aim.ctsn_harbin_1000G --out PC_aim.ctsn_harbin_1000G --pca 30 header tabs --threads 1
# plink -bfile aim.ctsn_harbin_1000G --recode --out aim.ctsn_harbin_1000G
#### END ####

