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

#echo `pwd`
#echo `ls`

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
    cd $CARTELLA
    for i in *; do
      if [ -d $i ] && [ $i != "extra" ]; then
        cd $i
        bash $SCRIPTS/colorationscript.sh folder $color $CARTELLA/$i

        if [ $i = "clear" ];then
          cd ../
          bsname=`pwd`
          bsname=`basename $bsname`
          cd $i
          if [ $bsname != "categories" ]; then
            echo "I'm going to process the $i folder, located in: " `pwd`
            bash $SCRIPTS/colorationscript.sh colorize $color $CARTELLA/$i
          fi
        fi
        cd ../
      elif [ $i = "extra" ];then
        echo "I'm going to process the $i folder, located in: " `pwd`
        cd $SCRIPTS/
        bash colorationextra.sh $color
      fi
    done
  ;;
  colorize)
    #echo "I'm going to colorize this folder: " `pwd`
    for i in *; do
      if [ -d $i ] && [ $i != "extra" ] && [ $i != "s11" ] && [ $i != "sonetto" ] && [ $i != "classy" ] && [ $i != "awoken" ] && [ $i != "original" ] && [ $i != "leaf" ] && [ $i != "snowsabre" ] && [ $i != "metal" ] && [ $i != "tlag" ] && [ $i != "tlag" ] && [ $i != "start-here" ] && [ $i != "drive-harddisk" ] && [ $i != "mimetypes" ] && [ $i != "overlay" ] && [ $i != "animations" ]; then
        cd $i
          echo -e "  I'm going to colorize inside this folder: " `pwd`
          bash $SCRIPTS/colorationscript.sh colorize $color $CARTELLA/$i
        cd ../
      fi
      if [ -f $i ] && ! [ -L $i ] && [ ${i##*.} != "sh" ] && [ ${i##*.} != "svg" ] && [ ${i##*.} != "pdf" ] && [ $i != "audio-volume-muted-blocking-panel.png" ] && [ $i != "dialog-warning-red.png" ] && [ $i != "dialog-warning.png" ] && [ $i != "gpm-battery-000.png" ] && [ $i != "gpm-battery-000-charging.png" ] && [ $i != "indicator-messages-new.png" ] && [ $i != "krb-expiring-ticket.png" ] && [ $i != "new-messages-red.png" ] && [ $i != "tray-message.png" ] && [ $i != "tray-message-new.png" ] && [ $i != "tray-new-im.png" ] && [ ${i: -5} != "1.png" ] && [ ${i: -5} != "9.png" ] && [ $i != "addressbook.png" ] && [ $i != "address-book-new.png" ] && [ $i != "document-open-recent.png" ] && [ $i != "appointment-new.png" ] && [ $i != "user-bookmarks.png" ] && [ $i != "bookmark_add.png" ] && [ $i != "bookmarks_list-add.png" ] && [ $i != "gnome-fs-bookmark-missing.png" ] && [ $i != "jockey-enabled.png" ] && [ $i != "jockey-free.png" ] && [ $i != "jockey-proprietary.png" ] && [ $i != "mail-send.png" ] && [ $i != "mail-message-new.png" ] && [ $i != "playlist-new.png" ] && [ $i != "playlist.png" ] && [ $i != "help-faq.png" ] && [ $i != "audio-cd-new.png" ] && [ $i != "media-optical-audio.png" ]&& [ $i != "media-optical-cd.png" ] && [ $i != "air.png" ] && [ $i != "bluetooth-active-old.png" ] && [ $i != "fontforge.png" ] && [ $i != "gdu-check-disk.png" ] && [ $i != "gdu-detach.png" ] && [ $i != "gdu-eject.png" ] && [ $i != "gdu-error.png" ] && [ $i != "gdu-info.png" ] && [ $i != "gdu-mount.png" ] && [ $i != "gdu-multidisk-drive.png" ] && [ $i != "gdu-raid-array-start.png" ] && [ $i != "gdu-raid-array-stop.png" ] && [ $i != "gdu-smart-threshold.png" ] && [ $i != "gdu-unmount.png" ] && [ $i != "gdu-unmountable.png" ] && [ $i != "gdu-warning.png" ] && [ $i != "gnome-fs-bookmark-missing.png" ] && [ $i != "gnome-panel-force-quit.png" ] && [ $i != "gnome-panel-notification-area.png" ] && [ $i != "gnumeric.png" ] && [ $i != "gphoto.png" ] && [ $i != "hwinfo.png" ] && [ $i != "hwbrowser.png" ] && [ $i != "hw.png" ] && [ $i != "jockey.png" ] && [ $i != "kubuntu.png" ] && [ $i != "launchpad.png" ] && [ $i != "notification-area.png" ] && [ $i != "package-reinstall.png" ]  && [ $i != "redshift.png" ] && [ $i != "restricted-manager.png" ] && [ $i != "rosso.png" ] && [ $i != "ripperX.png" ] && [ $i != "rubyripper.png" ] && [ $i != "software-update-urgent.png" ] && [ $i != "stock_new-24h-appointment.png" ] && [ $i != "stock_mail-compose.png" ] && [ $i != "system-restart-panel.png" ] && [ $i != "system-shutdown-panel-restart.png" ] && [ $i != "tsclient.png" ] && [ $i != "updates-notifier.png" ] && [ $i != "usb-creator-gtk.png" ] && [ $i != "xpdf.png" ] && [ $i != "emblem-burn.png" ] && [ $i != "emblem-default.png" ] && [ $i != "emblem-urgent.png" ] && [ $i != "magnatune.png" ] && [ $i != "user-trash1-full.png" ] && [ $i != "user-trash1.png" ] && [ $i != "user-trash3-full.png" ] && [ $i != "user-trash3.png" ] && [ $i != "user-trash4-full.png" ] && [ $i != "user-trash4.png" ] && [ $i != "user-trash5-full.png" ] && [ $i != "user-trash5.png" ] && [ $i != "user-desktop1.png" ] && [ $i != "user-desktop3.png" ] && [ $i != "user-desktop5.png" ] && [ $i != "user-home1.png" ] && [ $i != "user-home3.png" ] && [ $i != "user-home5.png" ] && [ $i != "contact-new.png" ] && [ $i != "stock_person.png" ] && [ $i != "gtk-spell-check.png" ] && [ $i != "internet-radio-new.png" ] && [ $i != "emblem-remote.png" ] && [ $i != "stock_new-tab.png" ] && [ $i != "window-new.png" ] && [ $i != "touchpad-enabled.png" ] && [ $i != "touchpad-disabled.png" ] && [ $i != "stock_lock-open.png" ] && [ $i != "stock_lock-broken.png" ] && [ $i != "stock_lock-ok.png" ] && [ $i != "appointment-missed.png" ] && [ $i != "appointment-soon.png" ] && [ $i != "aptdaemon-add.png" ] && [ $i != "aptdaemon-cleanup.png" ] && [ $i != "aptdaemon-delete.png" ] && [ $i != "aptdaemon-resolve.png" ] && [ $i != "aptdaemon-wait.png" ] && [ $i != "aptdaemon-working.png" ] && [ $i != "bluetooth-paired.png" ] && [ $i != "dropboxstatus-idle.png" ] && [ $i != "dropboxstatus-logo.png" ] && [ $i != "dropboxstatus-x.png" ] && [ $i != "gpm-ac-adapter.png" ] && [ $i != "gpm-battery-040.png" ] && [ $i != "gpm-battery-020.png" ]  && [ $i != "gpm-battery-020-charging.png" ] && [ $i != "gpm-battery-040-charging.png" ] && [ $i != "gpm-battery-060-charging.png" ] && [ $i != "gpm-battery-080-charging.png" ] && [ $i != "gpm-battery-100-charging.png" ] && [ $i != "gpm-battery-charged.png" ] && [ $i != "gpm-keyboard-000.png" ] && [ $i != "gpm-keyboard-020.png" ] && [ $i != "gpm-mouse-000.png" ] && [ $i != "gpm-mouse-020.png" ] && [ $i != "gpm-phone-000.png" ] && [ $i != "gpm-phone-020.png" ] && [ $i != "image-loading.png" ] && [ $i != "image-missing.png" ] && [ $i != "krb-no-valid-ticket.png" ] && [ $i != ".png" ] && [ $i != "notification-gpm-brightness-kbd-invalid.png" ] && [ $i != "notification-gpm-brightness-lcd-invalid.png" ] && [ $i != "tray-away.png" ] && [ $i != "tray-offline.png" ] && [ $i != "user-idle.png" ] && [ $i != "tray-extended-away.png" ] && [ $i != "ubuntuone-client-error.png" ] && [ $i != "ubuntuone-client-offline.png" ] && [ $i != "user-typing.png" ] && [ $i != "weather-severe-alert.png" ] && [ $i != "xfce4-mixer-volume-ultra-low.png" ] && [ $i != "xfce4-mixer-volume-very-high.png" ] && [ $i != "rpmdrake.png" ] && [ $i != "mandriva-update.png" ] && [ $i != "edit-urpm-sources.png" ] && [ $i != "bluetooth-active.png" ] && [ $i != "gpm-battery-empty.png" ] && [ $i != "gpm-keyboard-020-overlaybis.png" ] && [ $i != "ubuntuone-client-idle.png" ] && [ $i != "weather-overcast.png" ] && [ $i != "battery2.png" ] && [ $i != "bluetooth.png" ] && [ $i != "nm-secure-lock.png" ] && [ $i != "stock_new-template.png" ] && [ $i != "stock_new-drawing.png" ] && [ $i != "stock_new-formula.png" ] && [ $i != "stock_new-html.png" ] && [ $i != "stock_new-labels.png" ] && [ $i != "stock_new-master-document.png" ] && [ $i != "stock_new-presentation.png" ] && [ $i != "stock_new-spreadsheet.png" ] && [ $i != "stock_new-text.png" ] && [ $i != "stock_certificate.png" ] && [ $i != "xmlcopyeditor2.png" ] && [ $i != "claws-mail_logo.png" ] && [ $i != "stock_script.png" ] && [ $i != "checkgmail.png" ] && [ $i != "e_icon.png" ] && [ $i != "vinagre.png" ] && [ $i != "notification-network-wireless-disconnected.png" ] && [ $i != "notification-network-ethernet-disconnected.png" ] && [ $i != "network-error.png" ] && [ $i != "network-cellular-signal-none.png" ] && [ $i != "microphone-sensitivity-muted.png" ] && [ $i != "iso-image-burn.png" ] && [ $i != "iso-image-new.png" ] && [ $i != "media-optical-data-new.png" ] && [ $i != "media-optical-video.png" ] && [ $i != "continue-data-project.png" ] && [ $i != "tab-close.png" ] && [ $i != "tab-close-other.png" ] && [ $i != "unknown-channel.png" ] && [ $i != "application-default-icon.png" ] && [ $i != "list-remove-user.png" ] && [ $i != "media-clear-playlist-amarok.png" ] && [ $i != "media-track-add-amarok.png" ] && [ $i != "media-track-remove-amarok.png" ] && [ $i != "user-group-delete.png" ] && [ $i != "user-group-new.png" ] && [ $i != "bmp.png" ] && [ $i != "media-optical-video-new.png" ] && [ $i != "printer-printing.png" ] && [ $i != "printer-error.png" ] && [ $i != "dockbarx.png" ] && [ $i != "config-date.png" ] && [ $i != "kdewindows.png" ] && [ $i != "system-file-manager.png" ] && [ $i != "pan.png" ] && [ $i != "qutim-message-new.png" ] && [ $i != "qutim.png" ] && [ $i != "krusader_root.png" ] && [ $i != "user-offline.png" ] && [ $i != "libreoffice3-base2.png" ]  && [ $i != "libreoffice3-draw2.png" ]  && [ $i != "libreoffice3-calc2.png" ]  && [ $i != "libreoffice3-writer2.png" ]  && [ $i != "libreoffice-main.png" ]  && [ $i != "libreoffice3-math.png" ]  && [ $i != "libreoffice3-impress2.png" ]  && [ $i != "libreoffice3-printeradmin2.png" ] && [ $i != "preferences-color.png" ] && [ $i != "orca.png" ] && [ $i != "system-devices-panel-alert.png" ] && [ $i != "system-devices-panel-information.png" ] && [ $i != "mail-mark-important.png" ] && [ $i != "mail-mark-junk.png" ] && [ $i != "mail-mark-notjunk.png" ] && [ $i != "mail-mark-unread.png" ] && [ $i != "application-x-tex.png" ] && [ $i != "font-bitmap.png" ] && [ $i != "font-x-generic.png" ] && [ $i != "file-broken.png" ]; then
# && [ $i != ".png" ]
        convert $i $command $i
      fi
      if [ -f $i ] && ! [ -L $i ]; then
        case $i in       
          glippy1.png)
            convert $i $command $i
            cp ../aaoverlay/dockbar.png dockbarx.png
            cp ../aaoverlay/system-file-manage.png system-file-manager.png
            cp ../aaoverlay/pa.png pan.png
            convert qutim.png $command qutim.png
            convert qutim.png ../overlay/qutim-overlay9.png -composite qutim-message-new.png
          ;;
          bmp.png)
            convert $i $command $i
            convert $i ../overlay/overlay-add9.png -composite ../actions/media-track-add-amarok.png
            convert $i ../overlay/overlay-close9.png -composite ../actions/media-track-remove-amarok.png
          ;;
          user-group-new.png)
            convert ../aaoverlay/overlay-user-group-new.png ../overlay/overlay-add9.png -composite user-group-new.png
            convert ../aaoverlay/overlay-user-group-new.png ../overlay/overlay-close9.png -composite user-group-delete.png
          ;;
          bluetooth.png)
            cd ../
            wdname=`pwd`
            wdname=`basename $wdname`
            cd apps
            convert $i $command $i
            convert bluetooth-active.png $command bluetooth-active.png
            
            if [ $wdname != "22x22" ]; then
              convert ../overlay/bluetooth-active-overlay9.png $i -composite bluetooth-active.png
              i="../status/nm-secure-lock.png"
              convert $i $command $i
              convert bluetooth-active.png $i -composite ../status/bluetooth-paired.png
            else
              cd ../status
              convert printer-printing.png $command printer-printing.png
              convert printer-printing.png ../overlay/overlay-cellularprinter9.png -composite printer-error.png
              convert user-invisible.png $command user-invisible.png
              convert user-invisible.png ../overlay/overlay-cellularprinter9.png -composite user-offline.png
              cd ../apps
            fi
          ;;
          address-book-new.png)
            convert ../aaoverlay/addressboo.png $command ../apps/addressbook.png
            convert ../apps/addressbook.png ../overlay/overlay-add9.png -composite $i  
          ;;
          appointment-new.png)
            convert document-open-recent.png $command document-open-recent.png
            convert document-open-recent.png ../overlay/overlay-add9.png -composite $i
            convert document-open-recent.png ../overlay/overlay-warningdownred9.png -composite ../status/appointment-missed.png
            convert document-open-recent.png ../overlay/overlay-appointment9.png -composite ../status/appointment-soon.png
          ;;
          audio-cd-new.png)
            convert ../devices/media-optical-audio.png $command ../devices/media-optical-audio.png
            convert ../devices/media-optical-video.png $command ../devices/media-optical-video.png
            convert ../devices/media-optical-cd.png $command ../devices/media-optical-cd.png
            
            convert ../devices/media-optical-audio.png ../overlay/overlay-add9.png -composite $i
            convert ../devices/media-optical-video.png ../overlay/overlay-add9.png -composite media-optical-video-new.png
            
            fl="media-optical-data-new.png"
            convert ../devices/media-optical-cd.png ../overlay/media-optical-data-new9.png -composite $fl
            convert $fl ../aaoverlay/media-optical-data-ne.png -composite $fl
            cp $fl continue-data-project.png
            convert $fl ../overlay/overlay-add9.png -composite $fl
          ;;
          bookmark_add.png)
            convert ../places/user-bookmarks.png $command ../places/user-bookmarks.png
            convert ../places/user-bookmarks.png ../overlay/overlay-add9.png -composite $i
            convert ../places/user-bookmarks.png ../overlay/overlay-multipleadd9.png -composite bookmarks_list-add.png
          ;;
          hwbrowser.png)
            convert hw.png $command hw.png
            convert hw.png ../overlay/eogyellow9.png -composite $i
            convert hw.png ../overlay/info9.png -composite hwinfo.png
          ;;
          xpdf.png)
            convert dia_gnome_icon.png ../overlay/dia-overlay9.png -composite dia_gnome_icon.png
            convert ../overlay/checkgmail-overlay9.png mail.png -composite checkgmail.png
            convert ../mimetypes/font-x-generic.png ../aaoverlay/fontforg.png -composite fontforge.png
            
            convert ../places/user-desktop1.png ../aaoverlay/gdm.png -composite gdm1.png
            convert ../places/user-desktop1.png ../aaoverlay/gdm-login-photo.png -composite gdm-login-photo1.png
            convert ../places/user-desktop1.png ../aaoverlay/aptdaemon-workin.png -composite ../categories/clear/preferences-desktop-personal1.png
            
            convert ../categories/applications-internet1.png ../aaoverlay/gnome-network-preferences.png -composite gnome-network-preferences1.png
            
            convert xmlcopyeditor2.png $command xmlcopyeditor2.png
            convert xmlcopyeditor2.png ../overlay/xmlcopyeditor9.png -composite xmlcopyeditor1.png
            convert ../overlay/xpdf9.png ../aaoverlay/xpd.png -composite $i
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
            convert ../places/user-bookmarks.png ../overlay/overlay-close9.png -composite $i
            rm okteta.png
            cp ../aaoverlay/multipart-encrypted.png okteta.png
          ;;
          dropboxstatus-logo.png)
            convert $i $command $i
            convert $i ../overlay/dropboxstatus-idle-overlay9.png -composite dropboxstatus-idle.png
            convert $i ../overlay/dropboxstatus-x-overlay9.png -composite dropboxstatus-x.png
          ;;
          emblem-ubuntuone-unsynchronized1.png)
            convert ../apps/ubuntuone-client-emblem.png ../overlay/overlay-close9.png -composite $i
            i="emblem-ubuntuone-synchronized1.png"
            convert ../apps/ubuntuone-client-emblem.png ../overlay/overlay-apply9.png -composite $i
            i="emblem-ubuntuone-updating1.png"
            convert ../apps/ubuntuone-client-emblem.png ../overlay/overlay-reboot9.png -composite $i
            i="../status/ubuntuone-client-error.png"
            convert ../apps/ubuntuone-client-emblem.png ../overlay/overlay-warning9.png -composite $i
            i="../status/ubuntuone-client-idle.png"
            convert $i $command $i
            i="../status/ubuntuone-client-offline.png"
            convert ../apps/ubuntuone-client-emblem.png ../overlay/ubuntuone-client-offline-overlay9.png -composite $i
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
            convert playlist.png ../overlay/overlay-add9.png -composite $i          
            convert playlist.png ../overlay/overlay-close9.png -composite media-clear-playlist-amarok.png
          ;;
          contact-new.png)
            convert ../stock/stock_person.png $command ../stock/stock_person.png
            convert ../stock/stock_person.png ../overlay/overlay-adddown9.png -composite $i
            convert ../stock/stock_person.png ../overlay/overlay-closedown9.png -composite list-remove-user.png
          ;;
          gtk-spell-check.png)
            convert ../aaoverlay/gtk-spell-check-overla.png ../overlay/gtk-spell-check-overlay9.png -composite $i
          ;;
          internet-radio-new.png)
            convert ../emblems/emblem-remote.png $command ../emblems/emblem-remote.png
            convert ../emblems/emblem-remote.png ../overlay/overlay-addleft9.png -composite $i
          ;;
          stock_new-tab.png)
            convert ../apps/application-default-icon.png $command ../apps/application-default-icon.png
            convert ../aaoverlay/stock_new-ta.png ../overlay/overlay-addwindow9.png -composite $i
            convert ../aaoverlay/stock_new-ta.png ../overlay/overlay-closetab9.png -composite tab-close.png
            convert ../aaoverlay/tab-close-othe.png ../overlay/overlay-closetab9.png -composite tab-close-other.png
            
            convert ../apps/application-default-icon.png ../overlay/overlay-addwindow9.png -composite window-new.png
            convert ../apps/application-default-icon.png ../overlay/overlay-closewindow9.png -composite ../apps/gnome-panel-force-quit.png
          ;;
          touchpad-disabled.png)
            convert touchpad-enabled.png $command touchpad-enabled.png
            convert touchpad-enabled.png ../overlay/overlay-closebm9.png -composite $i
          ;;
          stock_lock-broken.png)
            convert stock_lock-open.png $command stock_lock-open.png
            convert stock_lock-open.png ../overlay/overlay-closelock9.png -composite $i
            convert stock_lock-open.png ../overlay/overlay-applylock9.png -composite stock_lock-ok.png
          ;;
          krb-no-valid-ticket.png)
            convert krb-valid-ticket.png ../overlay/overlay-warningdownleftred9.png -composite $i
          ;;
          gpm-battery-empty.png)
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
            convert gpm-keyboard-020-overlaybis.png ../aaoverlay/gpm-keyboard-020-overlay.png -composite gpm-keyboard-020-overlaybis.png
            convert ../aaoverlay/gpm-keyboard-overlay.png ../overlay/gpm-keyboard-000-overlay9.png -composite gpm-keyboard-000.png
            convert ../aaoverlay/gpm-keyboard-overlay.png gpm-keyboard-020-overlaybis.png -composite gpm-keyboard-020.png
          ;;
          gpm-mouse-000.png)            
            convert ../aaoverlay/gpm-mouse-overlay.png ../overlay/gpm-keyboard-000-overlay9.png -composite gpm-mouse-000.png
            convert ../aaoverlay/gpm-mouse-overlay.png gpm-keyboard-020-overlaybis.png -composite gpm-mouse-020.png
          ;;
          gpm-phone-000.png)
            convert ../aaoverlay/gpm-phone-overlay.png ../overlay/gpm-keyboard-000-overlay9.png -composite gpm-phone-000.png
            convert ../aaoverlay/gpm-phone-overlay.png gpm-keyboard-020-overlaybis.png -composite gpm-phone-020.png
          ;;
          tray-away.png)
            file="tray-away.png"
            convert $file $command $file
            convert ../overlay/overlay9tray-extended-away9.png $file -composite tray-extended-away.png
            convert ../overlay/overlay-tray-offline9.png ../aaoverlay/tray-offlin.png -composite tray-offline.png
            
            convert ../overlay/overlay-user-idle9.png ../aaoverlay/user-idl.png -composite user-typing.png
          ;;
          weather-overcast.png)
            convert $i $command $i
            convert $i ../overlay/overlay-warningdownleft9.png -composite weather-severe-alert.png          
            
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
            i="../mimetypes/package-x-generic.png"
            convert $i ../overlay/aptdaemon-add9.png -composite aptdaemon-add.png
            convert $i ../aaoverlay/aptdaemon-cleanu.png -composite aptdaemon-cleanup.png
            convert $i ../overlay/aptdaemon-delete9.png -composite aptdaemon-delete.png
            convert $i ../aaoverlay/aptdaemon-resolv.png -composite aptdaemon-resolve.png
            convert ../devices/printer1.png ../aaoverlay/aptdaemon-resolv.png -composite ../actions/document-print-preview1.png
            convert ../devices/printer2.png ../overlay/overlay-close9.png     -composite ../actions/gtk-print-error2.png
            convert ../devices/printer2.png ../overlay/overlay-add9.png       -composite ../devices/gnome-dev-printer-new2.png
            convert ../devices/printer2.png ../overlay/overlay-warning9.png   -composite ../actions/gtk-print-warning2.png
            convert $i ../aaoverlay/aptdaemon-wai.png -composite aptdaemon-wait.png
            convert $i ../aaoverlay/aptdaemon-workin.png -composite aptdaemon-working.png
            convert $i ../aaoverlay/aptdaemon-downloa.png -composite ../apps/rpmdrake.png
            convert $i ../aaoverlay/aptdaemon-update-cach.png -composite ../apps/edit-urpm-sources.png
            convert $i ../aaoverlay/aptdaemon-upgrad.png -composite ../apps/mandriva-update.png
            convert $i ../aaoverlay/synapti.png -composite ../apps/synaptic.png
            convert $i ../status/nm-secure-lock.png -composite ../actions/jockey-proprietary.png
            convert $i ../aaoverlay/application-x-jar.png -composite ../mimetypes/application-x-jar.png
            convert $i ../aaoverlay/unknown-channe.png -composite ../apps/unknown-channel.png
          ;;
          stock_certificate.png)
            i="../mimetypes/application-certificate.png"
            convert $i $command $i
            i="../mimetypes/opera-unite-application.png"
            convert $i $command $i
            i="../mimetypes/x-office-calendar.png"
            cp ../aaoverlay/config-dat.png $i
          
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
            convert stock_new-template.png ../aaoverlay/font-x-generi.png -composite ../mimetypes/font-x-generic.png

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
            
            convert ../mimetypes/image.png ../aaoverlay/image_centered.png -composite ../mimetypes/image.png
            convert ../mimetypes/image-x-ico.png ../aaoverlay/image_centered.png -composite ../mimetypes/image-x-ico.png
            convert ../mimetypes/image-bmp.png ../aaoverlay/image_toptop.png -composite ../mimetypes/image-bmp.png
            convert ../mimetypes/image-gif.png ../aaoverlay/image_top.png -composite ../mimetypes/image-gif.png
            convert ../mimetypes/image-jpeg.png ../aaoverlay/image_top.png -composite ../mimetypes/image-jpeg.png
            convert ../mimetypes/image-png.png ../aaoverlay/image_toptop.png -composite ../mimetypes/image-png.png
            convert ../mimetypes/image-tiff.png ../aaoverlay/image_top.png -composite ../mimetypes/image-tiff.png
            convert ../mimetypes/image.png ../aaoverlay/image-load.png -composite ../mimetypes/image-loading.png
            convert ../mimetypes/image.png ../aaoverlay/gphot.png -composite ../apps/gphoto.png
            convert ../mimetypes/image.png ../aaoverlay/eog.png -composite ../apps/eog1.png

            cd ../
            wddname=`pwd`
            wddname=`basename $wddname`
            cd stock            
            if [ $wddname != "22x22" ]; then
	      convert ../overlay/image-missing-overlay9.png ../aaoverlay/image_centered.png -composite ../status/image-missing.png
            fi
          ;;
        esac
        if [ $i = "user-trash1-full.png" ] || [ $i = "user-trash1.png" ] || [ $i = "user-trash3-full.png" ] || [ $i = "user-trash3.png" ] || [ $i = "user-trash4-full.png" ] || [ $i = "user-trash4.png" ] || [ $i = "user-trash5-full.png" ] || [ $i = "user-trash5.png" ] || [ $i = "user-desktop1.png" ] || [ $i = "user-desktop3.png" ] || [ $i = "user-desktop5.png" ] || [ $i = "user-home1.png" ] || [ $i = "user-home3.png" ] || [ $i = "user-home5.png" ]; then
            cd ../
            bsname=`pwd`
            bsname=`basename $bsname`
            cd places/
            ln -fs ../../../../$ICNST/clear/$bsname/places/$i $i
        fi
        if [ ${i: -5} = "1.png" ] || [ ${i: -5} = "9.png" ]; then
          if [ $i != "emblem-ubuntuone-unsynchronized1.png" ] && [ $i != "emblem-ubuntuone-synchronized1.png" ] && [ $i != "emblem-ubuntuone-updating1.png" ] && [ $i != "glippy1.png" ] && [ $i != "eog1.png" ] && [ $i != "openoffice-new1.png" ] && [ $i != "xmlcopyeditor1.png" ] && [ $i != "preferences-desktop-personal1.png" ] && [ $i != "gdm1.png" ] && [ $i != "gdm-login-photo1.png" ] && [ $i != "it.vodafone.desktopwidget.75c5d0ac8e830b80bd4fbc0b32a23f0123e8c097.1.png" ] && [ $i != "gnome-logo-icon.png" ] && [ $i != "gnome-suse.png" ] && [ $i != "ubuntuone-client1.png" ] && [ $i != "openofficeorg-printeradmin-new1.png" ] && [ $i != "libreoffice3-printeradmin1.png" ] && [ $i != "document-print-preview1.png" ] && [ $i != "gnome-network-preferences1.png" ] && [ $i != "haguichi-connecting-1.png" ]; then
            bsname=`pwd`
            bsname=`basename $bsname`
            if [ $bsname != "aaoverlay" ]; then
              cd ../
              bsname2=`pwd`
              bsname2=`basename $bsname2`
              cd $bsname/
              ln -fs ../../../../$ICNST/clear/$bsname2/$bsname/$i $i
            fi
          fi
        fi
      fi
      
      if [ $i = "ubuntuone-client1.png" ] || [ $i = "it.vodafone.desktopwidget.75c5d0ac8e830b80bd4fbc0b32a23f0123e8c097.1.png" ]; then
        convert $i $command $i
      fi
      
      if [ $i = "notification-area.png" ]; then
        ln -fs taskbar.png $i
      fi
    
      if [ -d $i ]; then
        if [ $i = "s11" ] || [ $i = "sonetto" ] || [ $i = "classy" ] || [ $i = "awoken" ] || [ $i = "original" ] || [ $i = "leaf" ] || [ $i = "snowsabre" ] || [ $i = "metal" ] || [ $i = "tlag" ]; then
            cd ../
            bsname=`pwd`
            bsname=`basename $bsname`
            cd places/
            rm -rf $i
            ln -s ../../../../$ICNST/clear/$bsname/places/$i $i
        elif [ $i = "start-here" ] || [ $i = "drive-harddisk" ] || [ $i = "overlay" ] || [ $i = "animations" ]; then
          if [ $i = "start-here" ];then
            bsname=`pwd`
            bsname=`basename $bsname`
            cd $i
            for l in *;do
              if [ ${l: -5} = "1.png" ] || [ ${l: -5} = "3.png" ] || [ ${l: -5} = "5.png" ] || [ ${l: -5} = "7.png" ] || [ ${l: -5} = "9.png" ] || [ $l = "start-here-frugalware.png" ]; then
                convert $l $command $l
              else
                ln -fs ../../../../$ICNST/clear/$bsname/start-here/$l $l
              fi
              if [ $l = "start-here-umbrella3.png" ]; then
                convert $l ../overlay/start-here-umbrella9.png -composite $l
              fi
            done
            cd ../
          else
            bsname=`pwd`
            bsname=`basename $bsname`
            rm -rf $i
            ln -s ../../../$ICNST/clear/$bsname/$i $i
          fi
        fi
      fi
    done
  ;;
esac
