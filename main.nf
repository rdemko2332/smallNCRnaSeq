#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//--------------------------------------------------------------------------
// Param Checking
//--------------------------------------------------------------------------

if (!params.input) {
    throw new Exception("Missing params.input")
}
else if (!params.genome) {
    throw new Exception("Missing params.genome")
}
else if (!params.sampleName) {
    throw new Exception("Missing params.sampleName")
}


file = channel.fromPath([params.input])

//--------------------------------------------------------------------------
// Includes
//--------------------------------------------------------------------------

include { smallNCRNASeq } from './modules/smallNCRNASeq.nf'

//--------------------------------------------------------------------------
// Main Workflow
//--------------------------------------------------------------------------

workflow {
    smallNCRNASeq(file)
}