BEGIN {
  cat=""
  name=""
  x=-1000000
  z=-1000000
  FS=","
}

{
  if ($1 != cat || $2 != name || $4 != x || $6 != z) {
   print $0;
  }

  cat=$1;
  name=$2;
  x=$4;
  z=$6;
}