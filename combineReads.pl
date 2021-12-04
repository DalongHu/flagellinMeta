#!/usr/bin/perl -w
use Bio::SeqIO;
my $resBSN = shift;
my $ecDB = shift;
my $readFASTA = shift;
my $outFakeFasta = shift;
unless (defined $resBSN and defined $ecDB and defined $readFASTA and defined $outFakeFasta){
	print "Usage :perl $0 <resBSN> <ecDB(fasta)> <reads(fasta)> <out(ake fasta)>\n";
	exit;
}
open BSN,$resBSN;
my %hit;
my %strand;
while(<BSN>){
	my @t = split /\t/;
	$hit{$t[0]} = $t[1];
	if($t[8] > $t[9]){
		$strand{$t[0]} = '-';
	}
	else{
		$strand{$t[0]} = '+';
	}
}
close BSN;
my $ref = Bio::SeqIO->new(-format=>'fasta',-file=>$ecDB);
my %ref;
while(my $fasta = $ref->next_seq){
	my $name = $fasta->display_id;
	my $seq = $fasta->seq;
	$ref{$name} = $seq;
}
open FAK,">$outFakeFasta";
my %strain;
my %seqs;
my $count = 0;
open READ,">$outFakeFasta.strain.list";
open STR,">$outFakeFasta.strain.fna";
my $file = Bio::SeqIO->new(-format=>'fasta',-file=>$readFASTA);
while(my $fasta = $file->next_seq){
	my $name = $fasta->display_id;
	my $seq = $fasta->seq;
	if($strand{$name} eq '-'){
		$seq =~ tr/ATGC/TACG/;
		$seq = reverse $seq;
	}
	if(defined $seqs{$seq}){
		print READ "$name\t$seqs{$seq}\n";
		next;
	}
	my $refname = $hit{$name};
	my $serotye;
	if($refname=~/-(.*)$/){
		$serotype= $1;
	}
	else{
		print "error in $refname\n";
	}
	my $refseq = $ref{$refname};
	open OUT,">tmp/$name.fna";
	print OUT ">$refname\n$refseq\n>$name\n$seq\n";
	my $resMFA = `muscle -quiet -in tmp/$name.fna`;
	my $mfa = Bio::SeqIO->new(-format=>'fasta',-string =>$resMFA);
	my $n1 = $mfa->next_seq;
	my $s1 = $n1->seq;
	my $n2 = $mfa->next_seq;
	my $s2 = $n2->seq;
	my @s1 = split //,$s1;
	my @s2 = split //,$s2;
	my $con = '';
	for(my $i =0;$i<@s1;$i++){
		if($s1[$i] ne '-'){
			if($s2[$i] ne '-'){
				$con .= $s2[$i];
			}
			else{
				$con .= $s1[$i];
			}
		}
	}
	print FAK ">$name\n$con\n";
	unless(defined $strain{$con}){
		$count++;
		$strain{$con} = $serotype.'-'.$count;
			print STR ">$strain{$con}\n$con\n";
	}
	$seqs{$seq} = $strain{$con};
	print READ "$name\t$strain{$con}\n";
	`rm tmp/*`;
}
