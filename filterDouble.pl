#!/usr/bin/perl -w
use Bio::SeqIO;
my $in = shift;
my $bar = shift;
my $out = shift;
my $minlength = shift;
my $maxlength = shift;
my $minquality = shift;
unless(defined $in and defined $bar and defined $out){
	print "Usage: perl $0 <in> <barcodes.fasta> <out> [minlength] [maxlength] [minquality]\n";
	exit;
}
my $file = Bio::SeqIO->new(-format=>'fasta',-file=>"$bar");
my %h;
while(my $fasta = $file->next_seq){
	my $name = $fasta->display_id;
	my $seq = $fasta->seq;
	$h{$seq} = $name;
}
my @bar = keys %h;
open IN, $in;
open OUT,">$out";
open ERR,">$out.err";
while(<IN>){
	if(/^@/){
		next;
	}
	chomp;
	my @t = split /\t/;
	my $seq = $t[9];
	my $length = length $seq;
	if($length > $maxlength or $length < $minlength){
		next;
	}
	$rq = $t[14];
	if($rq =~/rq:f:(.*)/){
		my $test = $1;
		if($test < $minquality){
			next;
		}
	}
	my $err = 0;
	foreach my $key (@bar){
		if($seq =~ /$key/){
			print ERR "$_\t$h{$key}\n";
			$err = 1;
			last;
		}
	}
	unless($err){
		print OUT "$_\n";
	}

}
