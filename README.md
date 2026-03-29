# RNA-Seq Analysis of Breast Cancer (Tumor vs Normal)
## 🧬 About Breast Cancer
Breast cancer is a disease in which cells in the breast grow out of control, forming tumors. It occurs when genetic mutations cause breast cells to divide and multiply in an uncontrolled, chaotic way. 

### Key Characteristics
**Origin:** It typically begins in the milk-producing glands (lobules) or the tubes (ducts) that carry milk to the nipple.

### 🔬 Types of Breast Cancer (based on molecular classification)
 - **Luminal A →** Hormone receptor-positive, less aggressive (focus of this study)
 - **Luminal B →** More aggressive than Luminal A
 - **HER2-enriched →** Overexpression of HER2 protein
 - **Triple-negative breast cancer (TNBC) →** Lacks ER, PR, and HER2 receptors

### Why RNA-Seq in Breast Cancer?
RNA-Seq helps to:
 - Identify gene expression changes between tumor and normal tissue  
 - Discover biomarkers for diagnosis and prognosis
 - Understand cancer pathways and mechanisms
 - Support precision medicine approaches

## 📌 Project Overview
This project performs a complete RNA-Seq analysis pipeline using publicly available data from GEO / NCBI BioProject (PRJNA975550).

### 🧬 Study Title
Tumor circadian clock strength influences metastatic potential and predicts patient prognosis in Luminal A breast cancer

### 🎯 Objective
To identify differentially expressed genes (DEGs) between tumor and normal breast tissue samples using RNA-Seq data.

### 📂 Dataset & Reference Information
#### 🔬 Experimental Dataset
 - **Database:** NCBI GEO / BioProject
 - **Accession:** PRJNA975550 (GSE233242)
 - **Organism:** Homo sapiens
 - **Data Type:** RNA-Seq (paired-end)
 - **Samples:** Tumor samples and Matched normal samples

### 📖 Study Description
This dataset investigates how circadian clock gene activity influences breast cancer progression and metastasis. RNA-Seq was used to compare gene expression between tumor and normal tissues.

### 🧬 Reference Genome Data
 - **Genome:** GRCh38 (Human reference genome)
 - **FASTA File:** Homo_sapiens.GRCh38.dna.primary_assembly.fa
 - **Annotation File:** Homo_sapiens.GRCh38.110.gtf

## 🧰 Tools & Technologies Used

| Tool | Type | Definition | Why Used |
|------|------|------------|----------|
| aria2 | Download | Multi-thread downloader | Fast data download |
| FastQC | QC | Quality check tool | Assess read quality |
| Trimmomatic | Preprocessing | Read trimming | Remove adapters |
| HISAT2 | Alignment | Splice-aware RNA-Seq aligner | Map reads to genome |
| SAMtools | Processing | BAM file toolkit | Convert & sort |
| featureCounts | Quantification | Read counting | Gene expression matrix |
| seqtk | Utility | FASTQ tool | Subsampling reads |
| R | Programming | Statistical language | Analysis & plotting |
| DESeq2 | Bioconductor | DEG analysis | Statistical testing |
| ggplot2 | Visualization | Plotting library | PCA, volcano, heatmap |
| Linux (WSL) | Environment | Unix-based system on Windows | Run bioinformatics tools efficiently |
| Git & GitHub | Version control | Code management system | Track and share project |

## ⚙️ Pipeline Workflow

### 1️⃣ Data Download
 - FASTQ files downloaded using aria2
 - Reference genome & annotation downloaded
### 2️⃣ Quality Control
 - Checked read quality using FastQC
### 3️⃣ Read Trimming
 - Removed adapters and low-quality bases
### 4️⃣ Reference Preparation
 - Used GRCh38 genome
 - Created smaller genome (chr1 & chr2) due to memory constraints
 - Built HISAT2 index
### 5️⃣ Alignment
 - **Tool:** HISAT2
 - Aligned paired-end reads
 - **Output:** SAM files
### 6️⃣ BAM Processing
 - Converted SAM → BAM using SAMtools
 - Sorted BAM files
### 7️⃣ Quantification
 - **Tool:** featureCounts
 - Generated gene-level counts
### 8️⃣ Differential Expression Analysis
 - **Tool:** DESeq2 (R)
 - Compared tumor vs normal samples
### 9️⃣ DEG Filtering
 - **Criteria:**
     - Adjusted p-value < 0.05 / 0.1
     - |log2FoldChange| > 1

**Final significant genes:** 27
### 🔟 Visualization
 - PCA Plot → sample clustering
 - Volcano Plot → DEG distribution
 - Heatmap → expression patterns

## 📁 Project Structure
```
rna_seq_analysis/
├── aligned/           # BAM files
├── counts_data/       # Raw count files + metadata
├── documentation/     # commands + results interpretation
├── fastq/             # Downloaded FASTQ files
├── images/            # Plots (PCA, Volcano, Heatmap)
├── qc/                # Quality reports
├── raw/               # Raw data
├── reference/         # Genome + index files
├── results/           # Final results (DEGs)
├── scripts/           # Commands / pipeline scripts
├── subset/            # Subsampled reads
├── trimmed/           # Cleaned reads
```

## 📊 Results Summary
 - Total genes analyzed: ~62,000
 - Significant DEGs: 27 genes
 - Statistical method: Wald test (DESeq2)
### Key Outputs:
 - deseq2_results.csv → Full results
 - significant_genes.csv → Filtered DEGs
 - pca_plot.png → Sample clustering
 - volcano_plot_final.png → DEG visualization
 - heatmap.png → Expression patterns

## ⚠️ Challenges Faced
❌ Memory limitations in WSL → HISAT2 crashes
### ✅ Solution:
 - Reduced threads (-p 1)
 - Used smaller genome (chr1 & chr2)
 - Subsampled reads using seqtk

## 🧠 Key Learnings
 - Real RNA-Seq pipelines require high computational resources
 - Memory optimization is crucial
 - Workflow automation tools (Snakemake/Nextflow) are important
 - Understanding each step improves debugging ability

## 🚀 Future Improvements
 - Run full genome analysis (not subset)
 - Use cloud/HPC environment
 - Convert pipeline into:
     - 🔁 Snakemake
     - ⚡ Nextflow
 - Add functional enrichment analysis (GO, KEGG)

## 📌 Conclusion
This project successfully demonstrates a complete RNA-Seq workflow from raw data to differential gene expression analysis, including:
 - Data preprocessing
 - Alignment
 - Quantification
 - Statistical analysis
 - Visualization

Despite hardware limitations, meaningful biological insights were obtained.

## 🙌 Acknowledgement
Dataset sourced from NCBI GEO BioProject PRJNA975550.

## ⭐ Author
**Sathya**

Bioinformatics Enthusiast | RNA-Seq Analysis | Computational Biology
