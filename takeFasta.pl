#!/usr/bin/perl -w
use Bio::SeqIO;
my $in =shift;
my $db = shift;
my $out=shift;
unless(defined $in and defined $db and defined $out){
	print "Usage: perl $0 <in> <db(fasta)> <out>\n";
	exit;
}
my %h;
open IN,$in;
while(<IN>){
	chomp;
	my @t = split /\t/;
	$h{$t[0]}++;
}
close IN;
open OUT,">$out";
my $file = Bio::SeqIO->new(-format=>'fasta',-file=>"$db");
while(my $fasta = $file->next_seq){
	my $name = $fasta->display_id;
	if(defined $h{$name}){
		my $seq = $fasta->seq;
		print OUT ">$name\n$seq\n";
	}
}
