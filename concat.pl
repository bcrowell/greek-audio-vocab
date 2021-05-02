#!/bin/perl

use strict;

use List::Util qw(shuffle);

my $pause = "pause.mp3";
my @all_v = shuffle(<audio/*.mp3>);

my $n = @all_v;
my $small = 100; # initial guess, later refined
my $n_small = int($n/$small);
$small = int($n/$n_small); # make words per file more equal
$n_small = int($n/$small);
if ($small*$n_small<$n) {++$small}
print "$n words, building $n_small files, $small words each\n";
my @small_files = ();
for (my $k=0; $k<$n_small; $k++) {
  my $top = ($k+1)*$small;
  if ($top>$#all_v) {$top=$#all_v}
  my @v = @all_v[$k*$small..$top];
  my $k_plus_1 = $k+1;
  my $f = "vocab_$k_plus_1.mp3";
  concat(\@v,$f);
  push @small_files,$f;
}
concat(\@small_files,"vocab_all.mp3");

sub concat {
  my ($vref, $file) = @_;
  my @v = @$vref;
  my $l = join("|$pause|",@v);
  # my $c = "mp3cut -o vocab.wav $l";
  my $c = "ffmpeg -i 'concat:$l' -acodec copy $file";
  print "$c\n";
  system $c;
}




