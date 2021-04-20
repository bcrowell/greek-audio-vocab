#!/bin/perl

use List::Util qw(shuffle);

@v = shuffle(<audio/*.mp3>);
$l = join('|pause.mp3|',@v);
#$c = "mp3cut -o vocab.wav $l";
$c = "ffmpeg -i 'concat:$l' -acodec copy vocab.mp3";
print "$c\n";
system $c;



