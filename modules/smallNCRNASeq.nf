#!/usr/bin/env nextflow
nextflow.enable.dsl=2

process mapToTrnaRrna {
  input:
    path fastq
    path trnaRrnaGenome
    val sampleName

  output:
    path "${sampleName}_trna_rrna.bam"

  script:
    """
    bwa index $trnaRrnaGenome
    srnaMapper -r $fastq -g $trnaRrnaGenome -o temp_trna_rrna.sam
    samtools view -buS temp_trna_rrna.sam | samtools sort -o ${sampleName}_trna_rrna.bam
    """
}

process removeMappedReads {
  input:
    path bamFile
    val sampleName

  output:
    path "${sampleName}_filtered.fastq"

  script:
    """
    samtools fastq -f 4 $bamFile -o ${sampleName}_filtered.fastq
    """
}

process archiveFilteredReads {
  publishDir "${params.outputDir}", mode: 'copy'

  input:
    path filteredFastq
    val sampleName

  output:
    path "${sampleName}_filtered.fastq.tar.gz"

  script:
    """
    cp $filteredFastq ${sampleName}.filtered.fastq
    tar czf ${sampleName}_filtered.fastq.tar.gz ${sampleName}.filtered.fastq
    """
}

process runRnaSeqMapper {
  publishDir "${params.outputDir}", mode: 'copy'

  input:
    path filteredFastq
    path genome
    val sampleName
    val type
    val minLength
    val maxLength    

  output:
    path '*.bam'
    path '*.bai'    

  script:
    """
    filterFastqByLength.pl --readsFile $filteredFastq --type $type --min $minLength --max $maxLength --outFile filtered_by_length.fastq
    bwa index $genome
    srnaMapper -r filtered_by_length.fastq -g $genome -o temp.sam 
    samtools view -buS temp.sam | samtools sort -o ${sampleName}.bam
    samtools index ${sampleName}.bam
    """
}

workflow smallNCRNASeq {

  take:
    fastq

  main:
    // Step 1: Map reads to tRNA/rRNA sequences
    mapped = mapToTrnaRrna(fastq, params.trnaRrnaGenome, params.sampleName)

    // Step 2: Remove mapped reads (keep unmapped)
    filtered = removeMappedReads(mapped, params.sampleName)

    // Step 3: Archive filtered reads (optional)
    archived = archiveFilteredReads(filtered, params.sampleName)

    // Step 4: Run main mapping on filtered reads
    runRnaSeqMapper(filtered, params.genome, params.sampleName, params.type, params.minLength, params.maxLength)
}
