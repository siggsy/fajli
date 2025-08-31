{ ... }: {
  name = "key";
  check = (v: builtins.isAttrs v && builtins.hasAttr "_type" v && builtins.elem v._type ["literal" "path"]);
}
