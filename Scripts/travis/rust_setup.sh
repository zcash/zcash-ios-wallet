#!/bin/bash

set -x

rustup-init --verbose -y

source $HOME/.cargo/env

cargo install cargo-lipo
