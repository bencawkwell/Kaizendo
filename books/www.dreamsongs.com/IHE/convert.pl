#!/usr/bin/perl

use v5.10.0;
use warnings;
use strict;
use autodie;

my $chapter = pop();
my $html = "tmp/ch$chapter.html";
my $txt  = "tmp/ch$chapter.txt";
my $tex  = "tmp/ch$chapter.tex";

for (@ARGV) {
	my $file=$_;
	open(my $infile, "<","$file") or die "Cannot read file '$file': $!";
	$_ = join "", <$infile>;
	close($infile);

	s/^.*<!-- START PAGE CONTENT -->//s;
	s/<!-- END PAGE CONTENT -->.*//s;
	s{^.*?</DIV>}{}s;
	s/<hr>.*?$//s;
	s/<HR>//s;
	s/<br>//s;
	s{<A HREF.*?#pgfId-(\d*)" CLASS="footnote.*?/A>}{\[\^$1\]}sg;
	s{<DIV CLASS="footnote">.*?<A NAME="pgfId-(\d*).*?</A>(.*?)</DIV>}{<p>[^$1]: $2 </p>}sg;
	s/<SPAN CLASS="footnoteNumber">.*?<\/SPAN>//sg;
	s/<H2 CLASS="Heading1TOC">.*?<\/H2>//sg;
	s{<P CLASS="Quote">(.*?)<\/P>}{<blockquote>$1</blockquote>}sg;
	s{&nbsp;}{ }sg;
	s{<H1 CLASS="Heading1">(.*?)</H1>}{<h2>$1</h2>}sg;
	s{<H1 CLASS="Heading2">(.*?)</H1>}{<h3>$1</h3>}sg;
	s{<H1 CLASS="Heading3">(.*?)</H1>}{<h4>$1</h4>}sg;
	s{<DIV.*?<IMG SRC="images/(.*?)".*?</A>(.*?)</H3>}{<p>![$2]($1)</p>}sg;

	my $text = $_;
	open(my $fh, ">","$file.$chapter");
	print $fh $text;
	close($fh);
}
system "mkdir -p tmp";
system "cat *.$chapter > $html";
system "rm *.$chapter";
system "pandoc -o $txt $html";

open(my $infile, "<",$txt);
$_ = join "", <$infile>;
s/\[\\(\^\d*)\]/[$1]/sg;
s/\*\*//sg;
close($infile);
open(my $fh, ">",$txt);
print $fh $_;
close($fh);
system "pandoc -o $tex $txt";
system "pandoc -o $html $txt";
system "rm $tex $txt";

#open($infile, "<",$tex);
#$_ = join "", <$infile>;
#s/\\section{\d.(.*?)}/\\chapter{$1}/s;
#close($infile);
#open($fh, ">",$tex);
#print $fh $_;
#close($fh);
