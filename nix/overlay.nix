final: prev: {
  stashsphereDocs = final.callPackage ./package.nix { inherit (prev) stashsphere-openapi; };
}
