# Pronto runner for cpplint

Pronto runner for [cpplint](https://github.com/cpplint/cpplint), command-line
tool to check C/C++ files for style issues following Google's C++ style guide.
[What is Pronto?](https://github.com/mmozuras/pronto)

## Usage

* `gem install pronto-cpplint`
* `pronto run`
* `PRONTO_CPPLINT_OPTS="--linelength=128" pronto run` for passing CLI options
  to `cpplint`

## Contribution Guidelines

### Installation

`git clone` this repo and `cd pronto-cpplint`

Ruby

```sh
rbenv install 3.1.0 # or newer
rbenv global 3.1.0 # or make it project specific
gem install bundle
bundle install
```

Make your changes

```sh
git checkout -b <new_feature>
# make your changes
bundle exec rspec
gem build pronto-cpplint.gemspec
gem install pronto-cpplint-<current_version>.gem
pronto run --unstaged
```

## Changelog

0.1.0 Initial public version.
