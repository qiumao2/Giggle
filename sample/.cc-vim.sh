#!/bin/bash
set -x
# this shell start dir, normally original path
startDir=`pwd`
# main work directory, usually ~/myGit
mainWd=$startDir

# VIM install
# common install dir for home | root mode
homeInstDir=~/.usr
rootInstDir=/usr/local
# default is home mode
commInstdir=$homeInstDir
execPrefix=""
# VIM install

logo() {
    cat << "_EOF"
__     _____ __  __
\ \   / /_ _|  \/  |
 \ \ / / | || |\/| |
  \ V /  | || |  | |
   \_/  |___|_|  |_|

_EOF
}

usage() {
    exeName=${0##*/}
    cat << _EOF
[NAME]
    $exeName -- setup newly Vim and compile YCM (optional)

[SYNOPSIS]
    $exeName [home | root | help]

[DESCRIPTION]
    home -- install to $homeInstDir/
    root -- install to $rootInstDir/

_EOF
    set +x
	logo
}

installVim() {
    cat << "_EOF"
------------------------------------------------------
STEP : INSTALLING VIM ...
------------------------------------------------------
_EOF
    vimInstDir=$commInstdir
    $execPrefix mkdir -p $commInstdir
    # comm attribute to get source 'vim'
    vimClonePath=https://github.com/vim/vim
    clonedName=vim
    checkoutVersion=v8.0.1428

    # rename download package
    cd $startDir
    # check if already has this tar ball.
    if [[ -d $clonedName ]]; then
        echo [Warning]: target $clonedName/ already exists, Omitting now ...
    else
        git clone ${vimClonePath} $clonedName
        # check if git clone returns successfully
        if [[ $? != 0 ]]; then
            echo [Error]: git clone returns error, quitting now ...
            exit
        fi
    fi

    cd $clonedName
    # if need checkout
    git checkout $checkoutVersion
	# clean before ./configure
	make distclean
	# python2Config=`python2-config --configdir`
	# python3Config='/usr/lib/python3.4/config-3.4m-x86_64-linux-gnu/'
	./configure --prefix=$vimInstDir \
			--with-features=huge \
            --enable-multibyte \
            --enable-rubyinterp=yes \
            --enable-pythoninterp=yes \
            --enable-python3interp=yes \
            --enable-perlinterp=yes \
            --enable-luainterp=yes \
    		--enable-gui=gtk2 \
			--enable-cscope
    # ./configure --prefix=$vimInstDir --enable-pythoninterp=yes --enable-python3interp=yes
    make -j
    # check if make returns successfully
    if [[ $? != 0 ]]; then
        echo [Error]: make returns error, quitting now ...
        exit
    fi

    $execPrefix make install

    cat << "_EOF"
------------------------------------------------------
Installing Git Completion Bash To Home ...
------------------------------------------------------
_EOF
    cd $startDir
    retVal=$vimInstDir

    cat << _EOF
------------------------------------------------------
INSTALLING VIM DONE ...
`$vimInstDir/bin/vim --version`
vim path = $vimInstDir/bin/
------------------------------------------------------
_EOF
}

# compile YouCompleteMe
compileYCM() {
    cat << "_EOF"
------------------------------------------------------
STEP : COMPILING YCM ...
------------------------------------------------------
_EOF
    # comm attribute for getting source tmux
    repoLink=https://github.com/Valloric
	repoName=YouCompleteMe
    ycmDir=~/.vim/bundle/YouCompleteMe

    if [[ -d $ycmDir ]]; then
        echo [Warning]: already has YCM installed, omitting now ...
    else
        git clone $repoLink/$repoName $ycmDir
        # check if clone returns successfully
        if [[ $? != 0 ]]; then
            echo [Error]: git clone returns error, quiting now ...
            exit
        fi
    fi

    cd $ycmDir
	git submodule update --init --recursive
    ./install.py --clang-completer
    # check if install returns successfully
    if [[ $? != 0 ]]; then
        echo [Error]: install fails, quitting now ...
        exit
    fi

    cat << "_EOF"
------------------------------------------------------
Installing .ycm_extra_conf.py To Home ...
------------------------------------------------------
_EOF
    cd $startDir
    sampleDir=./sample
    sampleFile=ycm_extra_conf.py

    echo cp ${sampleDir}/$sampleFile ~/.$sampleFile
    cp ${sampleDir}/$sampleFile ~/.$sampleFile

    cat << _EOF
    
------------------------------------------------------
INSTALLING YCM DONE ...
------------------------------------------------------
_EOF
}

install() {
    installVim
    #compileYCM
}

case $1 in
    'home')
        commInstdir=$homeInstDir
        execPrefix=""
        install
    ;;

    'root')
        commInstdir=$rootInstDir
        execPrefix=sudo
		install
    ;;

    *)
        set +x
        usage
    ;;
esac
