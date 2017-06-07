set -e
set -x
TERM=dumb

# NPM commands
ALEX=$(which alex || true)
# Delete 'alex' if it is not in a node_modules directory,
# which means it is ghc-alex.
if [[ -n "$ALEX" && "${ALEX/node_modules/}" == "${ALEX}" ]]; then
  echo "Removing $ALEX"
  sudo rm -rf $ALEX
fi
npm install

# GO commands
go get -u github.com/golang/lint/golint
go get -u golang.org/x/tools/cmd/goimports
go get -u sourcegraph.com/sqs/goreturns
go get -u golang.org/x/tools/cmd/gotype
go get -u github.com/kisielk/errcheck
go get -u github.com/BurntSushi/toml/cmd/tomlv

# Ruby commands
bundle install --path=vendor/bundle --binstubs=vendor/bin --jobs=8 --retry=3

# Dart Lint commands
if ! dartanalyzer -v &> /dev/null ; then
  wget -nc -O ~/dart-sdk.zip https://storage.googleapis.com/dart-archive/channels/stable/release/1.14.2/sdk/dartsdk-linux-x64-release.zip
  unzip -n ~/dart-sdk.zip -d ~/
fi

# VHDL Bakalint Installation
if [ ! -e ~/bakalint-0.4.0/bakalint.pl ]; then
  wget "http://downloads.sourceforge.net/project/fpgalibre/bakalint/0.4.0/bakalint-0.4.0.tar.gz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Ffpgalibre%2Ffiles%2Fbakalint%2F0.4.0%2F&ts=1461844926&use_mirror=netcologne" -O ~/bl.tar.gz
  tar xf ~/bl.tar.gz -C ~/
fi

# elm-format Installation
if [ ! -e ~/elm-format-0.18/elm-format ]; then
  mkdir -p ~/elm-format-0.18
  curl -fsSL -o elm-format.tgz https://github.com/avh4/elm-format/releases/download/0.5.2-alpha/elm-format-0.17-0.5.2-alpha-linux-x64.tgz
  tar -xvzf elm-format.tgz -C ~/elm-format-0.18
fi

# Julia commands
julia -e "Pkg.add(\"Lint\")"

# Lua commands
sudo luarocks install luacheck --deps-mode=none

<<<<<<< HEAD
# Infer commands
if [ ! -e ~/infer-linux64-v0.7.0/infer/bin ]; then
  wget -nc -O ~/infer.tar.xz https://github.com/facebook/infer/releases/download/v0.7.0/infer-linux64-v0.7.0.tar.xz
  tar xf ~/infer.tar.xz -C ~/
  cd ~/infer-linux64-v0.7.0
  opam init --y
  opam update
  opam pin add --yes --no-action infer .
  opam install --deps-only --yes infer
  ./build-infer.sh java
fi

# PMD commands
if [ ! -e ~/pmd-bin-5.4.1/bin ]; then
  wget -nc -O ~/pmd.zip https://github.com/pmd/pmd/releases/download/pmd_releases%2F5.4.1/pmd-bin-5.4.1.zip
  unzip ~/pmd.zip -d ~/
fi

# Rust commands
curl -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain=nightly-2017-03-04
# Workaround https://github.com/rust-lang/cargo/issues/2078
#        and https://github.com/rust-lang/cargo/issues/2429 (explanation)
# CircleCI gets its SSH agent activated, Travis doesn't need that.
CLIPPY_VERSION=0.0.118
if [ -e /home/ubuntu/.ssh/id_circleci_github ]; then
    eval `ssh-agent` && ssh-add /home/ubuntu/.ssh/id_circleci_github && cargo install clippy --vers $CLIPPY_VERSION --force
else
    cargo install clippy --vers $CLIPPY_VERSION --force
fi
cargo clippy -V


# Tailor (Swift) commands
# Comment out the hardcoded PREFIX, so we can put it into ~/.local
if [ ! -e ~/.local/tailor/tailor-latest ]; then
  curl -fsSL -o install.sh https://tailor.sh/install.sh
  sed -i 's/read -r CONTINUE < \/dev\/tty/CONTINUE=y/;;s/^PREFIX.*/# PREFIX=""/;' install.sh
  PREFIX=$HOME/.local bash ./install.sh
  # Provide a constant path for the executable
  ln -s ~/.local/tailor/tailor-* ~/.local/tailor/tailor-latest
fi

# PHPMD installation
if [ ! -e ~/phpmd/phpmd ]; then
  mkdir -p ~/phpmd
  curl -fsSL -o phpmd.phar http://static.phpmd.org/php/latest/phpmd.phar
  sudo chmod +x phpmd.phar
  sudo mv phpmd.phar ~/phpmd/phpmd
fi
