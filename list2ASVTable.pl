#!/usr/bin/perl -w
my $in = shift;
my $out = shift;
unless(defined $in and defined $out){
	print "Usage: perl $0 <in(asv.final.list)> <out(otu table)>\n";
	exit;
}
my %h;
my %sum;
open IN,$in;
while(<IN>){
	chomp;
	/(\d+)-(\d+)-\d+\tH(\d+)-(\d+)/;
	my $f = $1;
	my $r = $2;
	my $sero = $3;
	my $type = $4;
	$h{$f}{$r}{$sero}{$type}++;
	$sum{$f}{$r}++;
}
close IN;
open OUT,">$out";
print OUT "barcodeF\tbarcodeR\tHantigen\tASV\treadNum\tabundance\n";
foreach my $f(sort {$a <=> $b} keys %h){
	foreach my $r(sort {$a <=> $b} keys %{$h{$f}}){
		foreach my $sero(sort {$a <=> $b} keys %{$h{$f}{$r}}){
			foreach my $type(sort {$a <=> $b} keys %{$h{$f}{$r}{$sero}}){
				my $readnum = $h{$f}{$r}{$sero}{$type};
				my $abundance = $readnum *100/$sum{$f}{$r};
				print OUT "$f\t$r\tH$sero\tH$sero-$type\t$readnum\t$abundance\n";
			}
		}
	}
}
