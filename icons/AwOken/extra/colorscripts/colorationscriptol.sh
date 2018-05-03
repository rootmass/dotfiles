#!/bin/bash

color=$2

command="-colorize $color"
#command="-sigmoidal-contrast 5x5"

COL=${color:0:2}${color:3:2}${color:6:2}
WOKENCOL="AwOken-$COL"
ICNST="AwOken"
ICNSTP="awoken"
ICNSTCNF=".AwOkenrc"
ICNS="$HOME/.icons"

#echo $WOKENCOL

if [ $3 ]; then
  SCRIPTS="$ICNS/$ICNST/extra/colorscripts"
  CARTELLA=$3
else
  SCRIPTS=`pwd`
  cd ../../../
  CARTELLA=`pwd`/$WOKENCOL
fi

# && [ $k != ".png" ]

##########################################################################################
colorizeaaoverlay() {
  cd aaoverlay/
  for k in *; do
    if [ -f $k ] && ! [ -L $k ] && [ ${k##*.} != "sh" ] && [ ${k##*.} != "svg" ] && [ ${k##*.} != "pdf" ] && [ ${k: -5} != "1.png" ] && [ ${k: -5} != "9.png" ] && [ $k != "media-optical-audio.png" ] && [ $k != "media-optical-cd.png" ] && [ $k != "battery2.png" ];then
      convert $k $command $k &
    fi
  done
  cd ../
}
##########################################################################################
colorizeactions() {
  for k in *; do
    if [ -f $k ] && ! [ -L $k ] && [ ${k##*.} != "sh" ] && [ ${k##*.} != "svg" ] && [ ${k##*.} != "pdf" ] && [ ${k: -5} != "1.png" ] && [ ${k: -5} != "9.png" ] && [ $k != "address-book-new.png" ] && [ $k != "document-open-recent.png" ] && [ $k != "appointment-new.png" ] && [ $k != "bookmark_add.png" ] && [ $k != "bookmarks_list-add.png" ] && [ $k != "jockey-enabled.png" ] && [ $k != "jockey-free.png" ] && [ $k != "jockey-proprietary.png" ] && [ $k != "mail-send.png" ] && [ $k != "mail-message-new.png" ] && [ $k != "playlist-new.png" ] && [ $k != "playlist.png" ] && [ $k != "audio-cd-new.png" ] && [ $k != "contact-new.png" ] && [ $k != "gtk-spell-check.png" ] && [ $k != "internet-radio-new.png" ] && [ $k != "stock_new-tab.png" ] && [ $k != "window-new.png" ] && [ $k != "touchpad-enabled.png" ] && [ $k != "touchpad-disabled.png" ] && [ $k != "iso-image-burn.png" ] && [ $k != "iso-image-new.png" ] && [ $k != "media-optical-data-new.png" ] && [ $k != "media-optical-video.png" ] && [ $k != "continue-data-project.png" ] && [ $k != "tab-close.png" ] && [ $k != "tab-close-other.png" ] && [ $k != "list-remove-user.png" ] && [ $k != "media-clear-playlist-amarok.png" ] && [ $k != "media-track-add-amarok.png" ] && [ $k != "media-track-remove-amarok.png" ] && [ $k != "user-group-delete.png" ] && [ $k != "user-group-new.png" ] && [ $k != "media-optical-video-new.png" ] && [ $k != "mail-mark-important.png" ] && [ $k != "mail-mark-junk.png" ] && [ $k != "mail-mark-notjunk.png" ] && [ $k != "mail-mark-unread.png" ] && [ $k != "rekonq.png" ];then
      convert $k $command $k &
    fi
    
    if [ -f $k ] && ! [ -L $k ]; then
      case $k in
          address-book-new.png)
            convert ../aaoverlay/addressboo.png $command ../apps/addressbook.png
            convert ../apps/addressbook.png ../overlay/overlay-add9.png -composite address-book-new.png
            
            convert ../aaoverlay/overlay-user-group-new.png ../overlay/overlay-add9.png -composite user-group-new.png
            convert ../aaoverlay/overlay-user-group-new.png ../overlay/overlay-close9.png -composite user-group-delete.png

            convert document-open-recent.png $command document-open-recent.png
            convert document-open-recent.png ../overlay/overlay-add9.png -composite appointment-new.png
            convert document-open-recent.png ../overlay/overlay-warningdownred9.png -composite ../status/appointment-missed.png
            convert document-open-recent.png ../overlay/overlay-appointment9.png -composite ../status/appointment-soon.png
          ;;
          audio-cd-new.png)
            convert ../devices/media-optical-audio.png $command ../devices/media-optical-audio.png
            convert ../devices/media-optical-video.png $command ../devices/media-optical-video.png
            convert ../devices/media-optical-cd.png $command ../devices/media-optical-cd.png
            
            convert ../devices/media-optical-audio.png ../overlay/overlay-add9.png -composite $k
            convert ../devices/media-optical-video.png ../overlay/overlay-add9.png -composite media-optical-video-new.png
            
            fl="media-optical-data-new.png"
            convert ../devices/media-optical-cd.png ../overlay/media-optical-data-new9.png -composite $fl
            convert $fl ../aaoverlay/media-optical-data-ne.png -composite $fl
            cp $fl continue-data-project.png
            convert $fl ../overlay/overlay-add9.png -composite $fl
          ;;
          bookmark_add.png)
            convert ../places/user-bookmarks.png $command ../places/user-bookmarks.png
            convert ../places/user-bookmarks.png ../overlay/overlay-add9.png -composite $k
            convert ../places/user-bookmarks.png ../overlay/overlay-multipleadd9.png -composite bookmarks_list-add.png
          ;;
          mail-mark-important.png)
            l="mail-send.png"
            convert $l $command $l
            convert $l ../overlay/stock_mail-compose-overlay9.png -composite ../apps/stock_mail-compose.png
            convert ../aaoverlay/mail-mark-jun.png ../overlay/mail-mark-junk-overlay9.png -composite mail-mark-junk.png
            convert ../aaoverlay/mail-mark-notjun.png ../overlay/mail-mark-notjunk-overlay9.png -composite mail-mark-notjunk.png
            convert ../aaoverlay/mail-mark-importan.png ../overlay/mail-mark-important-overlay9.png -composite mail-mark-important.png
            convert ../aaoverlay/mail-mark-unrea.png ../overlay/mail-mark-unread-overlay9.png -composite mail-mark-unread.png
            convert ../aaoverlay/mail-message-ne.png ../overlay/mail-message-new-overlay9.png -composite mail-message-new.png
          ;;
          playlist-new.png)
            convert playlist.png $command playlist.png
            convert playlist.png ../overlay/overlay-add9.png -composite $k          
            convert playlist.png ../overlay/overlay-close9.png -composite media-clear-playlist-amarok.png
          ;;
          contact-new.png)
            convert ../stock/stock_person.png $command ../stock/stock_person.png
            convert ../stock/stock_person.png ../overlay/overlay-adddown9.png -composite $k
            convert ../stock/stock_person.png ../overlay/overlay-closedown9.png -composite list-remove-user.png
          ;;
          gtk-spell-check.png)
            convert ../aaoverlay/gtk-spell-check-overla.png ../overlay/gtk-spell-check-overlay9.png -composite $k
          ;;
          internet-radio-new.png)
            convert ../emblems/emblem-remote.png $command ../emblems/emblem-remote.png
            convert ../emblems/emblem-remote.png ../overlay/overlay-addleft9.png -composite $k
          ;;
          stock_new-tab.png)
            convert ../apps/application-default-icon.png $command ../apps/application-default-icon.png
            convert ../aaoverlay/stock_new-ta.png ../overlay/overlay-addwindow9.png -composite $k
            convert ../aaoverlay/stock_new-ta.png ../overlay/overlay-closetab9.png -composite tab-close.png
            convert ../aaoverlay/tab-close-othe.png ../overlay/overlay-closetab9.png -composite tab-close-other.png
            
            convert ../apps/application-default-icon.png ../overlay/overlay-addwindow9.png -composite window-new.png
            convert ../apps/application-default-icon.png ../overlay/overlay-closewindow9.png -composite ../apps/gnome-panel-force-quit.png
          ;;
          touchpad-disabled.png)
            convert touchpad-enabled.png $command touchpad-enabled.png
            convert touchpad-enabled.png ../overlay/overlay-closebm9.png -composite $k
          ;;
      esac
      
        if [ ${k: -5} = "1.png" ] || [ ${k: -5} = "9.png" ]; then
          if [ $k != "document-print-preview1.png" ]; then
            ln -fs ../../../../$ICNST/clear/$i/$j/$k $k
          fi
        fi 
    fi
  done
}
##########################################################################################
colorizeapps() {
  for k in *; do
    if [ -f $k ] && ! [ -L $k ] && [ ${k##*.} != "sh" ] && [ ${k##*.} != "svg" ] && [ ${k##*.} != "pdf" ] && [ ${k: -5} != "1.png" ] && [ ${k: -5} != "9.png" ] && [ $k != "addressbook.png" ] && [ $k != "gnome-fs-bookmark-missing.png" ] && [ $k != "air.png" ] && [ $k != "fontforge.png" ] && [ $k != "restricted-manager.png" ] && [ $k != "rosso.png" ] && [ $k != "ripperX.png" ] && [ $k != "rubyripper.png" ] && [ $k != "stock_mail-compose.png" ] && [ $k != "stock_new-24h-appointment.png" ] && [ $k != "system-restart-panel.png" ] && [ $k != "system-shutdown-panel-restart.png" ] && [ $k != "tsclient.png" ] && [ $k != "updates-notifier.png" ] && [ $k != "usb-creator-gtk.png" ] && [ $k != "xpdf.png" ] && [ $k != "rpmdrake.png" ] && [ $k != "mandriva-update.png" ] && [ $k != "edit-urpm-sources.png" ] && [ $k != "bluetooth-active.png" ] && [ $k != "bluetooth.png" ] && [ $k != "xmlcopyeditor2.png" ] && [ $k != "claws-mail_logo.png" ] && [ $k != "checkgmail.png" ] && [ $k != "dia_gnome_icon.png" ] && [ $k != "vinagre.png" ] && [ $k != "unknown-channel.png" ] && [ $k != "application-default-icon.png" ] && [ $k != "bmp.png" ] && [ $k != "dockbarx.png" ] && [ $k != "config-date.png" ] && [ $k != "kdewindows.png" ] && [ $k != "system-file-manager.png" ] && [ $k != "pan.png" ] && [ $k != "qutim-message-new.png" ] && [ $k != "qutim.png" ] && [ $k != "krusader_root.png" ] && [ $k != "libreoffice3-base2.png" ] && [ $k != "libreoffice3-draw2.png" ] && [ $k != "libreoffice3-calc2.png" ] && [ $k != "libreoffice3-writer2.png" ] && [ $k != "libreoffice-main.png" ] && [ $k != "libreoffice3-math.png" ] && [ $k != "libreoffice3-impress2.png" ] && [ $k != "libreoffice3-printeradmin2.png" ] && [ $k != "orca.png" ] && [ $k != "gdu-check-disk.png" ] && [ $k != "gdu-detach.png" ] && [ $k != "gdu-eject.png" ] && [ $k != "gdu-error.png" ] && [ $k != "gdu-info.png" ] && [ $k != "gdu-mount.png" ] && [ $k != "gdu-multidisk-drive.png" ] && [ $k != "gdu-raid-array-start.png" ] && [ $k != "gdu-raid-array-stop.png" ] && [ $k != "gdu-smart-threshold.png" ] && [ $k != "gdu-unmount.png" ] && [ $k != "gdu-unmountable.png" ] && [ $k != "gdu-warning.png" ] && [ $k != "gnome-fs-bookmark-missing.png" ] && [ $k != "gnome-panel-force-quit.png" ] && [ $k != "gnome-panel-notification-area.png" ] && [ $k != "gphoto.png" ] && [ $k != "hwinfo.png" ] && [ $k != "hwbrowser.png" ] && [ $k != "hw.png" ] && [ $k != "jockey.png" ] && [ $k != "kubuntu.png" ] && [ $k != "launchpad.png" ] && [ $k != "software-update-urgent.png" ] && [ $k != "notification-area.png" ] && [ $k != "package-reinstall.png" ] && [ $k != "redshift.png" ];then
      convert $k $command $k &
    fi
    
    if [ -f $k ] && ! [ -L $k ]; then
      case $k in
          glippy1.png)
            convert $k $command $k
            cp ../aaoverlay/dockbar.png dockbarx.png
            cp ../aaoverlay/system-file-manage.png system-file-manager.png
            cp ../aaoverlay/pa.png pan.png
            convert qutim.png $command qutim.png
            convert qutim.png ../overlay/qutim-overlay9.png -composite qutim-message-new.png
            convert rekonq.png $command rekonq.png
            convert rekonq.png ../overlay/rekonq-overlay9.png -composite rekonq.png
          ;;
          bmp.png)
            convert $k $command $k
            convert $k ../overlay/overlay-add9.png -composite ../actions/media-track-add-amarok.png
            convert $k ../overlay/overlay-close9.png -composite ../actions/media-track-remove-amarok.png
          ;;
          bluetooth.png)
            cd ../
            wdname=`pwd`
            wdname=`basename $wdname`
            cd apps
            convert $k $command $k
            convert bluetooth-active.png $command bluetooth-active.png
            
            if [ $wdname != "22x22" ]; then
              convert ../overlay/bluetooth-active-overlay9.png $k -composite bluetooth-active.png
              k="../status/nm-secure-lock.png"
              convert $k $command $k
              convert bluetooth-active.png $k -composite ../status/bluetooth-paired.png
            else
              cd ../status
              convert printer-printing.png $command printer-printing.png
              convert printer-printing.png ../overlay/overlay-cellularprinter9.png -composite printer-error.png
              convert user-invisible.png $command user-invisible.png
              convert user-invisible.png ../overlay/overlay-cellularprinter9.png -composite user-offline.png
              cd ../apps
            fi
          ;;
          hwbrowser.png)
            convert hw.png $command hw.png
            convert hw.png ../overlay/eogyellow9.png -composite $k
            convert hw.png ../overlay/info9.png -composite hwinfo.png
          ;;
          xpdf.png)
            convert dia_gnome_icon.png $command dia_gnome_icon.png
            convert dia_gnome_icon.png ../overlay/dia-overlay9.png -composite dia_gnome_icon.png
            convert ../overlay/checkgmail-overlay9.png mail.png -composite checkgmail.png
            convert ../stock/stock_new-template.png ../aaoverlay/font-x-generi.png -composite ../mimetypes/font-x-generic.png
            convert ../mimetypes/font-x-generic.png ../aaoverlay/fontforg.png -composite fontforge.png
            convert ../mimetypes/video-x-generic.png $command ../mimetypes/video-x-generic.png
            
            convert ../places/user-desktop1.png ../aaoverlay/gdm.png -composite gdm1.png
            convert ../places/user-desktop1.png ../aaoverlay/gdm-login-photo.png -composite gdm-login-photo1.png
            #convert ../places/user-desktop1.png ../aaoverlay/aptdaemon-workin.png -composite ../categories/clear/preferences-desktop-personal1.png
            
            convert ../categories/applications-internet1.png ../aaoverlay/gnome-network-preferences.png -composite gnome-network-preferences1.png
            
            convert xmlcopyeditor2.png $command xmlcopyeditor2.png
            convert xmlcopyeditor2.png ../overlay/xmlcopyeditor9.png -composite xmlcopyeditor1.png
            convert ../overlay/xpdf9.png ../aaoverlay/xpd.png -composite $k
            convert ../aaoverlay/jocke.png ../overlay/jockey9.png -composite jockey.png
            convert ../aaoverlay/claw.png ../overlay/claws9.png -composite claws-mail_logo.png
            convert taskbar.png ../overlay/info9.png -composite gnome-panel-notification-area.png
            convert ../categories/applications-internet1.png ../aaoverlay/tsclien.png -composite tsclient.png
            
            convert gnome-panel-window-list.png ../overlay/vinagre-overlay9.png -composite vinagre.png
            convert ../devices/media-optical-cd.png ../overlay/rubyripper-overlay9.png -composite rubyripper.png
            convert evolution-calendar.png ../overlay/stock_new-24h-appointment-overlay9.png -composite stock_new-24h-appointment.png
            
            convert ../aaoverlay/ripper.png ../overlay/ripperX-overlay9.png -composite ripperX.png
            convert ../drive-harddisk/USB-HD.png ../aaoverlay/usb-creator-gt.png -composite usb-creator-gtk.png
            
            convert ../aaoverlay/gdu-raid-array.png ../overlay/gdu-raid-array-start-overlay9.png -composite gdu-raid-array-start.png
            convert ../aaoverlay/gdu-raid-array.png ../overlay/gdu-raid-array-stop-overlay9.png -composite gdu-raid-array-stop.png
            
            convert ../aaoverlay/openoffice-new.png ../overlay/overlay-add9.png -composite openoffice-new1.png
            convert ../aaoverlay/openofficeorg-printeradmin-new.png ../overlay/openofficeorg-printeradmin-new-overlay9.png -composite openofficeorg-printeradmin-new1.png
            
            l="../overlay/libreoffice-bottom.png"
            convert $l ../aaoverlay/libreoffice-bas.png -composite libreoffice3-base2.png
            convert $l ../aaoverlay/libreoffice-dra.png -composite libreoffice3-draw2.png
            convert $l ../aaoverlay/libreoffice-cal.png -composite libreoffice3-calc2.png
            convert $l ../aaoverlay/libreoffice-write.png -composite libreoffice3-writer2.png
            convert $l ../aaoverlay/libreoffice-mai.png -composite libreoffice-main.png
            convert $l ../aaoverlay/libreoffice-mat.png -composite libreoffice3-math.png
            convert $l ../aaoverlay/libreoffice-impres.png -composite libreoffice3-impress2.png
            convert $l ../aaoverlay/libreoffice-printe.png -composite libreoffice3-printeradmin2.png
            convert libreoffice-main.png ../overlay/libreoffice-printeuno.png -composite libreoffice3-printeradmin1.png
          ;;
          gnome-fs-bookmark-missing.png)
            convert ../places/user-bookmarks.png ../overlay/overlay-close9.png -composite $k
            rm okteta.png
            cp ../aaoverlay/multipart-encrypted.png okteta.png
          ;;
      esac
      
        if [ ${k: -5} = "1.png" ] || [ ${k: -5} = "9.png" ]; then
          if [ $k != "glippy1.png" ] && [ $k != "eog1.png" ] && [ $k != "openoffice-new1.png" ] && [ $k != "xmlcopyeditor1.png" ] && [ $k != "gdm1.png" ] && [ $k != "gdm-login-photo1.png" ] && [ $k != "it.vodafone.desktopwidget.75c5d0ac8e830b80bd4fbc0b32a23f0123e8c097.1.png" ] && [ $k != "gnome-logo-icon.png" ] && [ $k != "gnome-suse.png" ] && [ $k != "ubuntuone-client1.png" ] && [ $k != "openofficeorg-printeradmin-new1.png" ] && [ $k != "libreoffice3-printeradmin1.png" ] && [ $k != "gnome-network-preferences1.png" ]; then
            ln -fs ../../../../$ICNST/clear/$i/$j/$k $k
          fi
        fi      
    fi
      
    if [ $k = "ubuntuone-client1.png" ] || [ $k = "it.vodafone.desktopwidget.75c5d0ac8e830b80bd4fbc0b32a23f0123e8c097.1.png" ]; then
      convert $k $command $k
    fi
      
    if [ $k = "notification-area.png" ]; then
      ln -fs taskbar.png $k
    fi
  done
}
##########################################################################################
colorizecategories() {
  for k in *; do
    if [ -f $k ] && ! [ -L $k ] && [ ${k##*.} != "sh" ] && [ ${k##*.} != "svg" ] && [ ${k##*.} != "pdf" ] && [ ${k: -5} != "1.png" ] && [ ${k: -5} != "9.png" ] && [ $k != "preferences-color.png" ];then
      convert $k $command $k &
    fi
    
    if [ -f $k ] && ! [ -L $k ]; then  
        if [ ${k: -5} = "1.png" ] || [ ${k: -5} = "9.png" ]; then
          if [ $k != "preferences-desktop-personal1.png" ]; then
            ln -fs ../../../../$ICNST/clear/$i/$j/$k $k
          fi
        fi 
    fi
  done
  if [ -d "clear" ]; then
    cd clear/
    colorizecategories
    cd ../
  fi
}
##########################################################################################
colorizedevices() {
  for k in *; do
    if [ -f $k ] && ! [ -L $k ] && [ ${k##*.} != "sh" ] && [ ${k##*.} != "svg" ] && [ ${k##*.} != "pdf" ] && [ ${k: -5} != "1.png" ] && [ ${k: -5} != "9.png" ] && [ $k != "media-optical-audio.png" ] && [ $k != "media-optical-cd.png" ] && [ $k != "battery2.png" ];then
      convert $k $command $k &
    fi
  done
}
##########################################################################################
colorizeemblems() {
  for k in *; do
    if [ -f $k ] && ! [ -L $k ] && [ ${k##*.} != "sh" ] && [ ${k##*.} != "svg" ] && [ ${k##*.} != "pdf" ] && [ ${k: -5} != "1.png" ] && [ ${k: -5} != "9.png" ] && [ $k != "emblem-burn.png" ] && [ $k != "emblem-default.png" ] && [ $k != "emblem-urgent.png" ] && [ $k != "emblem-remote.png" ];then
      convert $k $command $k &
    fi
  done
}
##########################################################################################
colorizeemotes() {
  for k in *; do
    if [ -f $k ] && ! [ -L $k ] && [ ${k##*.} != "sh" ] && [ ${k##*.} != "svg" ] && [ ${k##*.} != "pdf" ] && [ ${k: -5} != "1.png" ] && [ ${k: -5} != "9.png" ];then
      convert $k $command $k &
    fi
  done
}
##########################################################################################
colorizestatus() {
  for k in *; do
    if [ -f $k ] && ! [ -L $k ] && [ ${k##*.} != "sh" ] && [ ${k##*.} != "svg" ] && [ ${k##*.} != "pdf" ] && [ ${k: -5} != "1.png" ] && [ ${k: -5} != "9.png" ] && [ $k != "audio-volume-muted-blocking-panel.png" ] && [ $k != "dialog-warning-red.png" ] && [ $k != "dialog-warning.png" ] && [ $k != "gpm-battery-000.png" ] && [ $k != "gpm-battery-000-charging.png" ] && [ $k != "indicator-messages-new.png" ] && [ $k != "krb-expiring-ticket.png" ] && [ $k != "new-messages-red.png" ] && [ $k != "tray-message.png" ] && [ $k != "tray-message-new.png" ] && [ $k != "tray-new-im.png" ] && [ $k != "appointment-missed.png" ] && [ $k != "appointment-soon.png" ] && [ $k != "aptdaemon-add.png" ] && [ $k != "aptdaemon-cleanup.png" ] && [ $k != "aptdaemon-delete.png" ] && [ $k != "aptdaemon-resolve.png" ] && [ $k != "aptdaemon-wait.png" ] && [ $k != "aptdaemon-working.png" ] && [ $k != "bluetooth-paired.png" ] && [ $k != "dropboxstatus-idle.png" ] && [ $k != "dropboxstatus-logo.png" ] && [ $k != "dropboxstatus-x.png" ] && [ $k != "gpm-ac-adapter.png" ] && [ $k != "gpm-battery-040.png" ] && [ $k != "gpm-battery-020.png" ] && [ $k != "gpm-battery-020-charging.png" ] && [ $k != "gpm-battery-040-charging.png" ] && [ $k != "gpm-battery-060-charging.png" ] && [ $k != "gpm-battery-080-charging.png" ] && [ $k != "gpm-battery-100-charging.png" ] && [ $k != "gpm-battery-charged.png" ] && [ $k != "gpm-keyboard-000.png" ] && [ $k != "gpm-keyboard-020.png" ] && [ $k != "gpm-mouse-000.png" ] && [ $k != "gpm-mouse-020.png" ] && [ $k != "gpm-phone-000.png" ] && [ $k != "gpm-phone-020.png" ] && [ $k != "image-loading.png" ] && [ $k != "image-missing.png" ] && [ $k != "krb-no-valid-ticket.png" ] && [ $k != "notification-gpm-brightness-kbd-invalid.png" ] && [ $k != "notification-gpm-brightness-lcd-invalid.png" ] && [ $k != "tray-away.png" ] && [ $k != "tray-offline.png" ] && [ $k != "user-idle.png" ] && [ $k != "tray-extended-away.png" ] && [ $k != "ubuntuone-client-error.png" ] && [ $k != "ubuntuone-client-offline.png" ] && [ $k != "user-typing.png" ] && [ $k != "weather-severe-alert.png" ] && [ $k != "xfce4-mixer-volume-ultra-low.png" ] && [ $k != "xfce4-mixer-volume-very-high.png" ] && [ $k != "gpm-battery-empty.png" ] && [ $k != "gpm-keyboard-020-overlaybis.png" ] && [ $k != "ubuntuone-client-idle.png" ] && [ $k != "weather-overcast.png" ] && [ $k != "nm-secure-lock.png" ] && [ $k != "notification-network-wireless-disconnected.png" ] && [ $k != "notification-network-ethernet-disconnected.png" ] && [ $k != "network-error.png" ] && [ $k != "network-cellular-signal-none.png" ] && [ $k != "microphone-sensitivity-muted.png" ] && [ $k != "printer-printing.png" ] && [ $k != "printer-error.png" ] && [ $k != "user-offline.png" ] && [ $k != "system-devices-panel-alert.png" ] && [ $k != "system-devices-panel-information.png" ];then
      convert $k $command $k &
    fi
    
    if [ -f $k ] && ! [ -L $k ]; then
      case $k in
          dropboxstatus-logo.png)
            convert $k $command $k
            convert $k ../overlay/dropboxstatus-idle-overlay9.png -composite dropboxstatus-idle.png
            convert $k ../overlay/dropboxstatus-x-overlay9.png -composite dropboxstatus-x.png
          ;;
          ubuntuone-client-error.png)
            convert ../apps/ubuntuone-client-emblem.png ../overlay/overlay-warning9.png -composite $k
            k="../status/ubuntuone-client-idle.png"
            convert $k $command $k
            k="../status/ubuntuone-client-offline.png"
            convert ../apps/ubuntuone-client-emblem.png ../overlay/ubuntuone-client-offline-overlay9.png -composite $k
          ;;
          gpm-battery-empty.png)
            convert krb-valid-ticket.png ../overlay/overlay-warningdownleftred9.png -composite krb-no-valid-ticket.png

            file="../aaoverlay/gpm-battery-overlay.png"
            convert gpm-ac-adapter.png $file -composite gpm-ac-adapter.png
            convert gpm-battery-020.png     $file -composite gpm-battery-020.png
            convert gpm-battery-040.png     $file -composite gpm-battery-040.png
            convert gpm-battery-charged.png $file -composite gpm-battery-charged.png
            
            file="../overlay/gpm-battery-flash-overlay9.png"
            convert gpm-battery-020.png $file -composite gpm-battery-020-charging.png
            convert gpm-battery-040.png $file -composite gpm-battery-040-charging.png
            convert gpm-battery-060.png $file -composite gpm-battery-060-charging.png
            convert gpm-battery-080.png $file -composite gpm-battery-080-charging.png
            convert gpm-battery-100.png $file -composite gpm-battery-100-charging.png

            convert ../aaoverlay/gpm-battery-empt.png ../overlay/overlay-batteryempty9.png -composite gpm-battery-empty.png
            convert ../aaoverlay/battery2y.png ../overlay/battery2-overlay9.png -composite ../devices/battery2.png
          ;;
          gpm-keyboard-000.png)
            convert ../aaoverlay/gpm-keyboard-overlay.png ../overlay/gpm-keyboard-000-overlay9.png -composite gpm-keyboard-000.png
            convert ../aaoverlay/gpm-mouse-overlay.png ../overlay/gpm-keyboard-000-overlay9.png -composite gpm-mouse-000.png
            convert ../aaoverlay/gpm-phone-overlay.png ../overlay/gpm-keyboard-000-overlay9.png -composite gpm-phone-000.png
            
            convert ../overlay/gpm-keyboard-020-overlay9.png ../aaoverlay/gpm-keyboard-battery-overlay.png -composite gpm-keyboard-020.png
            convert gpm-keyboard-020.png ../aaoverlay/gpm-mouse-overlay.png -composite gpm-mouse-020.png
            convert gpm-keyboard-020.png ../aaoverlay/gpm-phone-overlay.png -composite gpm-phone-020.png
            convert gpm-keyboard-020.png ../aaoverlay/gpm-keyboard-overlay.png -composite gpm-keyboard-020.png
          ;;
          tray-away.png)
            file="tray-away.png"
            convert $file $command $file
            convert ../overlay/overlay9tray-extended-away9.png $file -composite tray-extended-away.png
            convert ../overlay/overlay-tray-offline9.png ../aaoverlay/tray-offlin.png -composite tray-offline.png
            
            convert ../overlay/overlay-user-idle9.png ../aaoverlay/user-idl.png -composite user-typing.png
          ;;
          weather-overcast.png)
            convert $k $command $k
            convert $k ../overlay/overlay-warningdownleft9.png -composite weather-severe-alert.png          
            
            convert nm-signal-00.png             ../overlay/overlay-wirelesswired9.png -composite notification-network-wireless-disconnected.png
            convert ../devices/network-wired.png ../overlay/overlay-wirelesswired9.png -composite notification-network-ethernet-disconnected.png
            
            convert ../aaoverlay/mic.png ../overlay/overlay-mic9.png -composite microphone-sensitivity-muted.png
            
            convert network-idle.png ../overlay/overlay-warningnet9.png -composite network-error.png


            convert notification-gpm-brightness-lcd-disabled.png ../overlay/overlay-cellularprinter9.png -composite notification-gpm-brightness-lcd-invalid.png
            convert notification-gpm-brightness-kbd-disabled.png ../overlay/overlay-cellularprinter9.png -composite notification-gpm-brightness-kbd-invalid.png
            convert ../aaoverlay/cell.png ../overlay/overlay-cellularprinter9.png -composite network-cellular-signal-none.png
            
            convert haguichi-connecting-1.png $command haguichi-connecting-1.png
          ;;
          aptdaemon-working.png)
            k="../mimetypes/package-x-generic.png"
            convert $k ../overlay/aptdaemon-add9.png -composite aptdaemon-add.png
            convert $k ../aaoverlay/aptdaemon-cleanu.png -composite aptdaemon-cleanup.png
            convert $k ../overlay/aptdaemon-delete9.png -composite aptdaemon-delete.png
            convert $k ../aaoverlay/aptdaemon-resolv.png -composite aptdaemon-resolve.png
            convert ../devices/printer1.png ../aaoverlay/aptdaemon-resolv.png -composite ../actions/document-print-preview1.png
            convert ../devices/printer2.png ../overlay/overlay-close9.png     -composite ../actions/gtk-print-error2.png
            convert ../devices/printer2.png ../overlay/overlay-add9.png       -composite ../devices/gnome-dev-printer-new2.png
            convert ../devices/printer2.png ../overlay/overlay-warning9.png   -composite ../actions/gtk-print-warning2.png
            convert $k ../aaoverlay/aptdaemon-wai.png -composite aptdaemon-wait.png
            convert $k ../aaoverlay/aptdaemon-workin.png -composite aptdaemon-working.png
            convert $k ../aaoverlay/aptdaemon-downloa.png -composite ../apps/rpmdrake.png
            convert $k ../aaoverlay/aptdaemon-update-cach.png -composite ../apps/edit-urpm-sources.png
            convert $k ../aaoverlay/aptdaemon-upgrad.png -composite ../apps/mandriva-update.png
            convert $k ../aaoverlay/synapti.png -composite ../apps/synaptic.png
            convert $k ../status/nm-secure-lock.png -composite ../actions/jockey-proprietary.png
            convert $k ../aaoverlay/application-x-jar.png -composite ../mimetypes/application-x-jar.png
            convert $k ../aaoverlay/unknown-channe.png -composite ../apps/unknown-channel.png
          ;;
      esac
      
        if [ ${k: -5} = "1.png" ] || [ ${k: -5} = "9.png" ]; then
          if [ $k != "haguichi-connecting-1.png" ]; then
            ln -fs ../../../../$ICNST/clear/$i/$j/$k $k
          fi
        fi 
    fi
  done
}
##########################################################################################
colorizeplaces() {
  for k in *; do
    if [ -f $k ] && ! [ -L $k ] && [ ${k##*.} != "sh" ] && [ ${k##*.} != "svg" ] && [ ${k##*.} != "pdf" ] && [ ${k: -5} != "1.png" ] && [ ${k: -5} != "9.png" ] && [ $k != "user-bookmarks.png" ] && [ $k != "user-trash1.png" ] && [ $k != "user-trash1-full.png" ] && [ $k != "user-trash3.png" ] && [ $k != "user-trash3-full.png" ] && [ $k != "user-trash4.png" ] && [ $k != "user-trash4-full.png" ] && [ $k != "user-desktop1.png" ] && [ $k != "user-desktop3.png" ] && [ $k != "user-desktop5.png" ] && [ $k != "user-home1.png" ] && [ $k != "user-home3.png" ] && [ $k != "user-home5.png" ];then
      convert $k $command $k &
    fi
    
    if [ -f $k ] && ! [ -L $k ]; then
        if [ $k = "user-trash1-full.png" ] || [ $k = "user-trash1.png" ] || [ $k = "user-trash3-full.png" ] || [ $k = "user-trash3.png" ] || [ $k = "user-trash4-full.png" ] || [ $k = "user-trash4.png" ] || [ $k = "user-desktop1.png" ] || [ $k = "user-desktop3.png" ] || [ $k = "user-desktop5.png" ] || [ $k = "user-home1.png" ] || [ $k = "user-home3.png" ] || [ $k = "user-home5.png" ]; then
            ln -fs ../../../../$ICNST/clear/$i/$j/$k $k
        fi
    fi
    
      if [ -d $k ]; then
        if [ $k = "s11" ] || [ $k = "sonetto" ] || [ $k = "classy" ] || [ $k = "awoken" ] || [ $k = "original" ] || [ $k = "leaf" ] || [ $k = "snowsabre" ] || [ $k = "metal" ] || [ $k = "tlag" ]; then
          rm -rf $k
          ln -s ../../../../$ICNST/clear/$i/$j/$k $k
        elif [ $k = "token" ]; then
          cd $k/
          for w in *; do
            if [ -f $w ] && ! [ -L $w ]; then
              convert $w $command $w &
            fi
          done
          cd ../
        fi
      fi
  done
}
##########################################################################################
colorizestarthere() {
  for l in *;do
    if [ ${l: -5} = "1.png" ] || [ ${l: -5} = "3.png" ] || [ ${l: -5} = "5.png" ] || [ ${l: -5} = "7.png" ] || [ ${l: -5} = "9.png" ] || [ $l = "start-here-frugalware.png" ]; then
      convert $l $command $l
    else
      ln -fs ../../../../$ICNST/clear/$i/start-here/$l $l
    fi
    if [ $l = "start-here-umbrella3.png" ]; then
      convert $l ../overlay/start-here-umbrella9.png -composite $l
    fi
  done
}
##########################################################################################
colorizestock() {
  for k in *; do
    if [ -f $k ] && ! [ -L $k ] && [ ${k##*.} != "sh" ] && [ ${k##*.} != "svg" ] && [ ${k##*.} != "pdf" ] && [ ${k: -5} != "1.png" ] && [ ${k: -5} != "9.png" ] && [ $k != "stock_person.png" ] && [ $k != "stock_lock-open.png" ] && [ $k != "stock_lock-broken.png" ] && [ $k != "stock_lock-ok.png" ] && [ $k != "stock_new-template.png" ] && [ $k != "stock_new-drawing.png" ] && [ $k != "stock_new-formula.png" ] && [ $k != "stock_new-html.png" ] && [ $k != "stock_new-labels.png" ] && [ $k != "stock_new-master-document.png" ] && [ $k != "stock_new-presentation.png" ] && [ $k != "stock_new-spreadsheet.png" ]&& [ $k != "stock_new-text.png" ] && [ $k != "stock_certificate.png" ] && [ $k != "stock_script.png" ];then
      convert $k $command $k &
    fi
    
    if [ -f $k ] && ! [ -L $k ]; then
      case $k in
          stock_lock-broken.png)
            convert stock_lock-open.png $command stock_lock-open.png
            convert stock_lock-open.png ../overlay/overlay-closelock9.png -composite $k
            convert stock_lock-open.png ../overlay/overlay-applylock9.png -composite stock_lock-ok.png
          ;;
          stock_certificate.png)
            k="../mimetypes/application-certificate.png"
            convert $k $command $k
            k="../mimetypes/opera-unite-application.png"
            convert $k $command $k
            k="../mimetypes/x-office-calendar.png"
            cp ../aaoverlay/config-dat.png $k
          
            convert stock_new-template.png ../aaoverlay/overlay-stock_certificate.png -composite stock_certificate.png
            convert stock_new-template.png ../aaoverlay/overlay-stock_new-drawing.png -composite stock_new-drawing.png
            convert stock_new-template.png ../aaoverlay/overlay-stock_new-formula.png -composite stock_new-formula.png
            convert stock_new-template.png ../aaoverlay/overlay-stock_new-html.png -composite stock_new-html.png
            convert stock_new-template.png ../aaoverlay/overlay-stock_new-labels.png -composite stock_new-labels.png
            convert stock_new-template.png ../aaoverlay/overlay-stock_new-master-document.png -composite stock_new-master-document.png
            convert stock_new-template.png ../aaoverlay/overlay-stock_new-presentation.png -composite stock_new-presentation.png
            convert stock_new-template.png ../aaoverlay/overlay-stock_new-spreadsheet.png -composite stock_new-spreadsheet.png
            convert stock_new-template.png ../aaoverlay/overlay-stock_new-text.png -composite stock_new-text.png
            convert stock_new-template.png ../aaoverlay/scrip.png -composite stock_script.png
            
            convert stock_new-template.png ../aaoverlay/application-x-python.png -composite ../mimetypes/application-x-python.png
            convert stock_new-template.png ../aaoverlay/image-x-psd.png -composite ../mimetypes/image-x-psd.png
            convert stock_new-template.png ../aaoverlay/image-x-xcf.png -composite ../mimetypes/image-x-xcf.png
            convert stock_new-template.png ../aaoverlay/application-x-emerald.png -composite ../mimetypes/application-x-emerald.png
            convert stock_new-template.png ../aaoverlay/openofficeorg23-database.png -composite ../mimetypes/openofficeorg23-database.png
            convert stock_new-template.png ../aaoverlay/application-x-bittorrent.png -composite ../mimetypes/application-x-bittorrent.png
            convert stock_new-template.png ../aaoverlay/application-x-tellico.png -composite ../mimetypes/application-x-tellico.png
            convert stock_new-template.png ../aaoverlay/pdf.png -composite ../mimetypes/pdf.png
            convert stock_new-template.png ../aaoverlay/application-x-cd-image.png -composite ../mimetypes/application-x-cd-image.png
            convert stock_new-template.png ../aaoverlay/iso-image-bur.png -composite ../actions/iso-image-burn.png
            convert stock_new-template.png ../aaoverlay/text-x-java.png -composite ../mimetypes/text-x-java.png
            convert stock_new-template.png ../aaoverlay/text-x-javascript.png -composite ../mimetypes/text-x-javascript.png
            convert stock_new-template.png ../aaoverlay/application-rss+xml.png -composite ../mimetypes/application-rss+xml.png
            convert stock_new-template.png ../aaoverlay/application-x-sln.png -composite ../mimetypes/application-x-sln.png
            convert stock_new-template.png ../aaoverlay/application-x-theme.png -composite ../mimetypes/application-x-theme2.png
            convert stock_new-template.png ../aaoverlay/multipart-encrypted.png -composite ../mimetypes/multipart-encrypted.png
            convert stock_new-template.png ../aaoverlay/extension.png -composite ../mimetypes/extension.png
            convert stock_new-template.png ../aaoverlay/text-xml.png -composite ../mimetypes/text-xml.png
            convert stock_new-template.png ../aaoverlay/text-x-c.png -composite ../mimetypes/text-x-c.png
            convert stock_new-template.png ../aaoverlay/text-x-csharp.png -composite ../mimetypes/text-x-csharp.png
            convert stock_new-template.png ../aaoverlay/text-x-c++.png -composite ../mimetypes/text-x-c++.png
            convert stock_new-template.png ../aaoverlay/text-x-chdr.png -composite ../mimetypes/text-x-chdr.png
            convert stock_new-template.png ../aaoverlay/text-x-c++hdr.png -composite ../mimetypes/text-x-c++hdr.png
            convert stock_new-template.png ../aaoverlay/text-x-makefile.png -composite ../mimetypes/text-x-makefile.png
            convert stock_new-template.png ../aaoverlay/text-css.png -composite ../mimetypes/text-css.png
            convert stock_new-template.png ../aaoverlay/text-x-copying.png -composite ../mimetypes/text-x-copying.png
            convert stock_new-template.png ../aaoverlay/x-dia-diagram.png -composite ../mimetypes/x-dia-diagram.png
            convert stock_new-template.png ../aaoverlay/text-x-readme.png -composite ../mimetypes/text-x-readme.png
            convert stock_new-template.png ../aaoverlay/image-x-eps.png -composite ../mimetypes/image-x-eps.png
            
            #convert stock_new-template.png ../aaoverlay/.png -composite ../actions/.png
            
            convert stock_new-template.png ../aaoverlay/application-x-te.png -composite ../mimetypes/application-x-tex.png
            convert stock_new-template.png ../aaoverlay/font-bitma.png -composite ../mimetypes/font-bitmap.png

            convert stock_new-template.png ../overlay/file-broken-overlay9.png -composite ../mimetypes/file-broken.png
            convert ../mimetypes/application-x-cd-image.png ../overlay/overlay-adddown9.png -composite ../actions/iso-image-new.png
            
            convert stock_new-template.png ../aaoverlay/application-x-blender.png -composite ../mimetypes/application-x-blender.png
            convert stock_new-template.png ../aaoverlay/application-x-pitivi.png -composite ../mimetypes/application-x-pitivi.png
            convert stock_new-template.png ../overlay/application-x-ms-dos-executable9.png -composite ../mimetypes/application-x-ms-dos-executable.png
            convert ../mimetypes/application-x-ms-dos-executable.png ../aaoverlay/scrip.png -composite ../mimetypes/application-x-ms-dos-executable.png
            convert stock_new-template.png ../aaoverlay/gnome-mime-application-x-shockwave-flash.png -composite ../mimetypes/gnome-mime-application-x-shockwave-flash.png
            convert stock_new-template.png ../aaoverlay/vmlinuz.png -composite ../mimetypes/vmlinuz.png
            convert stock_new-template.png ../aaoverlay/wordprocessing.png -composite ../mimetypes/wordprocessing.png
            convert stock_new-template.png ../aaoverlay/application-x-trash.png -composite ../mimetypes/application-x-trash2.png
            
            convert stock_new-template.png ../aaoverlay/audio.png -composite ../mimetypes/audio.png
            convert stock_new-template.png ../aaoverlay/mp3.png -composite ../mimetypes/audio-mp3.png
            convert stock_new-template.png ../aaoverlay/m3u.png -composite ../mimetypes/audio-x-mpegurl.png
            
            convert stock_new-template.png ../aaoverlay/ogg.png -composite ../mimetypes/audio-x-speex+ogg.png
            
            convert ../stock/stock_new-template.png ../aaoverlay/aptdaemon-resolv.png -composite ../apps/orca.png
            
            #convert ../mimetypes/image.png ../aaoverlay/image_centered.png -composite ../mimetypes/image.png
            #convert ../mimetypes/image-x-ico.png ../aaoverlay/image_centered.png -composite ../mimetypes/image-x-ico.png
            #convert ../mimetypes/image-bmp.png ../aaoverlay/image_toptop.png -composite ../mimetypes/image-bmp.png
            #convert ../mimetypes/image-gif.png ../aaoverlay/image_top.png -composite ../mimetypes/image-gif.png
            #convert ../mimetypes/image-jpeg.png ../aaoverlay/image_top.png -composite ../mimetypes/image-jpeg.png
            #convert ../mimetypes/image-png.png ../aaoverlay/image_toptop.png -composite ../mimetypes/image-png.png
            #convert ../mimetypes/image-tiff.png ../aaoverlay/image_top.png -composite ../mimetypes/image-tiff.png
            convert ../mimetypes/image.png ../aaoverlay/image-load.png -composite ../mimetypes/image-loading.png
            convert ../mimetypes/image.png ../aaoverlay/gphot.png -composite ../apps/gphoto.png
            convert ../mimetypes/image.png ../aaoverlay/eog.png -composite ../apps/eog1.png

            #cd ../stock          
            #if [ $j != "22x22" ]; then
	          #  convert ../overlay/image-missing-overlay9.png ../aaoverlay/image_centered.png -composite ../status/image-missing.png
            #fi
          ;;
      esac
    fi
  done
}
##########################################################################################

case $1 in
  scratch)
    if [ -d $WOKENCOL ]; then
      rm -rf $WOKENCOL
    fi
    cp -dpRf $ICNST $WOKENCOL
    rm $WOKENCOL/$ICNSTP-icon-theme-customization
    mv $WOKENCOL/$ICNSTP-icon-theme-customization-clear $WOKENCOL/$ICNSTP-icon-theme-customization-$COL
    mv $WOKENCOL/extra/colorscripts/$ICNSTCNF $WOKENCOL/$ICNSTCNF-$COL
    rm $WOKENCOL/$ICNSTCNF
    rm $WOKENCOL/Installation_and_Instructions.pdf
    rm -rf $WOKENCOL/extra/colorscripts/
    if [ $1 != "scratch-and-go" ]; then
      exit
    fi
  ;;
  folder)
    echo "I'm going to process the "`pwd`"/$WOKENCOL/extra folder"
    cd $SCRIPTS/
    bash colorationextra.sh $color &
    cd $CARTELLA/clear
    
    for i in *; do
      cd $i
      echo "I'm going to process the "`pwd`" folder"
      
      if [ -d "aaoverlay" ]; then
        echo -e "   I'm going to process the "`pwd`"/aaoverlay folder"
        colorizeaaoverlay
      fi
      
      NEXTSTEP=$(pgrep -fx convert)
      while ! [ -z "$NEXTSTEP" ]; do
        sleep 0.1
        NEXTSTEP=$(pgrep -fx convert)
      done
      
      for j in *; do
        if [ ! -f $j ] && [ $j == "actions" ] || [ $j == "apps" ] || [ $j == "categories" ] || [ $j == "emblems" ] || [ $j == "emotes" ] || [ $j == "devices" ] || [ $j == "places" ] || [ $j == "start-here" ] || [ $j == "status" ] || [ $j == "stock" ]; then
          cd $j
          echo -e "   I'm going to process the "`pwd`" folder"
          if [ $j == "start-here" ]; then
            j="starthere"
          fi
          colorize$j
          
          NEXTSTEP=$(pgrep -fx convert)
          while ! [ -z "$NEXTSTEP" ]; do
            sleep 0.1
            NEXTSTEP=$(pgrep -fx convert)
          done
          
          cd ../
        elif [ ! -f $j ] && [ $j == "drive-harddisk" ] || [ $j == "overlay" ] || [ $j == "animations" ]; then
          rm -rf $j
          ln -s ../../../$ICNST/clear/$i/$j $j
        fi
      done
      cd ../
    done
  ;;
esac
