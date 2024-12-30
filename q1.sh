#!/bin/bash

token="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJJZCI6ImZjOTFhOWMzLWNiYmMtNDQwZS05ZDkxLTg1MmY2ODJiYTA5NSIsIk1pbmluZyI6IiIsIm5iZiI6MTczNTU2ODU0OCwiZXhwIjoxNzY3MTA0NTQ4LCJpYXQiOjE3MzU1Njg1NDgsImlzcyI6Imh0dHBzOi8vcXViaWMubGkvIiwiYXVkIjoiaHR0cHM6Ly9xdWJpYy5saS8ifQ.PcWtBrIL8sHwPrUO-AbN8voiq0Vfr2QWtsfK8gEW4gny7jzEqUk1YWg6rKROZRK4g3-ByL5i_ut_QSWXceEA63xSrIdcpOiUegKJllr3ArNwFeuIv_PM9w536oMUA18hK3D5OQMFbk1o7MbMBH2Mpb6976uHNZEWESRAz1Kb0dLq0VlsmhrejIBtEBo7iSIjd8JrK36YbvzEjy6xPiVo7b_cHa0yOKjUrl7dj8xE7H8OqfPoUMCBrrjEAtDY5BcUdXVpZK-iKHFr_0S8smtx48760qJD66qJnghOiWfVMhhikyVStuRdpgKBsZHPMbwXHL8jkeODnk1_ayd2GlPoDw"
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
