#========================================#
# GAMING乛Mode
# Developer : @AkiraSuper
#========================================#
#!/system/bin/sh
MODDIR=${0%/*}

sleep 50
# Removed Log
if [ -e /storage/emulated/0/gaming.log ]; then
rm /storage/emulated/0/gaming.log
fi
sleep 5
# init.d enabler
if [ "$1" == "-ls" ]; then LS=true; else LS=false; fi

for i in $MODDIR/system/bin/*; do
  case $i in
    *-ls|*-ls.sh) $LS && if [ -f "$i" -a -x "$i" ]; then $i & fi;;
    *) $LS || if [ -f "$i" -a -x "$i" ]; then $i & fi;;
  esac
done

