#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process runRnaSeqMapper {
  input:
    path fastq
    path genome
    val sampleName

  output:
    path '*.bam'

  script:
    """
    bwa index $genome
    srnaMapper -r $fastq -g $genome -o temp.sam 
    samtools view -buS temp.sam | samtools sort -o ${sampleName}.bam
    """
}

process PCRDuplicates {
  publishDir "$params.outputDir", pattern: "*.bam", mode: "copy", saveAs: { filename -> "${sampleName}.bam" }
  publishDir "$params.outputDir", pattern: "*.bam.bai", mode: "copy", saveAs: { filename -> "${sampleName}.bam.bai" }
  publishDir "$params.outputDir", pattern: "*.bed", mode: "copy", saveAs: { filename -> "${sampleName}.bed" }

  input:
    path bamfile
    val removePCRDuplicates
    val writeBedFile
    val sampleName

  output:
    path 'out.*'

  script:
    template 'pcrDuplicates.bash'
}

workflow smallNCRNASeq {
  take:
    fastq

  main:
    runRnaSeqMapper(fastq,params.genome, params.sampleName)
    // PCRDuplicates(bowtieResults, params.removePCRDuplicates, params.writeBedFile, params.sampleName)
}