# 🧬 RNA-Seq Analysis of Breast Cancer (Tumor vs Normal)

---

## 🧬 About Breast Cancer

Breast cancer is a disease in which cells in the breast grow uncontrollably, forming tumors. It occurs due to genetic mutations that disrupt normal cell growth and division.

### 🔑 Key Characteristics
- Origin: Begins in **lobules (milk glands)** or **ducts (milk channels)**

### 🔬 Types of Breast Cancer (Molecular Classification)
- **Luminal A** → Hormone receptor-positive, less aggressive *(focus of this study)*
- **Luminal B** → More aggressive than Luminal A  
- **HER2-enriched** → HER2 protein overexpression  
- **Triple-Negative Breast Cancer (TNBC)** → Lacks ER, PR, HER2  

---

## 🧪 Why RNA-Seq in Breast Cancer?

RNA-Seq helps to:
- Identify gene expression differences (Tumor vs Normal)
- Discover biomarkers
- Understand cancer pathways
- Support precision medicine

---

## 📌 Project Overview

This project performs a complete RNA-Seq pipeline using public data.

### 🧬 Study Title
**Tumor circadian clock strength influences metastatic potential and predicts patient prognosis in Luminal A breast cancer**

### 🎯 Objective
Identify **Differentially Expressed Genes (DEGs)** between tumor and normal samples.

---

## 📂 Dataset & Reference Information

### 🔬 Dataset
- Database: NCBI GEO / BioProject  
- Accession: **PRJNA975550 (GSE233242)**  
- Organism: *Homo sapiens*  
- Data Type: RNA-Seq (paired-end)

### 📖 Study Description
Investigates how **circadian clock genes** influence breast cancer progression.

---

### 🧬 Reference Data
- Genome: **GRCh38**
- FASTA: `Homo_sapiens.GRCh38.dna.primary_assembly.fa`
- GTF: `Homo_sapiens.GRCh38.110.gtf`

---

## 🧰 Tools & Technologies Used

| Tool | Type | Definition | Why Used |
|------|------|-----------|----------|
| aria2 | Download | Multi-thread downloader | Faster data download |
| FastQC | QC | Quality control tool | Check read quality |
| fastp | Preprocessing | Read trimming tool | Remove adapters & low-quality reads |
| HISAT2 | Alignment | Splice-aware aligner | Map reads to genome |
| SAMtools | Processing | BAM toolkit | Convert, sort, index |
| featureCounts | Quantification | Read counting tool | Generate gene counts |
| seqtk | Utility | FASTQ processing | Subsampling reads |
| R | Programming | Statistical computing | Data analysis |
| DESeq2 | Bioconductor | DEG analysis | Statistical testing |
| ggplot2 | Visualization | Plotting library | PCA, volcano |
| pheatmap | Visualization | Heatmap plotting | Expression patterns |
| Linux (WSL) | Environment | Unix system | Run bioinformatics tools |
| Git & GitHub | Version control | Code management | Track project |
| Snakemake | Workflow | Pipeline manager | Automation & reproducibility |

---

## ⚙️ Pipeline Workflow

1️⃣ Data Download  
2️⃣ Quality Control (FastQC)  
3️⃣ Read Trimming (fastp)  
4️⃣ Reference Preparation  
5️⃣ Alignment (HISAT2)  
6️⃣ BAM Processing (SAMtools)  
7️⃣ Quantification (featureCounts)  
8️⃣ Differential Expression (DESeq2)  
9️⃣ DEG Filtering  
🔟 Visualization (PCA, Volcano, Heatmap)

---

## 🔁 Snakemake Workflow 

This project includes a **Snakemake pipeline** to automate the RNA-Seq workflow.
- Converted manual pipeline into automated workflow
- Defined rules for:
  - QC
  - Trimming
  - Alignment
  - Counting
  - DEG analysis
- Used **DAG (Directed Acyclic Graph)** for dependency tracking

### ▶️ How to Run
```bash
cd workflow
snakemake --cores 1
```
---

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
├── scripts/           # bash script
├── subset/            # Subsampled reads
├── trimmed/           # Cleaned reads
├── workflow/          # Snakemake pipeline
```

---

## 📊 Results Summary
 - Total genes analyzed: ~62,000
 - Significant DEGs: 27 genes
 - Statistical method: Wald test (DESeq2)

---

### Key Outputs:
 - deseq2_results.csv → Full results
 - significant_genes.csv → Filtered DEGs
 - pca_plot.png → Sample clustering
 - volcano_plot.png → DEG visualization
 - heatmap.png → Expression patterns

---

## ⚠️ Challenges Faced
❌ Memory limitations in WSL → HISAT2 crashes
### ✅ Solution:
 - Reduced threads (-p 1)
 - Used smaller genome (chr1 & chr2)
 - Subsampled reads using seqtk

---

## 🧠 Key Learnings
 - Real RNA-Seq pipelines require high computational resources
 - Memory optimization is crucial
 - Workflow automation tools (Snakemake/Nextflow) are important
 - Understanding each step improves debugging ability

---

## 🚀 Future Improvements
 - Run full genome analysis (not subset)
 - Use cloud/HPC environment
 - Convert pipeline into:
     - ⚡ Nextflow
 - Add functional enrichment analysis (GO, KEGG)

---

## 📌 Conclusion
This project successfully demonstrates a complete RNA-Seq workflow from raw data to differential gene expression analysis, including:
 - Data preprocessing
 - Alignment
 - Quantification
 - Statistical analysis
 - Visualization

✔️ Successfully implemented both manual pipeline + Snakemake automation

---

## 🙌 Acknowledgement
Dataset sourced from NCBI GEO BioProject PRJNA975550.

---

## ⭐ Author
**Sathya**

Bioinformatics Enthusiast | RNA-Seq Analysis | Computational Biology
