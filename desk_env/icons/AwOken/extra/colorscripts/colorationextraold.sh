#!/bin/bash

color=$1

R=${color:0:3}
G=${color:4:3}
B=${color:8:3}

let "C=100-(100*$R)/255"
let "M=100-(100*$G)/255"
let "Y=100-(100*$B)/255"

command="-colorize $C/$M/$Y"
#command="-sigmoidal-contrast 5x5"

COL=${color:0:3}${color:4:3}${color:8:3}
WOKENCOL="AwOken-$COL"

cd ../../../$WOKENCOL/extra/

#echo `pwd`
#echo $color

#################################################################
cd pidgin/status/
cd 16/
convert invisible.png $command invisible.png 
convert chat.png $command chat.png 
convert person.png $command person.png
cd ../22/
convert invisible.png $command invisible.png 
convert chat.png $command chat.png 
convert person.png $command person.png
cd ../32/
convert invisible.png $command invisible.png 
convert chat.png $command chat.png 
convert person.png $command person.png
cd ../48/
convert invisible.png $command invisible.png 
convert chat.png $command chat.png 
convert person.png $command person.png
cd ../../tray/16/
convert ../../../../clear/128x128/status/tray-away.png tray-away.png 
convert ../../../../clear/128x128/status/tray-busy.png tray-busy.png 
convert ../../../../clear/128x128/status/tray-away.png -resize 16x16 tray-away.png 
convert ../../../../clear/128x128/status/tray-busy.png -resize 16x16 tray-busy.png 
convert ../../../../clear/128x128/status/tray-extended-away.png -resize 16x16 tray-extended-away.png 
convert ../../../../clear/128x128/status/tray-invisible.png -resize 16x16 tray-invisible.png 
convert ../../../../clear/128x128/status/tray-online.png -resize 16x16 tray-online.png 
convert ../../../../clear/128x128/status/tray-offline.png -resize 16x16 tray-offline.png 
convert tray-connecting.png $command tray-connecting.png
cd ../22/
convert ../../../../clear/128x128/status/tray-away.png tray-away.png 
convert ../../../../clear/128x128/status/tray-busy.png tray-busy.png 
convert ../../../../clear/128x128/status/tray-away.png -resize 22x22 tray-away.png 
convert ../../../../clear/128x128/status/tray-busy.png -resize 22x22 tray-busy.png 
convert ../../../../clear/128x128/status/tray-extended-away.png -resize 22x22 tray-extended-away.png 
convert ../../../../clear/128x128/status/tray-invisible.png -resize 22x22 tray-invisible.png 
convert ../../../../clear/128x128/status/tray-online.png -resize 22x22 tray-online.png 
convert ../../../../clear/128x128/status/tray-offline.png -resize 22x22 tray-offline.png 
convert tray-connecting.png $command tray-connecting.png
cd ../32/
convert ../../../../clear/128x128/status/tray-away.png tray-away.png 
convert ../../../../clear/128x128/status/tray-busy.png tray-busy.png 
convert ../../../../clear/128x128/status/tray-away.png -resize 32x32 tray-away.png 
convert ../../../../clear/128x128/status/tray-busy.png -resize 32x32 tray-busy.png 
convert ../../../../clear/128x128/status/tray-extended-away.png -resize 32x32 tray-extended-away.png 
convert ../../../../clear/128x128/status/tray-invisible.png -resize 32x32 tray-invisible.png 
convert ../../../../clear/128x128/status/tray-online.png -resize 32x32 tray-online.png 
convert ../../../../clear/128x128/status/tray-offline.png -resize 32x32 tray-offline.png 
convert tray-connecting.png $command tray-connecting.png
cd ../48/
convert ../../../../clear/128x128/status/tray-away.png tray-away.png 
convert ../../../../clear/128x128/status/tray-busy.png tray-busy.png 
convert ../../../../clear/128x128/status/tray-away.png -resize 48x48 tray-away.png 
convert ../../../../clear/128x128/status/tray-busy.png -resize 48x48 tray-busy.png 
convert ../../../../clear/128x128/status/tray-extended-away.png -resize 48x48 tray-extended-away.png 
convert ../../../../clear/128x128/status/tray-invisible.png -resize 48x48 tray-invisible.png 
convert ../../../../clear/128x128/status/tray-online.png -resize 48x48 tray-online.png 
convert ../../../../clear/128x128/status/tray-offline.png -resize 48x48 tray-offline.png 
convert tray-connecting.png $command tray-connecting.png
cd ../../../
#################################################################
cd cpufreq-applet/
for u in *; do
  convert $u $command $u
done
cd ../
#################################################################
cd caffeine/128x128/
for u in *; do
  convert $u $command $u
done
cd ../../
#################################################################
cd caffeine/24x24/
for u in *; do
  convert $u $command $u
done
cd ../../
#################################################################
cd emesene
convert ../../clear/128x128/status/tray-away.png away.png 
convert ../../clear/128x128/status/tray-away.png -resize 32x32 away.png 
convert ../../clear/128x128/status/tray-busy.png -resize 32x32 busy.png   
convert ../../clear/128x128/devices/camera-web.png -resize 22x22 cam.png 
convert ../../clear/128x128/actions/editclear.png -resize 22x22 eraser.png 
convert icon.png $command icon.png 
convert icon16.png $command icon16.png 
convert icon32.png $command icon32.png 
convert icon48.png $command icon48.png 
convert icon96.png $command icon96.png 
convert ../../clear/128x128/status/tray-extended-away.png -resize 32x32 idle.png 
convert ../../clear/128x128/status/tray-invisible.png -resize 32x32 invisible.png 
convert ../../clear/128x128/status/tray-online.png -resize 32x32 online.png 
convert login.png $command login.png 
convert ../../clear/128x128/status/tray-offline.png -resize 32x32 offline.png 
convert rotate-90.png $command rotate-90.png 
convert rotate-270.png $command rotate-270.png 
convert space.png $command space.png 
convert status-blocked.png $command status-blocked.png 
convert text.png $command text.png 
convert tool-eraser.png $command tool-eraser.png 
convert tool-paintbrush.png $command tool-paintbrush.png 
convert trayicon.png $command trayicon.png 
convert trayicon2.png $command trayicon2.png 
convert userPanel.png $command userPanel.png 
convert groupChat.png $command groupChat.png 
convert paintbrush.png $command paintbrush.png
cd ../
#################################################################
cd liferea/
for u in *; do
  convert $u $command $u
done
cd ../
#################################################################
cd wicd/
for u in *; do
  if ! [ -L $u ]; then
    convert $u $command $u
  fi
done
convert ../../clear/128x128/actions/gtk-disconnect.png -resize 22x22 no-signal.png
convert ../../clear/128x128/actions/gtk-connect.png -resize 22x22 wired.png
cd ../
