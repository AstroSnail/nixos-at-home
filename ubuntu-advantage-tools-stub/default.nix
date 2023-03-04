{ lib, ... }:

{
  debianControl = lib.readFile ./control.txt;
  installScript = "";
}
