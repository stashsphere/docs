final: prev: {
  stashsphere-docs = final.callPackage ./package.nix { inherit (prev) stashsphere-openapi; };
}
