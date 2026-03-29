#!/bin/bash

# ================================
# RNA-Seq Analysis Pipeline Script
# ================================

# Exit if any command fails
set -e

# Activate conda environment
source ~/miniconda3/etc/profile.d/conda.sh
conda activate rnaseq_env

# ================================
# 1. Quality Control (Raw Reads)
# ================================
echo "Running FastQC on raw data..."
fastqc fastq/*.fastq.gz -o qc/

# ================================
# 2. Read Trimming (fastp)
# ================================
echo "Running trimming..."

for sample in SRR24709144 SRR24709146 SRR24709165 SRR24709172
do
  fastp \
  -i fastq/${sample}_1.fastq.gz \
  -I fastq/${sample}_2.fastq.gz \
  -o trimmed/${sample}_1_trimmed.fastq.gz \
  -O trimmed/${sample}_2_trimmed.fastq.gz \
  -h qc/${sample}_fastp.html \
  -j qc/${sample}_fastp.json
done

# ================================
# 3. QC After Trimming
# ================================
echo "Running FastQC after trimming..."
fastqc trimmed/*.fastq.gz -o qc/

# ================================
# 4. Subset Reads (Low Memory)
# ================================
echo "Subsampling reads..."

mkdir -p subset

for sample in SRR24709144 SRR24709146 SRR24709165 SRR24709172
do
    seqtk sample -s100 trimmed/${sample}_1_trimmed.fastq.gz 200000 > subset/${sample}_1.fastq
    seqtk sample -s100 trimmed/${sample}_2_trimmed.fastq.gz 200000 > subset/${sample}_2.fastq
done

# ================================
# 5. Alignment (HISAT2)
# ================================
echo "Running alignment..."

for sample in SRR24709144 SRR24709146 SRR24709165 SRR24709172
do
    hisat2 -p 1 \
    -x reference/chr1_2_index \
    -1 subset/${sample}_1.fastq \
    -2 subset/${sample}_2.fastq \
    -S aligned/${sample}.sam
done

# ================================
# 6. Convert SAM → BAM
# ================================
echo "Converting SAM to BAM..."

for file in aligned/*.sam
do
    samtools view -@ 1 -bS $file > ${file%.sam}.bam
done

# ================================
# 7. Sort BAM
# ================================
echo "Sorting BAM files..."

for file in aligned/*.bam
do
    samtools sort -@ 1 $file -o ${file%.bam}_sorted.bam
done

# ================================
# 8. Index BAM
# ================================
echo "Indexing BAM files..."

for file in aligned/*_sorted.bam
do
    samtools index $file
done

# ================================
# 9. Gene Quantification
# ================================
echo "Running featureCounts..."

featureCounts -T 1 -p -B -C \
-a reference/Homo_sapiens.GRCh38.110.gtf \
-o counts/gene_counts.txt \
aligned/*_sorted.bam

# ================================
# 10. Prepare Count Matrix
# ================================
echo "Preparing count matrix..."

cut -f1,7- counts/gene_counts.txt > counts/clean_counts.txt

# ================================
# 11. Differential Expression (R)
# ================================
echo "Running DESeq2 analysis..."

Rscript - <<EOF
library(DESeq2)
library(ggplot2)
library(pheatmap)

counts <- read.table("counts/clean_counts.txt", header=TRUE, row.names=1)
coldata <- read.table("counts/metadata.txt", header=TRUE, row.names=1)

colnames(counts) <- gsub("aligned.", "", colnames(counts))
colnames(counts) <- gsub("_sorted.bam", "", colnames(counts))

coldata\$condition <- as.factor(coldata\$condition)

dds <- DESeqDataSetFromMatrix(
    countData = counts,
    colData = coldata,
    design = ~ condition
)

dds <- DESeq(dds)
res <- results(dds)

write.csv(as.data.frame(res), "counts/deseq2_results.csv")

res_df <- as.data.frame(res)
res_sig <- res_df[which(res_df\$pvalue < 0.05), ]
write.csv(res_sig, "counts/significant_genes.csv")

# Volcano Plot
res_df\$significance <- "Not Significant"
res_df\$significance[res_df\$pvalue < 0.05 & res_df\$log2FoldChange > 1] <- "Up"
res_df\$significance[res_df\$pvalue < 0.05 & res_df\$log2FoldChange < -1] <- "Down"

volcano <- ggplot(res_df, aes(x=log2FoldChange, y=-log10(pvalue), color=significance)) +
  geom_point(alpha=0.6) +
  scale_color_manual(values=c("blue","grey","red")) +
  theme_minimal()

ggsave("images/volcano_plot.png", plot = volcano)

# PCA Plot
vsd <- vst(dds)
png("images/pca_plot.png")
plotPCA(vsd, intgroup="condition")
dev.off()

# Heatmap
topgenes <- head(order(res\$pvalue), 20)
mat <- assay(vsd)[topgenes, ]

png("images/heatmap.png")
pheatmap(mat, scale="row")
dev.off()

EOF

echo "Pipeline completed successfully!"
