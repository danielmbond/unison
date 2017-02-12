#!/bin/bash
apt-get -y install unison

tee ~/sync.sh <<-'EOF'
if mkdir /var/lock/unison; then
  echo "Locking succeeded" >&2
else
  echo "Lock failed - exit" >&2
  exit 1
fi

#echo "Sync /media/USBHDD1/Backup/ and /media/USBHDD2/Backup/"
unison backup
#echo "Sync /media/USBHDD1/Kids/ /media/USBHDD2/Kids/"
unison kids
#echo "Sync /media/USBHDD1/Movies/ /media/USBHDD2/Movies/"
unison movies

rmdir /var/lock/unison
EOF

mkdir -p ~/.unison
FILENAMES=(
  'backup.prf'
  'kids.prf'
  'movies.prf'
)

count=0

while [ "x${FILENAMES[count]}" != "x" ]
do
case $count in
  0)
  root_one="/media/USBHDD1/Backup/"
  root_two="/media/USBHDD2/Backup/"
  ;;
  1)
  root_one="/media/USBHDD1/Kids/"
  root_two="/media/USBHDD2/Kids/"
  ;;
  2)
  root_one="/media/USBHDD1/Movies/"
  root_two="/media/USBHDD2/Movies/"
  ;;
  *)
  ;;
esac

tee ~/.unison/${FILENAMES[count]} <<-'EOF'
#directories to sync
root=root_one
root=root_two
#automatically accept default (nonconflicting) actions
auto=true
#batch mode: ask no questions at all
batch=true
#ask about whole-replica (or path) deletes (default true)
confirmbigdel=true
#do fast update detection (true/false/default)
fastcheck=true
#synchronize group attributes
group=true
#log
logfile=/tmp/unison.log
#synchronize owner
owner=true
#Including the preference -prefer root causes Unison always to
#resolve conflicts in favor of root, rather than asking for
#guidance from the user. (The syntax of root is the same as for
#the root preference, plus the special values newer and older.)
#This preference is overridden by the preferpartial preference.
#This preference should be used only if you are sure you know
#what you are doing!
prefer=newer
#When this preference is set to true, the user interface will not print status messages
terse=true
#Including the preference -ignore pathspec causes Unison to
#completely ignore paths that match pathspec (as well as their children).
ignore=Path .snapshot
ignore=Path lost+found
#Including the preference -mountpoint PATH causes Unison to
#double-check, at the end of update detection, that PATH exists
#and abort if it does not. This is useful when Unison is used
#to synchronize removable media. This preference can be given
#more than once. See the Mount Points section.
EOF

  sed -i "s|root_one|${root_one}|g" ${FILENAMES[count]}
  sed -i "s|root_two|${root_two}|g" ${FILENAMES[count]}
  count=$(( $count + 1 ))
done

head -3 ~/.unison/*.prf
