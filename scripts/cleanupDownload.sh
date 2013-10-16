#!/opt/bin/bash
# @todo: Don't delete parent dir if Dir == Root
# @todo: Root = $1 - But what about series!

set +x
export PATH="/opt/bin:/opt/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/syno/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/syno/bin:/usr/syno/sbin:/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/syno/bin:/usr/syno/sbin:/usr/local/bin:/usr/local/sbin"

# Locking
LockFile="/volume1/downloads/nas_is_unpacking.lock"
if [ -f "${LockFile}" ]; then
  echo "Lockfile still exists: ${LockFile}. Aborting"
  exit 0
fi
trap "{ rm -f ${LockFile} ; exit 255; }" EXIT
date > ${LockFile}

echo "Running ${0} on $(date)"

Root="/volume1/downloads"
Home="$(pwd)"
Purged=""

# Downloadstation
echo "Looking for downloadstation tasks..."
Prevdir=""
find ${Root}/_queue -mmin +5 -iname '*.nzb' -o -iname '*.torrent' |sort | while read File; do
  Dir="$(dirname "$File")"
  if [ "${Prevdir}" != "${Dir}" ]; then
      cd "${Dir}"
      echo ""
      echo "= $(pwd)"
      echo "================================================================================================"
  fi
  # Process the first par file in this directory thanks to |sort
  /opt/bin/downloadstation add "${File}"
  if [ $? -eq 0 ]; then
      echo "Successfully added ${File}; purging file"
      rm -f "${File}"
  else
      echo "Unable to add ${File}"
  fi  
  Prevdir=$Dir
done
cd "${Home}"

# PAR
echo "Looking for files to repair..."
Prevdir=""
find ${Root} -mmin +5 -iname '*.par2' |sort | while read File; do
  Dir="$(dirname "$File")"
  if [ "${Prevdir}" != "${Dir}" ]; then
      cd "${Dir}"
      echo ""
      echo "= $(pwd)"
      echo "================================================================================================"
      # Process the first par file in this directory thanks to |sort
      par2 r "${File}"
      if [ $? -eq 0 ]; then
          echo "Successfully repaired; purging par files"
          rm -f *.par2
          rm -f *.PAR2
      else
          echo "Unable to repair; purging entire directory"
          Purged="${Purged}${Dir}\n"
          cd ..
          rm -rf "${Dir}"
      fi
  fi
  Prevdir=$Dir
done
cd "${Home}"

# RAR
echo "Looking for rar files to unpack..."
Prevdir=""
find ${Root} -mmin +5 -iname '*.rar' |sort | while read File; do
  Dir="$(dirname "$File")"
  if [ "${Prevdir}" != "${Dir}" ]; then
      cd "${Dir}"
      echo ""
      echo "= $(pwd)"
      echo "================================================================================================"
      # Process the first rar file in this directory thanks to |sort
      unrar e -y -o+ -p- "${File}"
      if [ $? -eq 0 ]; then
          echo "Successfully unpacked; purging rar files"
          rm -f *.rar
          rm -f *.r[0-9][0-9]
          rm -f *.s[0-9][0-9]
          rm -f *.t[0-9][0-9]
      else
          echo "Unable to unpack; purging entire directory"
          Purged="${Purged}${Dir}\n"
          cd ..
          rm -rf "${Dir}"
      fi
  fi
  Prevdir=$Dir
done
cd "${Home}"

# 7zip
echo "Looking for 7zip files to unpack..."
Prevdir=""
find ${Root} -mmin +5 -iname '*.7z.001' |sort | while read File; do
  Dir="$(dirname "$File")"
  if [ "${Prevdir}" != "${Dir}" ]; then
      cd "${Dir}"
      echo ""
      echo "= $(pwd)"
      echo "================================================================================================"
      # Process the first 7zip file in this directory thanks to |sort
      7z x "${File}"
      if [ $? -eq 0 ]; then
          echo "Successfully unpacked; purging rar files"
          rm -f *.7z.[0-9][0-9][0-9]
      else
          echo "Unable to unpack; purging entire directory"
          Purged="${Purged}${Dir}\n"
          cd ..
          rm -rf "${Dir}"
      fi
  fi
  Prevdir=$Dir
done
cd "${Home}"

# Move 1 Dir up & rename to parent dir
echo "Looking for files to clean..."
Prevdir=""
find ${Root} -mmin +5 -iname '*.mkv' -o -iname '*.avi' |sort | while read File; do
  Dir="$(dirname "$File")"
  Parent="$(dirname "$Dir")"
  if [ "${Prevdir}" != "${Dir}" ]; then
      cd "${Dir}"
      echo ""
      echo "= $(pwd)"
      echo "================================================================================================"
      rm -f *.1 2> /dev/null
      rm -f *.2 2> /dev/null
      rm -f *.nzb 2> /dev/null
      rm -f *.nfo 2> /dev/null
      rm -f *.par2_hellanzb_dupe0 2> /dev/null
      rm -f *.sfv 2> /dev/null
      rm -f *.srr 2> /dev/null
      rm -f *.segment000[0-9] 2> /dev/null
      # in the middle
      rm -f *[.-][Ss][Aa][Mm][Pp][Ll][Ee][.-]*.{mkv,avi,mpg,srs} 2> /dev/null
      # at the end
      rm -f *[.-][Ss][Aa][Mm][Pp][Ll][Ee].{mkv,avi,mpg,srs} 2> /dev/null
      # at the beginning
      rm -f [Ss][Aa][Mm][Pp][Ll][Ee][.-]*.{mkv,avi,mpg,srs} 2> /dev/null
      # complete
      rm -f [Ss][Aa][Mm][Pp][Ll][Ee].{mkv,avi,mpg,srs} 2> /dev/null

      # Synology media thumbs
      rm -rf @eaDir
  fi
  Prevdir=$Dir
done
cd "${Home}"

# Move lonely files 1 dir up & rename to parent dir
echo "Looking for lonely files to promote 1 directory up..."
Prevdir=""
find ${Root} -mmin +5 -iname '*.mkv' -o -iname '*.avi' -o -iname '*.ts' |sort | while read File; do
  Dir="$(dirname "$File")"
  Parent="$(dirname "$Dir")"
  if [ "${Prevdir}" != "${Dir}" ]; then
      cd "${Dir}"

      if [ "$(ls -l |grep -v 'total ' |wc -l)" = "1" ]; then
          Basedir="$(basename "${Dir}")"
          Newname="$(echo "${Basedir}")"
          Ext=${File##*.}
          Newname="${Newname}.${Ext}"

          #cmd="mv \"${File}\" \"${Parent}/${Newname}\" && rmdir \"${Dir}\""
          mv "${File}" "${Parent}/${Newname}" && rmdir "${Dir}"
          echo "promoted: ${Parent}/${Newname}"
      fi
  fi
  Prevdir=$Dir
done
cd "${Home}"

## TV Episodes
# Please use FileBot instead. Much better results.
#if [ "${1}" = "tvnamer" ]; then
# echo "Looking for tv episodes to rename..."
# tvnamer -r --batch /volume1/video/series
#fi

# REPORT
if [ -n "${Purged}" ]; then
  echo ""
  echo "Had to purge these directories cause they were damaged beyond repair:"
  echo -e "${Purged}"
fi

echo "Done"
