# 40Docs

git config -f .gitmodules submodule.infrastructure.branch main
git config -f .gitmodules submodule.dotfiles.branch main
git config -f .gitmodules submodule.hydration.branch main

git clone --recurse-submodules https://github.com/40docs/.github.git ~/40docs

