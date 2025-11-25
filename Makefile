.PHONY: iso test

iso:
	@./scripts/build-iso.sh

test:
	nix --extra-experimental-features 'nix-command flakes' flake check --no-build --allow-import-from-derivation
