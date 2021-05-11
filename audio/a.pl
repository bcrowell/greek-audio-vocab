foreach $f(<*.mp3>) {
  $x=`vidu loudness $f | tail -1`;
  if ($x<-26) {
    print $f," ",$x;
    $z = -25-$x;
    $c="ffmpeg -y -i $f -filter:a 'volume=${z}dB' -c:v copy a.mp3 && mv a.mp3 $f";
    print $c,"\n";
    system $c;
  }
}
