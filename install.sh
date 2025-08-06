#!/bin/bash
#

cd dotfiles
git checkout main
git pull
cd ..

cd hydration
git checkout main
git pull
cd ..

cd infrastructure
git checkout main
git pull
cd ..

