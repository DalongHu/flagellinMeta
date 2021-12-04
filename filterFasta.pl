#!/usr/bin/perl -w
my $in =shift;
my $list = shift;
my $out = shift;
unless(defined $in and defined $list and defined $out){
	print "Usage: perl $0 <in(asv.strain.fasta)> <list(asv.filtered.list)> <out(fasta)>\n";
	exit;
}
my %h;
my %l;
open LST,$list;
while(<LST>){
	chomp;
	my @t = split /\t/;
	$h{$t[-1]}++;
	$l{$t[0]} = $t[1];
}
close LST;
foreach my $key(keys %h){
	if($h{$key} <3){
		delete $h{$key};
	}
}
open IN,$in;
open OUT,">$out";
while(<IN>){
	chomp;
	if(/^>(.*)/){
		my $name = $1;
		if(defined $h{$name}){
			my $seq = <IN>;
			print OUT ">$name\n$seq";
		}
	}
}
open OUT2,">$out.list";
foreach my $k (keys %l){
	if(defined $h{$l{$k}}){
		my $asv = $l{$k};
		print OUT2 "$k\t$asv\n";
	}
}
