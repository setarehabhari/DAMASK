#!/bin/bash

DEFAULT_VERSION='2013.1'

WORKINGDIR="$( cd "$( dirname "$0" )" && pwd )"

source $WORKINGDIR/../options

while [ ! -d "$WORKINGDIR/$VERSION" ] || [ -z "$VERSION" ]
do
  echo "Input version of MARC/MENTAT installation: [${DEFAULT_VERSION}]"
  read VERSION
  if [ -z "$VERSION" ]; then
    VERSION=${DEFAULT_VERSION}
  fi
done
echo "MSC version: $VERSION"

if [ "x$MSC_ROOT" != "x" ]; then
 INSTALLDIR=$MSC_ROOT
fi

while [ ! -d "$INSTALLDIR" ] || [ -z "$INSTALLDIR" ]
do
  echo "Input path of MARC/MENTAT installation:"
  read INSTALLDIR
done

INSTALLDIR=${INSTALLDIR%/}               # remove trailing slash
echo "MSC installation path: $INSTALLDIR"

BLASDIR=''
BLASTYPE=''
if [ "x$LAPACK_ROOT" != "x" ]; then
  BLASDIR=$LAPACK_ROOT
  BLASTYPE='LAPACK'
fi
if [ "x$ACML_ROOT" != "x" ]; then
  BLASDIR=$ACML_ROOT
  BLASTYPE='ACML'
fi
if [ "x$IMKL_ROOT" != "x" ]; then
  BLASDIR=$IMKL_ROOT
  BLASTYPE='IMKL'
fi

while [ ! -d "$BLASDIR" ] || [ -z "$BLASDIR" ]
do
  echo "Input type of BLAS installation [IMKL | ACML | LAPACK]:"
  read BLASTYPE
  echo "Input path of BLAS installation:"
  read BLASDIR
done

BLASDIR=${BLASDIR%/}               # remove trailing slash

case $BLASTYPE in
    IMKL | imkl) 
    BLAS=" -mkl"
    ;;
    ACML | acml) 
    BLAS=" -L$BLASDIR/ifort64_mp/lib -lacml_mp"
    ;;
    LAPACK | lapack) 
    BLAS=" -L$BLASDIR/lib64 -L$BLASDIR/lib -llapack"
    ;;
    *)
    echo "error, BLAS type must be IMKL, ACML, or LAPACK"
    exit
    ;;
esac

DEFAULT_EDITOR='vi'
EDITOR=''
while [ -z "$EDITOR" ]
do
  echo "Input command to invoke your preferred editor: [${DEFAULT_EDITOR}]"
  read EDITOR
  if [ -z "$EDITOR" ]; then
    EDITOR=${DEFAULT_EDITOR}
  fi
done
echo "Editor: $EDITOR"

# tools
echo ''
echo 'copying Marc tools...'
theDIR=$INSTALLDIR/marc$VERSION/tools
for filename in 'comp_damask' \
                'comp_damask_l' \
                'comp_damask_h' \
                'comp_damask_mp' \
                'comp_damask_lmp' \
                'comp_damask_hmp' \
                'run_damask' \
                'run_damask_l' \
                'run_damask_h' \
                'run_damask_mp' \
                'run_damask_lmp' \
                'run_damask_hmp' \
                'include_linux64'; do
  cp $WORKINGDIR/$VERSION/Marc_tools/$filename $theDIR
  echo $theDIR/$filename | xargs perl -pi -e "s:%INSTALLDIR%:${INSTALLDIR}:g"
  echo $theDIR/$filename | xargs perl -pi -e "s:%VERSION%:${VERSION}:g"
  echo $theDIR/$filename | xargs perl -pi -e "s:%BLAS%:${BLAS}:g"
  echo $filename
done

# Mentat scripts
echo ''
echo 'copying Mentat scripts...'
theDIR=$INSTALLDIR/mentat$VERSION/bin
for filename in 'edit_window' \
                'submit4' \
                'submit5' \
                'submit6' \
                'submit7' \
                'submit8' \
                'submit9' \
                'kill4' \
                'kill5' \
                'kill6' \
                'kill7' \
                'kill8' \
                'kill9'; do
  cp $WORKINGDIR/$VERSION/Mentat_bin/$filename $theDIR
  echo $theDIR/$filename | xargs perl -pi -e "s:%INSTALLDIR%:${INSTALLDIR}:g"
  echo $theDIR/$filename | xargs perl -pi -e "s:%VERSION%:${VERSION}:g"
  echo $theDIR/$filename | xargs perl -pi -e "s:%EDITOR%:${EDITOR}:g"
  echo $filename
done

# Mentat scripts
echo ''
echo 'copying Mentat menus...'
theDIR=$INSTALLDIR/mentat$VERSION/menus
for filename in 'job_run.ms'; do
  cp $WORKINGDIR/$VERSION/Mentat_menus/$filename $theDIR
  echo $theDIR/$filename | xargs perl -pi -e "s:%INSTALLDIR%:${INSTALLDIR}:g"
  echo $theDIR/$filename | xargs perl -pi -e "s:%VERSION%:${VERSION}:g"
  echo $filename
done

# compile menus
echo ''
echo 'compiling menus...'
$INSTALLDIR/mentat$VERSION/bin/mentat -compile $INSTALLDIR/mentat$VERSION/menus/linux64/main.msb

# setting access rights
echo ''
echo 'setting file access rights...'
chmod 555 $INSTALLDIR/marc$VERSION/tools/run_damask*
chmod 555 $INSTALLDIR/marc$VERSION/tools/comp_damask*
chmod 555 $INSTALLDIR/mentat$VERSION/bin/submit{4..9}
chmod 555 $INSTALLDIR/mentat$VERSION/bin/kill{4..9}

#creating symlinks for run_damask_scripts in /usr/local/bin
BIN_DIR=/usr/local/bin
echo ''
echo "Do you want to create symlinks for run_damask scripts in ${BIN_DIR} [YES/no] ?"
read YESNO
  if [ -z "$YESNO" ]; then
    YESNO=yes
  fi
case $YESNO in
 y* | Y* )
  echo''
  echo 'creating symlinks ...'
  echo''
  theDIR=$INSTALLDIR/marc$VERSION/tools
  for filename in 'run_damask' \
                  'run_damask_l' \
                  'run_damask_h' \
                  'run_damask_mp' \
                  'run_damask_lmp' \
                  'run_damask_hmp'; do
    echo ${filename:4}$VERSION
    ln -s $theDIR/$filename $BIN_DIR/${filename:4}$VERSION 
  done
  ;;
esac

echo ''
echo 'done.'
