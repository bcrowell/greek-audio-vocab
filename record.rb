#!/bin/ruby
# coding: utf-8

# usage:
#  ./record.rb λογος
#  ./record.rb mp3/λογος
#  ...these both write to audio/λογος.mp3
#  ./record.rb -f λογος
#  ...overwrite any preexisting file

mic = 'tonor' # 'tonor' or 'logi'

def die(message)
  print message,"\n"
  exit(-1)
end

def s(command)
  print "#{command}\n"
  system(command)
end

if ARGV.length<1 then
  die("not enough arguments")
end

force = (ARGV[0]=="-f")
if force then ARGV.shift end
f = ARGV[0]

if !(f=~/^audio\//) then
  f = "audio/#{f}"
end
if !(f=~/\.mp3$/) then
  f = "#{f}.mp3"
end

if FileTest.exist?(f) and not force then die("file #{f} already exists") end

# https://stackoverflow.com/questions/2089421/capturing-ctrl-c-in-ruby
# Control-C is used to stop recording, so don't let it terminate the script.
trap "SIGINT" do end
print "Use control-C to stop recording."

if mic=='tonor'
  s("arecord -f S16_LE -r 44100 --device=\"hw:1,0\" temp.wav") # is 3,0 when webcam is also hooked up
else
  s("arecord -f S16_LE -r 48000 --device=\"hw:1,0\" temp.wav")
end

trap "SIGINT" do die("script killed") end

# Do the manipulations with vidu first, because those have the effect of forcing the sampling rate to stay at 44.1 kHz.
s("vidu amplify temp.wav temp2.wav                        && mv temp2.wav temp.wav") # normalize gain to -23 dB
s("vidu trim temp.wav temp2.wav 0.3 -0.3                  && mv temp2.wav temp.wav") # cut silence and key click from start, and similarly at end
s("sox temp.wav -r 16000 temp2.wav channels 1             && mv temp2.wav temp.wav") # lower sampling rate and mix any stereo down to mono
s("ffmpeg -i temp.wav -af \"afftdn=nf=-25\" temp2.wav     && mv temp2.wav temp.wav") # reduce noise
s("lame --abr 14 -m m temp.wav #{f}")
print "success\n"
s("mpg321 -K #{f}")
s("rm -f temp.wav")

