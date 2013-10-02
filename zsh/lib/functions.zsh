# Создать директорию и перейти в нее.
function take() {
    mkdir -p /tmp/$1
    cd /tmp/$1
}

# Перестановка.
function rot13() {
	if [ $# = 0 ] ; then
		tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]"
	else
		tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]" < $1
	fi
}

# Распаковка архива...
function upack() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1;;
            *.tar.gz)    tar xzf $1;;
            *.bz2)       bunzip2 $1;;
            *.rar)       unrar x $1;;
            *.gz)        gunzip $1;;
            *.tar)       tar xf $1;;
            *.tbz2)      tar xjf $1;;
            *.tgz)       tar xzf $1;;
            *.zip)       unzip $1;;
            *.Z)         uncompress $1;;
            *.7z)        7z x $1;;
            *.lzma)      lzma -d $1;;
            *)           echo "ERROR: '$1' unknown type." ;;
        esac
    else
        echo "ERROR: '$1' is not a valid file."
    fi
}
# ... и упаковка.
function pack() {
    if [ $1 ] ; then
        case $1 in
            tbz)    tar cjvf $2.tar.bz2 $2;;
            tgz)    tar czvf $2.tar.gz  $2;;
            tar)    tar cpvf $2.tar  $2;;
            bz2)    bzip $2;;
            gz)     gzip -c -9 -n $2 > $2.gz;;
            zip)    zip -r $2.zip $2;;
            7z)     7z a $2.7z $2;;
            lzma)   lzma -z $1;;
            *)      echo "ERROR: '$1' Cannot be packed via pack.";;
        esac
    else
        echo "ERROR: '$1' is not a valid file."
    fi
}

# Локальное зеркало сайта.
function lmirror(){
    wget -r -l inf -k -p $1
}

#
# Конвертируем всякую дурь
#

function mp32utf() { 
    find -iname '*.mp3' -print0 | xargs -0 mid3iconv -eCP1251 --remove-v1
}

function mpg2flv() { 
    ffmpeg -i $1 -ar 22050 -ab 32 -f flv -s 320x240 `echo $1 | awk -F . '{print $1}'`.flv 
}

function flv2xvid() { 
    mencoder "$1" -vf scale=320:240  -ovc xvid -xvidencopts bitrate=250:autoaspect -vf pp=lb -oac mp3lame  -lameopts fast:preset=standard -o  "./basename $1.avi" 
}

function flv2divx() {
    mencoder "$1" --vf scale=320:240  -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=250:mbd=2:v4mv:autoaspect -vf pp=lb -oac mp3lame  -lameopts fast:preset=standard -o  "./basename $1.avi" 
}

function iso2cd() {
    cdrecord -s dev=`cdrecord --devices 2>&1 | grep "\(rw\|dev=\)" | awk {'print $2'} | cut -f'2' -d'=' | head -n1` gracetime=1 driveropts=burnfree -dao -overburn -v
}

function nrg2iso() {
    dd bs=1k if=$1 of=$2 skip=300
}

function win2utf() {
    iconv -f CP1251 -t UTF-8 $1 > $1
}

function djvu2pdf() {
    ddjvu -format=pdf $1 $1.pdf
}

