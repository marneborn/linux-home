#!/bin/bash

git fetch origin --prune 2>&1 | grep '[deleted]' | grep -e '\[deleted\]' | perl -p -e 's/.* origin\///' | xargs git branch -D
