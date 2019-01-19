#! /usr/bin/env bash

# Reactive-Firewall firewall config service
# ......................................................................
# Copyright (c) 2013-2019, Mr. Walls
# ......................................................................
# Licensed under MIT (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# ......................................................................
# http://www.github.com/reactive-firewall/PiAP-firewall/LICENSE.md
# ......................................................................
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ......................................................................

HAS_FW_USER=$(id fw 1>&2 2>/dev/null >> /dev/null && echo -n 0 || echo -n $?)
FW_USER=0
HAS_POCKET_USER=$(id pocket-admin 1>&2 2>/dev/null >> /dev/null && echo -n 0 || echo -n $?)
if [[ ( ${HAS_FW_USER:-1} -lt 1 ) ]] ; then 
        FW_USER="fw"
elif [[ ( ${HAS_POCKET_USER:-1} -lt 1 ) ]] ; then 
        FW_USER="pocket-admin"
fi

# consider adding shred
declare BASEFILEPATH=$(dirname "${0}")
`${BASEFILEPATH}/build.sh > "${BASEFILEPATH}/temp.rules"` ; wait ;
`${BASEFILEPATH}/iterate.sh "${BASEFILEPATH}/temp.rules" >  "${BASEFILEPATH}/default.rules"` ; wait ;
shred --zero "${BASEFILEPATH}/temp.rules" 2>/dev/null || true ; wait ;
rm -vf "${BASEFILEPATH}/temp.rules" ; wait ;
install -m 0755 -o $FW_USER -g 0 "${BASEFILEPATH}/init.d" "/etc/init.d/fw"
install -m 0755 -o $FW_USER -g 0 "${BASEFILEPATH}/init" "/etc/init/fw.conf"
mkdir -p -m 0751 "/etc/fw" 2>/dev/null
chown $FW_USER "/etc/fw/"
chgrp 0 "/etc/fw/" 2>/dev/null || true
cp -f "${BASEFILEPATH}/default.rules" "/etc/fw/default.rules" ; wait ; sync ;
install -m 0640 -o $FW_USER -g 0 "${BASEFILEPATH}/default.rules" "/etc/fw/default.rules"
(update-rc.d fw enable 2>/dev/null || update-rc.d start 15 2345 . stop 0 1 6 fw 2>/dev/null ; wait ) 2>/dev/null || true ;
wait ;
exit 0 ;