#!/bin/bash
old_tty_settings=$(stty -g)
stty -icanon
Keypress=$(head -c1)
echo "Key pressed was\""$Keypress"\"."
stty "$old_tty_settings"
exit 0
