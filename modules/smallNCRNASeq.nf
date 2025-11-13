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

workflow smallNCRNASeq {
  take:
    fastq

  main:
    runRnaSeqMapper(fastq,params.genome, params.sampleName)
}