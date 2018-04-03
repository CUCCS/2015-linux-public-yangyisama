#!bin/bash
input=""
DIR="bash/"
quality_pct="75"
resolution_pct="25"
text=""
prefix=""
suffix=""
isCompressQuality="0"
isCompressResize="0"
isTextWatermark="0"
isPrefix="0"
isSuffix="0"
isTransJPG="0"

if [ ! -d "$DIR" ] ; then
  echo "No such file or directory"
  exit 0
fi
OUTPUT=${DIR}/output
mkdir -p $OUTPUT
imageType=".*\(jpg\|JPG\|jpeg\|png\|PNG\|svg\|SVG\)"
imageFind="find $DIR -maxdepth 1 -regex $imageType"
iArray=$($imageFind)

function Usage{
	 echo -e "
Usage: bash Picture.sh [OPTIONS] [PARAMETER] \n
-i, --input[=DIRECTORY]         choose the specified DIRECTORY\n
-q, --quality[=QUALITY]         for jpeg format images to image quality compression\n
-s, --resize[=SIZE]             for jpeg/png/svg images to maintain the original aspect ratio under the premise of compression resolution\n
-w, --watermark[=TEXT]          add custom TEXT watermarks to images\n
-e, --prefix[=PREFIX]           add the PREFIX to rename the images\n
-o, --suffix[=SUFFIX]           add the SUFFIX to rename the images\n
-t, --changetype                change the png/svg format images to jpeg format images\n
--help   
	 "
}
function compressQuality{
	if [ -f "$1" ]; then 
		$(convert "$1" -quality "$2"% "$OUTPUT")
		echo " Compress "$1" into "$OUTPUT"."
	else
		echo "No such a file "$1" exist."  
	fi
}
function compressResize{
    if [ -f "$1" ]; then 
        $(convert "$1" -resize "$2"% "$OUTPUT")
        echo " Compress "$1" into "$OUTPUT"."  
    else
        echo "No such a file "$1" exist."
    fi
}
function addWatermark{
    if [ -f "$1" ]; then
        $(convert "$1" -draw "gravity east fill black  text 0,12 "$2" " "$OUTPUT") 
        echo "add the watermark into "$OUTPUT" sucessfully"
    else 
        echo "No such a file "$1" exist."
    fi
}
function transFormat
{
    if [ -f "$1" ]; then 
    	iName="${$1%%.*}.jpg"
        $(convert "$1" "$OUTPUT/$iName")
        echo "Transfer "$1" into "$OUTPUT/$iName""
    else
        echo "No such a file "$1" exist."
    fi
}
function addPrefix
{
    for img in $iArray ;do
    	iName_base=$(basename "$img")
    	iName="${1}${iName}"
    	$(convert "$iName_base" "$OUTPUT/$iName")
    done
    echo "Done."
}
function addSuffix
{
    for img in $iArray ;do
    	iName_base=$(basename "$img")
    	iName=${iName_base%%.*}${1}"."${iName_base#*.}
    	$(convert "$iName_base" "$OUTPUT/$iName")
    done
    echo "Done."
}

if [[ "$#" -lt 1 ]]; then
	echo "no primary parameters!";
        exit 1;
else
	while true ; do
		case "$1" in	
	    -i|--input)     case "$2" in
						  "") echo "Parameter is needed" ; break ;;
						   *)  input=$2; shift 2 ;;
					    esac ;;
		-q|--quality)   quality_pct=$2 ; isCompressQuality="1" ; shift 2 ;;
		-s|--resize)    resolution_pct=$2 ; isCompressResize="1" ; shift 2 ;;
		-w|--watermark) text=$2 ; isTextWatermark="1"  ; shift 2 ;;       
		-p|--prefix)    case $2 in 
 						  "") echo "Parameter is needed" ; break ;;
			               *) isPrefix="1" ; prefix=$2 ; shift 2 ;;
        -s|--suffix)    case $2 in 
 						  "") echo "Parameter is needed" ; break ;;
			               *) isSuffix="1" ; suffix=$2 ; shift 2 ;;  
		-t|--transfer) 	isTransFormat="1"; shift ;;
		-h|--help)	    Usage exit;;
		--) shift ; break ;;
		 *) echo "Internal error!" ; exit 1 ;;
        esac
    done

if [ "$isCompressQuality" == "1" ] ; then
	compressQuality $input $quality_pct
fi

if [ "$isCompressResize" == "1" ] ; then
        compressResize $input $resolution_pct
fi

if [ "$isTransJPG" == "1" ] ; then
        transFormat $input
fi

if [ "$isTextWatermark" == "1" ] ; then
        addTextWatermark $input $text
fi

if [ "$isPrefix" == "1"  ] ; then
        addPrefix $prefix
fi

if [ "$isSuffix" == "1" ] ; then
        addSuffix $suffix
fi

