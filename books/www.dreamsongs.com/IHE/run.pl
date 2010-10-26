#!/usr/bin/perl
use v5.10.0;
use warnings;
use strict;

my $output_chapter = 1;
my @chapterstarts = (10,18,25,35,42,52,60,66,72,84);
my $current_chapter = shift @chapterstarts;

for my $next_chapter (@chapterstarts) {
  my $inputfiles;
	for my $i ($current_chapter .. $next_chapter-1) {
		$inputfiles .= " IHE-$i.html";
	}
	
	system "perl convert.pl $inputfiles $output_chapter";
	$current_chapter = $next_chapter;
	my $chapterfile = "plain/ch" . $output_chapter . ".html";
	system "tidy --show-body-only yes --preserve-entities yes --input-encoding utf8 --output-html yes -o plain/ch$output_chapter.html -i tmp/ch$output_chapter.html";
	$output_chapter++;
}
