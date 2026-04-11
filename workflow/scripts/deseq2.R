library(DESeq2)
library(ggplot2)
library(pheatmap)

counts <- read.table(snakemake@input[["counts"]], header=TRUE, row.names=1)
coldata <- read.table(snakemake@input[["metadata"]], header=TRUE, row.names=1)

colnames(counts) <- gsub("aligned.", "", colnames(counts))
colnames(counts) <- gsub("_sorted.bam", "", colnames(counts))

coldata$condition <- as.factor(coldata$condition)

dds <- DESeqDataSetFromMatrix(countData=counts, colData=coldata, design=~condition)
dds <- DESeq(dds)
res <- results(dds)

write.csv(as.data.frame(res), snakemake@output[[1]])

res_df <- as.data.frame(res)

# Volcano
res_df$significance <- "NS"
res_df$significance[res_df$pvalue < 0.05 & res_df$log2FoldChange > 1] <- "Up"
res_df$significance[res_df$pvalue < 0.05 & res_df$log2FoldChange < -1] <- "Down"

volcano <- ggplot(res_df, aes(log2FoldChange, -log10(pvalue), color=significance)) +
  geom_point()

ggsave(snakemake@output[[2]], volcano)

# PCA
vsd <- vst(dds)
png(snakemake@output[[3]])
plotPCA(vsd, intgroup="condition")
dev.off()

# Heatmap
topgenes <- head(order(res$pvalue), 20)
mat <- assay(vsd)[topgenes, ]

png(snakemake@output[[4]])
pheatmap(mat, scale="row")
dev.off()
