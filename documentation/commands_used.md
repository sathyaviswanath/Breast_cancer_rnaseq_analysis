# 📜 Commands Used in RNA-Seq Pipeline

This document contains all commands used in the RNA-Seq analysis pipeline, organized step-by-step with explanations.

---

## 1️⃣ System Setup

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential wget curl unzip nano
```
### Explanation:
 - Updates system packages
 - Installs essential tools for downloading and building software

## 2️⃣ Install Miniconda & Create Environment
```
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh

conda create -n rnaseq_env -y
conda activate rnaseq_env
```
### Explanation:
 - Installs Miniconda for package management
 - Creates isolated environment for RNA-seq tools

## 3️⃣ Install Required Bioinformatics Tools
```
conda install -c bioconda fastqc hisat2 samtools subread sra-tools -y
```
### Explanation:
 - FastQC → Quality control
 - HISAT2 → Alignment
 - SAMtools → File processing
 - Subread (featureCounts) → Quantification

## 4️⃣ Project Setup
```
mkdir -p rna_seq_analysis/{raw,fastq,qc,trimmed,aligned,counts,results,reference,data,scripts,documentation,images}
cd rna_seq_analysis
```

## 5️⃣ Download RNA-Seq Data
```
sudo apt install aria2 -y
cd fastq

aria2c -x 8 -s 8 ftp://ftp.sra.ebi.ac.uk/.../SRR24709144_1.fastq.gz
aria2c -x 8 -s 8 ftp://ftp.sra.ebi.ac.uk/.../SRR24709144_2.fastq.gz
(repeat for all samples)
```

## 6️⃣ Quality Control (QC)
```
fastqc fastq/*.fastq.gz -o qc/
```
### Explanation:
 - Generates quality reports for raw reads

## 7️⃣ Read Trimming
```
conda install -c bioconda fastp -y

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
```
### Explanation:
 - Removes low-quality bases and adapters
 - Generates QC reports

## 8️⃣ QC After Trimming
```
fastqc trimmed/*.fastq.gz -o qc/
```
### Explanation:
 - Confirms improvement in read quality

## 9️⃣ Reference Genome Setup
```
cd reference

aria2c https://ftp.ensembl.org/.../Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
gunzip Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz

aria2c https://ftp.ensembl.org/.../Homo_sapiens.GRCh38.110.gtf.gz
gunzip Homo_sapiens.GRCh38.110.gtf.gz
```
### Explanation:
 - Downloads genome and annotation files

## 🔟 Create Reduced Genome (chr1 & chr2)
```
samtools faidx Homo_sapiens.GRCh38.dna.primary_assembly.fa
samtools faidx Homo_sapiens.GRCh38.dna.primary_assembly.fa 1 2 > chr1_2.fa
```
### Explanation:
 - Extracts chromosomes 1 & 2 to reduce computational load

## 1️⃣1️⃣ Build HISAT2 Index
```
hisat2-build -p 1 chr1_2.fa chr1_2_index
```
### Explanation:
 - Builds index for alignment

## 1️⃣2️⃣ Subset Reads (Reduce Data Size)
```
conda install -c bioconda seqtk -y
mkdir subset

for sample in $(ls trimmed/*_1_trimmed.fastq.gz | sed 's/_1_trimmed.fastq.gz//' | xargs -n1 basename)
do
    seqtk sample -s100 trimmed/${sample}_1_trimmed.fastq.gz 200000 > subset/${sample}_1.fastq
    seqtk sample -s100 trimmed/${sample}_2_trimmed.fastq.gz 200000 > subset/${sample}_2.fastq
done
```
### Explanation:
 - Samples 200,000 reads to reduce memory usage

## 1️⃣3️⃣ Alignment (HISAT2)
```
for sample in $(ls subset/*_1.fastq | sed 's/_1.fastq//' | xargs -n1 basename)
do
    hisat2 -p 1 \
    -x reference/chr1_2_index \
    -1 subset/${sample}_1.fastq \
    -2 subset/${sample}_2.fastq \
    -S aligned/${sample}.sam
done
```
### Explanation:
 - Aligns reads to reference genome

## 1️⃣4️⃣ Convert SAM → BAM
```
for file in aligned/*.sam
do
    samtools view -@ 1 -bS $file > ${file%.sam}.bam
done
```

## 1️⃣5️⃣ Sort BAM Files
```
for file in aligned/*.bam
do
    samtools sort -@ 1 $file -o ${file%.bam}_sorted.bam
done
```

## 1️⃣6️⃣ Index BAM Files
```
for file in aligned/*_sorted.bam
do
    samtools index $file
done
```
### Explanation:
 - Prepares files for downstream analysis

## 1️⃣7️⃣ Gene Quantification
```
featureCounts -T 1 -p -B -C \
-a reference/Homo_sapiens.GRCh38.110.gtf \
-o counts/gene_counts.txt \
aligned/*_sorted.bam
```
### Explanation:
 - Counts reads mapped to genes

## 1️⃣8️⃣ Prepare Count Matrix
```
cd counts
cut -f1,7- gene_counts.txt > clean_counts.txt
```
### Explanation:
 - Removes unnecessary columns

## 1️⃣9️⃣ Metadata File
```
nano metadata.txt
sample condition
SRR24709144 Tumor
SRR24709146 Normal
SRR24709165 Tumor
SRR24709172 Normal
```

## 2️⃣0️⃣ Differential Expression Analysis (DESeq2)
```
counts <- read.table("counts/clean_counts.txt", header=TRUE, row.names=1)
coldata <- read.table("counts/metadata.txt", header=TRUE, row.names=1)

colnames(counts) <- gsub("aligned.", "", colnames(counts))
colnames(counts) <- gsub("_sorted.bam", "", colnames(counts))

library(DESeq2)

coldata$condition <- as.factor(coldata$condition)

dds <- DESeqDataSetFromMatrix(
    countData = counts,
    colData = coldata,
    design = ~ condition
)

dds <- DESeq(dds)
res <- results(dds)

write.csv(as.data.frame(res), file="counts/deseq2_results.csv")
```
### Explanation:
 - Performs statistical testing for differential expression

## 2️⃣1️⃣ Filter Significant Genes
```
res_df <- as.data.frame(res)
res_sig <- res_df[which(res_df$pvalue < 0.05), ]

write.csv(res_sig, file="counts/significant_genes.csv")
```

## 2️⃣2️⃣ Volcano Plot
```
library(ggplot2)

res_df$significance <- "Not Significant"
res_df$significance[res_df$pvalue < 0.05 & res_df$log2FoldChange > 1] <- "Up"
res_df$significance[res_df$pvalue < 0.05 & res_df$log2FoldChange < -1] <- "Down"

volcano_plot <- ggplot(res_df, aes(x=log2FoldChange, y=-log10(pvalue), color=significance)) +
  geom_point(alpha=0.6) +
  scale_color_manual(values=c("blue","grey","red")) +
  theme_minimal() +
  ggtitle("Volcano Plot")

ggsave("counts/volcano_plot_final.png", plot = volcano_plot, width = 8, height = 6)
```

## 2️⃣3️⃣ PCA Plot
```
vsd <- vst(dds)

png("counts/pca_plot.png")
plotPCA(vsd, intgroup="condition")
dev.off()
```

## 2️⃣4️⃣ Heatmap
```
library(pheatmap)

topgenes <- head(order(res$pvalue), 20)
mat <- assay(vsd)[topgenes, ]

png("counts/heatmap.png")
pheatmap(mat, scale="row")
dev.off()
```

## ✅ Pipeline Completed
### Outputs:
 - Gene counts
 - DEG results
 - Significant genes
 - PCA plot
 - Volcano plot
 - Heatmap
