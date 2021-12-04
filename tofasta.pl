#!/usr/bin/perl -w
my $in = shift;
my $list = shift;
my $cut = shift;
my $out = shift;
unless(defined $in and defined $cut and defined $list and defined $out){
	print "Usage: perl $0 <in> <list> <cut(num of reads, estimate from lima.counts file)> <out>\n";
	exit;
}
open LST,$list;
my $f = <LST>;
my %h;
while(<LST>){
	chomp;
	my @t = split /\t/;
	$h{$t[0]}{$t[1]} = $t[4];
}
close LST;
open IN, $in;
open OUT,">$out.fasta";
open ERR,">$out.err.fasta";
while(<IN>){
	if(/^\@/){
		next;
	}
	my @t = split /\t/;
	$t[0]=~/\/(\d+)\/ccs/;
	my $name = $1;
	my $seq = $t[9];
	my $bar = $t[-8];
	$bar=~/bc:B:S,(\d+),(\d+)/;
	my $f = $1+1;
	my $r = $2-10;
	if($h{$f-1}{$r+10}<$cut){
		print ERR ">$f-$r-$name\n$seq\n";
	}
	else{
		print OUT ">$f-$r-$name\n$seq\n";
	}
}
