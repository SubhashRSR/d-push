#!/bin/sh

encoder=""
fullEncoder="Current v14.0"
language=""
selectedArch=""
sysArch=""
encoderOptions=""
encoderPath=""
warning=""
isFreeBSD="" # Whether the script is running on FreeBSD which does not have any 64-bit encoders.
currentV="14.0"
legacyV="13.0"
obsoleteV="12.0"

# Encoder-Arch-Language


encodersForV14="C-64-5.3 C-64-5.4 C-64-5.5 C-64-5.6 C-64-7.1 C-64-7.2 C-64-7.4 C-64-8.1 C-64-8.2 C-64-8.3
               C-32-4 C-32-5 C-32-5.3 C-32-5.4 C-32-5.5 C-32-5.6 C-32-7.1 C-32-7.2 C-32-7.4 C-32-8.1 C-32-8.2 C-32-8.3
               L-32-4 L-32-5 L-32-5.3 L-32-5.4 L-32-5.5 L-32-5.6 L-32-7.1 L-32-7.2 L-32-7.4 L-32-8.1 L-32-8.2
               L-64-5.3 L-64-5.4 L-64-5.5 L-64-5.6 L-64-7.1 L-64-7.2 L-64-7.4 L-64-8.1 L-64-8.2
               O-32-4 O-32-5 O-32-5.3 O-32-5.4 O-32-5.5 O-32-5.6 O-32-7.1 O-32-7.2 O-32-7.4 O-32-8.1
               O-64-5.3 O-64-5.4 O-64-5.5 O-64-5.6 O-64-7.1 O-64-7.2 O-64-7.4 O-64-8.1"

fail()  {
    echo $*
    exit 1
}

checkSelectionCompatibility() {
    
    var="$encoder-$selectedArch-$language"

    for validEncoder in $encodersForV14; do
        [ "$validEncoder" = "$var" ] && echo "valid" && return
    done

    echo "invalid"
}

checkSystemCompatibility() {
    
    # check for 64-bit Encoder running on FreeBSD which does not have any 64-bit encoders.
    [ "$selectedArch" = "64" ] && [ "$isFreeBSD" = 1 ] && fail "64-bit Encoders do not exist for FreeBSD. Please use the 32-bit Encoder." 

    # check for 64-bit Encoder running on a 32-bit system.
    [ "$selectedArch" = "64" ] && [ "$sysArch" = "32" ] && fail "The 64-bit Encoder cannot be run on a 32-bit system." 

    # check for 32-bit Encoder running on a 64-bit system.
    [ "$selectedArch" = "32" ] && [ "$sysArch" = "64" ] && warning="Warning: you are running the 32-bit Encoder on a 64-bit system."
}

setEncoder() {
        if [ "$encoder" = "" ] ; then
            encoder="$1"
        [ "$1" = "C" ] && fullEncoder="Current v14.0"
        [ "$1" = "L" ] && fullEncoder="Legacy v13.0"
        [ "$1" = "O" ] && fullEncoder="Obsolete v12.0"
    else
        fail "You cannot set more than one Encoder version."
    fi
}               

setLanguage() {

    if [ "$language" = "" ] ; then 
        language="$1"
    else
        fail "You cannot set more than one Encoding language."
    fi
}

setArch() {

    if [ "$selectedArch" = "" ] ; then
        selectedArch="$1"
    else 
        fail "You cannot set more than one architecture type"
    fi
}

setSysArch() {

    localArch=`uname -m`
    isFreeBSD=`uname -s | grep -ic "FreeBSD"`
    sysArch="32"

    if [ "$isFreeBSD" = "1" ]
    then
        # FreeBSD currently only has 32-bit Encoders
        sysArch="32"
    else 

        case "$localArch" in 
            "i686" | "i386")
                sysArch="32"
                ;;

            "x86_64" | "amd64")
                sysArch="64"
                ;;
        esac
    fi
}

checkLanguage() {
    if [ "$language" = "" ] ; then
        echo notSet 
    else
        echo set
    fi
}


printArchHelp() {
    arch=$1
    if [ $arch -eq "32" ] ; then
        archOptions="-x86"
        optionsDesc="Run the 32-bit Encoder"
        arch32T=""
        arch64T=""
        arch32O=""
        arch64O=""
    else
        archOptions="-x86 | -x86-64"
        optionsDesc="Run either the 32-bit or 64-bit Encoder"
        arch32_T="32-bit "
        arch64_T="64-bit "
        arch32_O="-x86 "
        arch64_O="-x86-64 "
    fi

    echo "
The following is a summary of command options for this script and its basic usage. 

Usage: ioncube_encoder.sh [-C | -L | -O] [-4 | -5 | -53 | -54 | -55 | -56 | -71 | -72 | -74 | -81 | -82 | -83] [$archOptions] <encoder options>

Encoder Version (optional):
-C : Use Current Encoder (v14.0) - Default
-L : Use Legacy Encoder (v13.0)
-O : Use Obsolete Encoder (v12.0)

PHP Languages:
-4 : Encode file as PHP 4
-5 : Encode file as PHP 5
-53 : Encode file as PHP 5.3
-54 : Encode file as PHP 5.4
-55 : Encode file as PHP 5.5
-56 : Encode file as PHP 5.6
-71 : Encode file as PHP 7.1
-72 : Encode file as PHP 7.2
-74 : Encode file as PHP 7.4
-81 : Encode file as PHP 8.1
-82 : Encode file as PHP 8.2
-83 : Encode file as PHP 8.3

Architecture (optional):
$archOptions : $optionsDesc

-h : Display this help and exit. 
If -h is specified before a language has been specified, help will be displayed by this script.
if -h is specified after a language has been specified, help will be displayed by the Encoder.

If an Encoder version is not specified, the Current Encoder (14.0) will be used.
If a PHP language is not specified, the script will exit.
If an architecture is not specified, the script will run the Encoder that matches your system architecture.

The first unknown option and any further options are passed to the Encoder.
More than one Encoder version, PHP language or Architecture cannot be specified at the same time.

Usage examples:

Encode source_file.php using the Current ${arch64_T}Encoder for PHP 8.3
  ./ioncube_encoder.sh -C ${arch64_O}-83 source_file.php -o target_file.php

Display help from the Current ${arch64_T}Encoder for PHP 7.4
  ./ioncube_encoder.sh -C ${arch64_O}-74 -h

Use the Legacy ${arch32_T}Encoder for PHP 8.2
  ./ioncube_encoder.sh -L ${arch32_O}-82
"

    exit
}

printHelp() {
    printArchHelp "$sysArch"
}

setEncoderFilePath() {
    # Change so that all executables go in a bin directory but are suffixed with version number and, if 64 bit, "_64".

    encoderPath=`cd \`dirname $0\` ; pwd`/bin/

    case "$language" in 
        4)
            encoderPath="$encoderPath""ioncube_encoder4"
            ;;

        5)
            encoderPath="$encoderPath""ioncube_encoder5"
            ;;

        5.3)
            encoderPath="$encoderPath""ioncube_encoder53"
            ;;

        5.4)
            encoderPath="$encoderPath""ioncube_encoder54"
            ;;

        5.5)
            encoderPath="$encoderPath""ioncube_encoder55"
            ;;

        5.6)
            encoderPath="$encoderPath""ioncube_encoder56"
            ;;

        7.1)
            encoderPath="$encoderPath""ioncube_encoder71"
            ;;

        7.2)
            encoderPath="$encoderPath""ioncube_encoder72"
            ;;

        7.4)
            encoderPath="$encoderPath""ioncube_encoder74"
            ;;

        8.1)
            encoderPath="$encoderPath""ioncube_encoder81"
            ;;

        8.2)
            encoderPath="$encoderPath""ioncube_encoder82"
            ;;

        8.3)
            encoderPath="$encoderPath""ioncube_encoder83"
            ;;
    esac

    case "$encoder" in 
        C)
            encoderPath="$encoderPath""_""$currentV"
            ;;

        L)
            encoderPath="$encoderPath""_""$legacyV"
            ;;

        O)
            encoderPath="$encoderPath""_""$obsoleteV"
            ;;
    esac


    # Now just suffix 64-bit with "_64".
    case "$selectedArch" in
        32)
            encoderPath="$encoderPath"
            ;;
        64)
            encoderPath="$encoderPath""_64"
            ;;
    esac
}

checkEncoderExists() {
    
    if [ -f $encoderPath ] ; then
        if [ -x $encoderPath ] ; then
            true
        else 
            fail "The Encoder is not executable."
        fi
    else 
        fail "The Encoder does not exist at the path: $encoderPath"
    fi
}

setSysArch

if [ $# -eq 0 ] ; then
    printHelp
fi

for var in "$@" 
do
    case "$var" in
        -L)
            setEncoder "L"
            ;;

        -O)     
            setEncoder "O"
            ;;

        -C)
            setEncoder "C"
            ;;

        -4)
            setLanguage "4"
            ;;

        -5)
            setLanguage "5"
            ;;

        -53)
            setLanguage "5.3"
            ;;

        -54)
            setLanguage "5.4"
            ;;

        -55) 
            setLanguage "5.5"
            ;;

        -56) 
            setLanguage "5.6"
            ;;

        -71) 
            setLanguage "7.1"
            ;;

        -72) 
            setLanguage "7.2"
            ;;

        -74) 
            setLanguage "7.4"
            ;;

        -81) 
            setLanguage "8.1"
            ;;

        -82)
            setLanguage "8.2"
            ;;

        -83)
            setLanguage "8.3"
            ;;

        -8?)
	    fail "The specified variant of the PHP 8 language is not supported with this version of the ionCube Encoder."
	    ;;

        -9?)
	    fail "As of the release of ionCube Encoder ${currentV}, PHP 9 does not exist."
	    ;;


        -x86)
            setArch "32"
            ;;

        -x86-64)
            setArch "64"
            ;;

        -h)
            if [ "$language" ] ; then
                break
            else 
                printHelp
            fi;
            ;;
        
        *)
            break;
            ;;
            
    esac
    shift
done

[ "$language" = "" ] && setLanguage "8.3"
[ "$encoder" = "" ] && encoder="C" 
[ "$selectedArch" = "" ] && selectedArch="$sysArch"


selection="$(checkSelectionCompatibility)"

if [ "$selection" = "valid" ] ; then 
    true 
elif [ "$selection" = "invalid" ] ; then
    fail "The PHP ${language} language you have specified is not supported by the ${selectedArch}-bit ${fullEncoder} Encoder. Use -h for help."
fi

checkSystemCompatibility

setEncoderFilePath

checkEncoderExists

[ "$warning" != "" ] && echo "$warning"

exec $encoderPath "$@"
