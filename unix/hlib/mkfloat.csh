#! /bin/csh
# THIS IS A SUN/IRAF SYSTEM MANAGEMENT UTILITY.
# -------------------------------------------------
# MKFLOAT.CSH -- Install the indicated version of the IRAF binaries, i.e.,
# archive the current objects and libraries, set BIN to point to bin.FFF,
# and set mkpkg to produce FFF binaries (FFF = f68881, ffpa, sparc, etc.).
#
# NOTE -- This script should be run only by the IRAF system manager.  It is
# assumed that the environment variables defined in the IRAF .login and in
# hlib/irafuser.csh are defined.

set ARCH = "$1"
set DIRS = "lib pkg sys"
set FILE = unix/hlib/mkpkg.inc
set DFL  = _DFL.mkfloat
set TFL  = _TFL.mkfloat

# set echo

set float = `ls -l bin | sed -e 's+^.*bin\.++'`
if ("$ARCH" == "") then
    echo "system is configured for $float"
    exit 0
else if ($float == "$ARCH") then
    echo "system is already configured for $ARCH"
    exit 0
else if (! -e bin.$ARCH) then
    echo "must set up a bin.$ARCH subdirectory first"
    exit 1
endif

# Get the list of directories to be changed.
shift
if ("$1" == "-d") then
    set DIRS = ""
    shift
    while ("$1" != "")
	set DIRS = "$DIRS $1"
	shift
    end
endif

echo "delete any dreg .e files left lying about in the source directories"
rmbin -n -o .a .o .e $DIRS > $TFL;  grep '\.e$' $TFL | tee > _.e_files
rm -f `cat _.e_files` _.e_files;  grep -v '\.e$' $TFL > $DFL;  rm $TFL

echo "archive and delete $float objects"
if (-e bin.$float) then
    tar -cf bin.$float/OBJS.arc `cat $DFL`
    tar -tf bin.$float/OBJS.arc > $TFL
    cmp -s $DFL $TFL
    if ($status) then
	echo "Error: cannot archive $float objects"
	diff $DFL $TFL
	rm $DFL $TFL bin.$float/OBJS.arc
	exit 1
    else
	rm -f $TFL
    endif
else
    echo "old objects will not be archived as no bin.$float directory found"
endif
rm -f `cat $DFL` $DFL

echo "restore archived $ARCH objects"
if (-e bin.$ARCH/OBJS.arc) then
    tar -xpf bin.$ARCH/OBJS.arc
    if ($status == 0) then
	rm -f bin.$ARCH/OBJS.arc
    endif
else
    echo "no object archive found; full sysgen will be needed"
endif

# Set BIN to point to new directory.
rm -f bin; ln -s bin.$ARCH bin

# If script is run at IRAF root, edit mkpkg.inc for new float option.
#if (-e $FILE) then
#    sed -e "s+= $float+= $ARCH+" $FILE > temp; mv -f temp $FILE
#endif

# Warn the user if the new ARCH does not match their current IRAFARCH.
if ($?IRAFARCH == 1) then
    if ($ARCH != $IRAFARCH) then
	echo "Warning: IRAFARCH is still set in your environment to $IRAFARCH"
    endif
endif