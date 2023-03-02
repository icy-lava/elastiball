# Elastiball

Elastiball is a game made with Love2D for LÖVE Jam 2023.

You can [download it on itch.io](https://icy-lava.itch.io/elastiball).

## Quickstart

### Windows

In command prompt:
```cmd
git clone https://github.com/icy-lava/elastiball.git elastiball
cd elastiball

:: Install dependencies

:: With chocolatey:
choco install love busybox make luarocks
:: Or with scoop:
scoop bucket add extras
scoop install love busybox-lean make luarocks

luarocks install tl

:: For web build:
npm i love.js

:: Build & Run
make run
```

### Ubuntu / Debian based

```shell
git clone https://github.com/icy-lava/elastiball.git elastiball
cd elastiball

# Install dependencies

sudo apt-get install luarocks love busybox make

luarocks install tl

# For web build:
npm i love.js

# Build & Run
make run
```
