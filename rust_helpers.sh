#!/bin/bash

SG_RUST_PROJECT_REPO=$HOME/rust
SG_RUST_BUILD_LOG_DIR=$HOME/www/rust-builds
SG_RUSTC_TOOLCHAIN_NAME=stage1
SG_RUST_BUILD_LOG=$HOME/www/rust-log-latest

runRustStuff()
{
    mkdir -p $SG_RUST_BUILD_LOG_DIR
    pushd $SG_RUST_PROJECT_REPO

    local FILE_SUFFIX=$(uuidgen)

    if [[ $1 == "test-commit" ]]; then
        FILE_SUFFIX="commit_"$FILE_SUFFIX_$(git rev-parse HEAD)
        shift
    fi

    local build_file="$SG_RUST_BUILD_LOG_DIR/log_$FILE_SUFFIX"
    touch $build_file
    ln -sf $build_file $SG_RUST_BUILD_LOG

    ./x.py fmt
    ./x.py $@ |& tee $build_file
    popd
}

buildRust()
{
    runRustStuff build -j50 -i --stage 1 $@
}

testRust()
{
    runRustStuff test -j50 -i --stage 1 $@
}


openBuildLog()
{
    vim $SG_RUST_BUILD_LOG
}

testRustCommit()
{
    runRustStuff test-commit test -j50 -i --stage 1 $@
}

screenTestCommit()
{
    screen -dm zsh -c "source $HOME/rust_helpers.sh; testRustCommit"
}

rustSetDevBuild()
{
    rustup toolchain link $SG_RUSTC_TOOLCHAIN_NAME $SG_RUST_PROJECT_REPO/build/x86_64-unknown-linux-gnu/stage1
}
