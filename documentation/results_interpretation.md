# 📊 RNA-Seq pipeline results and its interpretation
This document explains the biological and analytical meaning of the RNA-Seq results.

## 🧬 Overview
The analysis compared **tumor vs normal breast tissue samples** to identify differentially expressed genes (DEGs).

## 📈 Differential Expression Results
- Total genes analyzed: ~62,754  
- Significant genes identified: **27**

### 📌 Filtering Criteria
- Adjusted p-value (padj) < 0.05 / 0.1  
- |log2FoldChange| > 1  

## 🔬 What are DEGs?
Differentially Expressed Genes (DEGs) are genes that show significant changes in expression between two conditions.
- **Upregulated genes** → Higher expression in tumor  
- **Downregulated genes** → Lower expression in tumor  

## 📉 PCA Plot Interpretation
<p align="center">
  <img src="./images/pca_plot.png" width="800">
</p>

### 📌 What it shows
- Clustering of samples based on gene expression
### 🧠 Interpretation
- Tumor and normal samples should form separate clusters  
- Clear separation indicates strong biological differences  

## 🌋 Volcano Plot Interpretation
<p align="center">
  <img src="./images/volcano_plot_final.png" width="800">
</p>

### 📌 What it shows
- X-axis → log2FoldChange  
- Y-axis → -log10(p-value)  
### 🧠 Interpretation
- Points far from center → strong expression change  
- Top points → highly significant genes  
- Red points → significant DEGs  

## 🔥 Heatmap Interpretation
<p align="center">
  <img src="./images/heatmap.png" width="800">
</p>

### 📌 What it shows
- Expression levels of top genes across samples  

### 🧠 Interpretation
- Clusters of genes with similar expression patterns  
- Differences between tumor and normal samples  

## ⚠️ Limitations of This Analysis
- Used **subset of reads** (not full dataset)  
- Used **partial genome (chr1 & chr2)**  
- Limited computational resources  

👉 These may reduce:
- Number of detected DEGs  
- Biological accuracy  

## 🧠 Biological Insight
Even with limited data:
- Differences between tumor and normal samples are observable  
- Identified genes may relate to cancer pathways  
- Demonstrates RNA-Seq pipeline effectiveness  

## 🚀 Future Improvements
- Use full genome and full reads  
- Increase sample size  
- Perform:
  - Gene Ontology (GO) analysis  
  - Pathway analysis (KEGG)  
  - Functional enrichment  

## 📌 Conclusion
This analysis successfully:
- Identified differentially expressed genes  
- Visualized expression patterns  
- Demonstrated tumor vs normal differences  

Despite limitations, the pipeline provides meaningful biological insights into breast cancer gene expression.
