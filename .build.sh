#! /bin/bash
set -e

IVY_PATH=`pwd`/ivy

pushd installer/ivy
ant -Dmbs.ivy.path=${IVY_PATH} bootstrap
ant -Dmbs.ivy.path=${IVY_PATH}
popd

