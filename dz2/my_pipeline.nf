params.results_dir = "results/"
SRA_list = params.SRA.split(",")

log.info ""
log.info " Q U A L I T Y C O N T R O L "
log.info "================================="
log.info "SRA number : ${SRA_list}"
log.info "Results location : ${params.results_dir}"

process DownloadFastQ {
input:
val sra

output:
path "${sra}/*"

script:
"""
/content/sratoolkit.3.0.0-ubuntu64/bin/fasterq-dump ${sra} -O ${sra}/
"""
}

process kallisto {
publishDir "${params.results_dir}"

input:
path x

output:
path "kllst"

script:
"""
mkdir kllst
wget https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/GRCh38_latest/refseq_identifiers/GRCh38_latest_genomic.fna.gz
gunzip GRCh38_latest_genomic.fna.gz
cp GRCh38_latest_genomic.fna GRCh38_latest_genomic.fasta
/content/kallisto/build/src/kallisto index -i GRCh38_latest_genomic.idx GRCh38_latest_genomic.fasta
/content/kallisto/build/src/kallisto quant -i GRCh38_latest_genomic.idx -o results x
"""
}

workflow {
data = Channel.of( SRA_list )
DownloadFastQ(data)
kallisto( DownloadFastQ.out.collect() )
}