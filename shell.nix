{pkgs ? import<nixpkgs> {}}:
let 
	firehose = import (builtins.fetchFromGitHub {
		    owner = "nixos";
		    repo = "nixpkgs";
    		    rev = "9d12c7a8167e6380add23a8060282cc2b72bd693";
   		    hash = "sha256-i5hSDpA1TsNFnI6JN727yKtDmsDNPRtn/ubLYI+3nG0=";
	}) {};
in
pkgs.mkShell {
	buildInputs = with pkgs; [
		jasmin-compiler
                easycrypt
                easycrypt-runtest
	];
}
