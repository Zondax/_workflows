zup-install:
	npx -y @zondax/cli@latest zup install

zup-update:
	npx -y @zondax/cli@latest zup update

zup-list:
	npx -y @zondax/cli@latest zup list

.PHONY: zup-install zup-update zup-list
