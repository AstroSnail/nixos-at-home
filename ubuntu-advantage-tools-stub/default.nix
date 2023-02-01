{
  debianControl = builtins.readFile ./control.txt;
  installScript = builtins.readFile ./install.sh;
}
