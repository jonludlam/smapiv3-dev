#!/bin/bash

P=`readlink -f $PWD/..`
docker run -it -v $P:/external xenserver-opam
