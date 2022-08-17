.PHONY: all test clean

ifndef m
override m = test
endif

all: prettier users test docgen
build :; forge build
users :; node blacksmith.js create
test :; forge test -vvv --match-test $(m)
report :; forge test --gas-report -vvv --optimize
docgen :; npx hardhat docgen
deps :; git submodule update --init --recursive
install :; npm install
prettier :; npm run prettier
