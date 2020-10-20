#!/bin/bash

while read p; do
    echo "$p"
done < $1
