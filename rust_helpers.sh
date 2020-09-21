#!/bin/bash

SG_RUST_PROJECT_REPO=$HOME/rust
SG_RUST_BUILD_LOG_DIR=$HOME/www/rust-builds
SG_RUST_BUILD_LOG=$HOME/www/rust-log-latest
SG_RUSTC_TOOLCHAIN_NAME=stage1
SG_RUSTC_STAGE1=$SG_RUST_PROJECT_REPO/build/x86_64-unknown-linux-gnu/stage1

runRustStuff()
{
    mkdir -p $SG_RUST_BUILD_LOG_DIR
    pushd $SG_RUST_PROJECT_REPO

    local FILE_SUFFIX=$(uuidgen)

    if [[ $1 == "test-commit" ]]; then
        FILE_SUFFIX="commit_$(git rev-parse HEAD)_"$FILE_SUFFIX
        shift
    fi

    local build_file="$SG_RUST_BUILD_LOG_DIR/log_$FILE_SUFFIX"
    touch $build_file
    ln -sf $build_file $SG_RUST_BUILD_LOG

    env | rg SG_ | tee $build_file

    nice ./x.py fmt -j32
    nice ./x.py $@ |& tee -a $build_file
    popd
}

buildRust()
{
    runRustStuff build -j50 -i --stage 1 $@
}

screenBuildRust()
{
    screen -dm zsh -c "source $HOME/rust_stuff.sh; buildRust $@; exit"
}

testRust()
{
    runRustStuff test -i --stage 1 $@
}

openBuildLog()
{
    vim $SG_RUST_BUILD_LOG
}

testRustCommit()
{
    runRustStuff test-commit test -i --stage 1 $@
}

screenTestCommit()
{
    screen -dm zsh -c "source $HOME/rust_stuff.sh; testRustCommit; exit"
}

rustSetDevBuild()
{
    rustup toolchain link $SG_RUSTC_TOOLCHAIN_NAME $SG_RUSTC_STAGE1
}

rustCheck()
{
    pushd $SG_RUST_PROJECT_REPO
    ./x.py check -j32
    popd
}

