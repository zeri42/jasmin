{ pkgs ? import (if pinned-nixpkgs then scripts/nixpkgs.nix else <nixpkgs>) {}
, inCI ? false
, pinned-nixpkgs ? inCI
, coqDeps ? !inCI
, ocamlDeps ? !inCI
, testDeps ? !inCI
, devTools ? !inCI
, ecRef ? ""
, opamDeps ? false
, enableFramePointers ? false
}:

with pkgs;

let inherit (lib) optionals; in

let coqPackages = coqPackages_8_18; in

let mathcomp-word = callPackage scripts/mathcomp-word.nix { inherit coqPackages; }; in

let easycrypt = callPackage scripts/easycrypt.nix {
  inherit ecRef;
  why3 = pkgs.why3.override { ideSupport = false; };
}; in

let inherit (coqPackages.coq) ocamlPackages; in

let oP =
  if enableFramePointers
  then ocamlPackages.overrideScope' (self: super: {
    ocaml = super.ocaml.overrideAttrs (o: {
      configureFlags = o.configureFlags ++ [ "--enable-frame-pointers" ];
    });
  })
  else ocamlPackages
; in

if !lib.versionAtLeast oP.ocaml.version "4.11"
then throw "Jasmin requires OCaml ≥ 4.11"
else

let ecDeps = ecRef != ""; in

pkgs.mkShell {
  name = "jasmin-0";
  src = null;
  buildInputs = []
    ++ optionals coqDeps [ coqPackages.coq mathcomp-word ]
    ++ optionals testDeps ([ curl.bin oP.apron.out libllvm ] ++ (with python3Packages; [ python pyyaml ]))
    ++ optionals ocamlDeps ([ mpfr ppl ] ++ (with oP; [
         ocaml findlib dune_3
         cmdliner
         batteries
         ppxlib
         ppx_import
         ppx_sexp_conv
         ppx_yojson_conv
         ppx_deriving
         sel
         lsp
         sexplib
	pkgs.git
		 pkgs.coqPackages.vscoq-language-server
(pkgs.vscode-with-extensions.override {
			vscodeExtensions = [
			pkgs.vscode-extensions.ms-vsliveshare.vsliveshare
			] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
			  {
    				publisher = "maximedenes";
				name = "vscoq";
			        version = "2.0.3";
			    	sha256 = "sha256-ZYyQhOszWyFFmAk8P42voFP2FlQihCT6FnlzVxy7KMo=";
			  }
			] ++ pkgs.jasmin.buildInputs;
			})
         menhir (oP.menhirLib or null) zarith camlidl apron yojson ]))
    ++ optionals devTools (with oP; [ merlin ocaml-lsp ])
    ++ optionals ecDeps [ easycrypt alt-ergo z3.out ]
    ++ optionals opamDeps [ rsync git pkg-config perl ppl mpfr opam ]
    ;
}
