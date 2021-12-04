#Whole pipeline for flagellin gene pacbio amplicon sequencing
#Only raw read file "HUY5581A1_4pM_m54196_180925_230246.subreads.bam" is input files. E. coli flagellin gene database "ecHdatabase.alignregion.fna" and barcodes sequences "barcodes.fasta" are provided publicly in this depository. All the intermediate files are generated by the scripts.
#Subscripts can be found in the same directory in this depository.

#1 To dump ccs sequences from raw pacbio read file "HUY5581A1_4pM_m54196_180925_230246.subreads.bam" with initial quality control
ccs --minPredictedAccuracy=0.999 --minLength=700 --maxLength=2000 --minPasses=3 ccs.bam HUY5581A1_4pM_m54196_180925_230246.subreads.bam

#2 To demultiplex the barcoded reads
lima --different --ccs --num-threads 10 ccs.bam barcodes.fasta demultiplex.bam

#3 To transfer the file format into text
samtools view -h -o demultiplex.sam demultiplex.bam

#4 Second round quality control to remove primer dimers, which lima may not be sensitive enough to detect.
perl filterDouble.pl demultiplex.sam barcodes.fasta filterQLDouBC.sam 700 2000 0.999

#5 To dump sequences into fasta file
perl tofasta.pl filterQLDouBC.sam demultiplex.lima.counts 1000 reads.realsample

#6 Close referenced annotation of reads
blastall -p blastn -i reads.realsample.fasta -d ecHdatabase.alignregion.fna -o ec.bsn -F F -e 1e-10 -b 1 -v 1 -a 12 -m 8

#7 To extract reads with identity with known E. coli flagellin genes
perl takeFasta.pl ec.bsn reads.realsample.fasta realsample.ec.fasta

#8 Third round quality control to remove reads with mismatches at two terminals and/or low identity to E. coli flagellin genes
#Cutoff: identity>0.85 two side <50 mismatch/uncovered, 20 bps at two terminals are primers 
perl groupRead.pl ec.bsn realsample.ec.fasta ec.out 

#9 To extract sequences from the filtered list above
perl takeFasta.pl ec.out realsample.ec.fasta filtered.ec 

#10 To combine reads from the same ASV to generate "ASV list" and "ASV representative sequences"
perl combineReads.pl ec.bsn ecHdatabase.alignregion.fna filtered.ec.fasta ec.asv

#11 To remove ASVs with <3 copies
perl filterFasta.pl ec.asv.strain.fna ec.asv.strain.list ec.asv.final.fna

#12 To generate final "ASV table"
perl list2ASVTable.pl ec.asv.final.fna.list ec.asv-table.txt

