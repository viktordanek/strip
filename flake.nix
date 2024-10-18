{
    inputs =
        {
            flake-utils.url = "github:numtide/flake-utils" ;
            nixpkgs.url = "github:NixOs/nixpkgs" ;
        } ;
    outputs =
        { self, nixpkgs, flake-utils, ... } :
            let
                fun =
                    system :
                    let
                        pkgs = import nixpkgs { inherit system; } ;
                        lib =
                            string :
                                let
                                    first = builtins.substring 0 1 string ;
                                    head = builtins.substring 0 ( length - 1 ) string ;
                                    last = builtins.substring ( length - 1 ) 1 string ;
                                    length = builtins.stringLength string ;
                                    tail = builtins.substring 1 ( length - 1 ) string ;
                                    whitespace = [ " " "\t" "\n" "\r" "\f" ] ;
                                    in
                                        if length == 0 then string
                                        else if builtins.any ( w : w == first ) whitespace then lib tail
                                        else if builtins.any ( w : w == last ) whitespace then lib head
                                        else string ;
                        in
                            {
                                lib = lib ;
                                checks.testLib =
                                    pkgs.stdenv.mkDerivation
                                        {
                                            name = "test-lib";
                                            builder = "${pkgs.bash}/bin/bash" ;
                                            args =
                                                [
                                                    "-c"
                                                    ''
                                                        observed='${ lib "          HI            " }' &&
                                                            expected='HI' &&
                                                            if [ "$observed" != "$expected" ]
                                                            then
                                                                    exit 1
                                                            else
                                                                ${ pkgs.coreutils }/bin/mkdir $out
                                                            fi
                                                    ''
                                                ] ;
                                        } ;
                            } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
