# maybe a little silly to put this here, but it's really not
# as straight forward/obvious as it should be to do this
with builtins; zipAttrsWith (_: foldl' (acc: ms: acc // ms) {})
# this one depends on `lib` from nixpkgs:
# builtins.foldl' lib.recursiveUpdate {};
