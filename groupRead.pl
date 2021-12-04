#!/usr/bin/perl -w
use Bio::SeqIO;
my $in =shift;
my $db = shift;
my $out=shift;
unless(defined $in and defined $db and defined $out){
	print "Usage: perl $0 <in> <db(fasta)> <out>\n";
	exit;
}
my %l;
my $file = Bio::SeqIO->new(-format=>'fasta',-file=>"$db");
while(my $fasta = $file->next_seq){
	my $name = $fasta->display_id;
	my $length = $fasta->length;
	$l{$name} = $length;
}
open IN,$in;
open OUT,">$out";
open ERR,">$out.err";
open SHO,">$out.lenerr";
my %ecoli;
while(<IN>){
	my @t = split /\t/;
	my $read = $t[0];
	if(defined $ecoli{$read}){
		next;
	}
	my $hit = $t[1];
#	my $ident = $t[2];
	my $aln = $t[3];
	my $snp = $t[4];
	my $gap = $t[5];
	my $start = $t[6];
	my $end = $t[7];
	if($start > $end){
		($start,$end) = ($end,$start);
	}
	my $length = $l{$read};
	my $three = $length -$end;
	my $five = $start-1;
	my $ident = 1-$snp/($aln-$gap);
	my $cov = ($aln-$gap)/$l{$read};
	if($length<=700 or $length>=1900){
		print SHO "$read\t$hit\t$length\t$five\t$three\t$ident\t$cov\n";
	}
	elsif($three<50 and $five <50 and $ident > 0.85){
		$ecoli{$read}++;
		print OUT "$read\t$hit\t$length\t$five\t$three\t$ident\t$cov\n";
	}
	else{
		print ERR "$read\t$hit\t$length\t$five\t$three\t$ident\t$cov\n";
	}
}
