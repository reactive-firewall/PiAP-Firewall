#! /bin/bash

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

FIRST_IFACE=$(ip route show default | fgrep default | grep -oE "[dev]{3}\s[abelhstuwn]{3}[n]?[0-9]+\s" | cut -d \  -f 2 | head -n 1 )
LAST_IFACE=$(ip route | fgrep "10.0.40.1" | grep -oE "[dev]{3}\s[abelhstuwn]{3}[n]?[0-9]+\s" | cut -d \  -f 2 | tail -n 1 )
GW_IFACE=${FIRST_IFACE:-wlan0}
#GW_IP=$( ip route show default | fgrep $GW_IFACE | fgrep via | cut -d v -f 2 | cut -d \  -f 2 ) ;
GW_BCAST=255.255.255.255 ;
GW_MAC=$( ip addr show $GW_IFACE | fgrep ether | tr -s ' ' ' ' | cut -d \  -f 3 | cut -d \/ -f 1 ) ;
# GW host
GW_IP=$( ip addr show $GW_IFACE | fgrep inet | tr -s ' ' ' ' | cut -d \  -f 3 | cut -d \/ -f 1 )

#change if multi-homed
MY_MAIN_IFACE=$GW_IFACE ;
MY_MAIN_IP=$( ip addr show $MY_MAIN_IFACE | fgrep inet | tr -s ' ' ' ' | cut -d \  -f 3 | cut -d \/ -f 1 ) ;
MY_MAIN_MAC=$( ip addr show $MY_MAIN_IFACE | fgrep ether | tr -s ' ' ' ' | cut -d \  -f 3 | cut -d \/ -f 1 ) ;


MY_AUX_IFACE=${LAST_IFACE:-wlan1};
# used for special
MY_AUX_IP=10.0.40.1 ;
MY_AUX_MAC=$( ip addr show $MY_AUX_IFACE | fgrep ether | tr -s ' ' ' ' | cut -d \  -f 3 | cut -d \/ -f 1 ) ;
MY_AUX_MAC=${MY_AUX_MAC} ;

# unused
MY_OTHER_IFACE=${FIRST_IFACE:-wlan0};
MY_OTHER_IP=$( ip route show default | fgrep "${MY_OTHER_IFACE}" | grepCIDR | cut -d \  -f 1 | fgrep "/" | head -n 1 | sed -E -e 's/\//\\\\\//g' ) ;

# trusted LAN CIDR
#LAN_SUBNET=10.0.0.0\\/8 ;
LAN_SUBNET=10.0.40.0\\/24 ;

# Marks

CLOSED_MARK=606;
NEW_MARK=602;
CONNECTED_MARK=603;
ACTIVE_MARK=604;
ESTABLISHED_MARK=700;
NINE_SCAN=668;
XMAS_SCAN=667;
NULL_SCAN=661;
CON_SCAN=663;
GRAB_SCAN=664;
SYN_SCAN=662;
rm -f ./half_baked.rules 2>/dev/null ; wait ;

head -n 999999999 "${1}" | sed -E -e "s/^([[:print:]]+)+([$]{1}[G]{1}[W]{1}[_]{1}[I]{1}[F]{1}[A]{1}[C]{1}[E]{1}){1}([[:print:]]+)+$/\1${GW_IFACE}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[G]{1}[W]{1}[_]{1}[I]{1}[F]{1}[A]{1}[C]{1}[E]{1}){1}([[:print:]]+)+$/\1${GW_IFACE}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[G]{1}[W]{1}[_]{1}[I]{1}[P]{1}){1}([[:print:]]+)+$/\1${GW_IP}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[G]{1}[W]{1}[_]{1}[M]{1}[A]{1}[C]{1}){1}([[:print:]]+)+$/\1${GW_MAC}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[C]{1}[L]{1}[O]{1}[S]{1}[E]{1}[D]{1}[_]{1}[M]{1}[A]{1}[R]{1}[K]{1}){1}([[:print:]]+)*$/\1${CLOSED_MARK}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[M]{1}[Y]{1}[_]{1}[M]{1}[A]{1}[I]{1}[N]{1}[_]{1}[M]{1}[A]{1}[C]{1}){1}([[:print:]]+)+$/\1${MY_MAIN_MAC}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[M]{1}[Y]{1}[_]{1}[A]{1}[U]{1}[X]{1}[_]{1}[M]{1}[A]{1}[C]{1}){1}([[:print:]]+)+$/\1${MY_AUX_MAC}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[E]{1}[S]{1}[T]{1}[A]{1}[B]{1}[L]{1}[I]{1}[S]{1}[H]{1}[E]{1}[D]{1}[_]{1}[M]{1}[A]{1}[R]{1}[K]{1}){1}([[:print:]]+)*$/\1${ESTABLISHED_MARK}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[A]{1}[C]{1}[T]{1}[I]{1}[V]{1}[E]{1}[_]{1}[M]{1}[A]{1}[R]{1}[K]{1}){1}([[:print:]]+)*$/\1${ACTIVE_MARK}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[C]{1}[O]{1}[N]{2}[E]{1}[C]{1}[T]{1}[E]{1}[D]{1}[_]{1}[M]{1}[A]{1}[R]{1}[K]{1}){1}([[:print:]]+)*$/\1${CONNECTED_MARK}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[N]{1}[E]{1}[W]{1}[_]{1}[M]{1}[A]{1}[R]{1}[K]{1}){1}([[:print:]]+)*$/\1${NEW_MARK}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[L]{1}[A]{1}[N]{1}[_]{1}[S]{1}[U]{1}[B]{1}[N]{1}[E]{1}[T]{1}){1}([[:print:]]+)+$/\1${LAN_SUBNET}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[L]{1}[A]{1}[N]{1}[_]{1}[S]{1}[U]{1}[B]{1}[N]{1}[E]{1}[T]{1}){1}([[:print:]]+)+$/\1${LAN_SUBNET}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[G]{1}[W]{1}[_]{1}[B]{1}[C]{1}[A]{1}[S]{1}[T]{1}){1}([[:print:]]+)+$/\1${GW_BCAST}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[M]{1}[Y]{1}[_]{1}[M]{1}[A]{1}[I]{1}[N]{1}[_]{1}[I]{1}[F]{1}[A]{1}[C]{1}[E]{1}){1}([[:print:]]+)+$/\1${MY_MAIN_IFACE}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[M]{1}[Y]{1}[_]{1}[A]{1}[U]{1}[X]{1}[_]{1}[I]{1}[F]{1}[A]{1}[C]{1}[E]{1}){1}([[:print:]]+)+$/\1${MY_AUX_IFACE}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[M]{1}[Y]{1}[_]{1}[M]{1}[A]{1}[I]{1}[N]{1}[_]{1}[I]{1}[P]{1}){1}([[:print:]]+)+$/\1${MY_MAIN_IP}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[M]{1}[Y]{1}[_]{1}[A]{1}[U]{1}[X]{1}[_]{1}[I]{1}[P]{1}){1}([[:print:]]+)+$/\1${MY_AUX_IP}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[X]{1}[M]{1}[A]{1}[S]{1}[_]{1}[S]{1}[C]{1}[A]{1}[N]{1}){1}([[:print:]]+)*$/\1${XMAS_SCAN}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[N]{1}[I]{1}[N]{1}[E]{1}[_]{1}[S]{1}[C]{1}[A]{1}[N]{1}){1}([[:print:]]+)*$/\1${NINE_SCAN}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[N]{1}[U]{1}[L]{2}[_]{1}[S]{1}[C]{1}[A]{1}[N]{1}){1}([[:print:]]+)*$/\1${NULL_SCAN}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[C]{1}[O]{1}[N]{1}[_]{1}[S]{1}[C]{1}[A]{1}[N]{1}){1}([[:print:]]+)*$/\1${CON_SCAN}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[G]{1}[R]{1}[A]{1}[B]{1}[_]{1}[S]{1}[C]{1}[A]{1}[N]{1}){1}([[:print:]]+)*$/\1${GRAB_SCAN}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[S]{1}[Y]{1}[N]{1}[_]{1}[S]{1}[C]{1}[A]{1}[N]{1}){1}([[:print:]]+)*$/\1${SYN_SCAN}\3/g" > ./half_baked.rules 2>/dev/null ; wait;
head -n 999999999 "./half_baked.rules" | sed -E -e "s/^([[:print:]]+)+([$]{1}[G]{1}[W]{1}[_]{1}[I]{1}[F]{1}[A]{1}[C]{1}[E]{1}){1}([[:print:]]+)+$/\1${GW_IFACE}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[G]{1}[W]{1}[_]{1}[I]{1}[F]{1}[A]{1}[C]{1}[E]{1}){1}([[:print:]]+)+$/\1${GW_IFACE}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[G]{1}[W]{1}[_]{1}[I]{1}[P]{1}){1}([[:print:]]+)+$/\1${GW_IP}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[G]{1}[W]{1}[_]{1}[M]{1}[A]{1}[C]{1}){1}([[:print:]]+)+$/\1${GW_MAC}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[C]{1}[L]{1}[O]{1}[S]{1}[E]{1}[D]{1}[_]{1}[M]{1}[A]{1}[R]{1}[K]{1}){1}([[:print:]]+)+$/\1${CLOSED_MARK}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[M]{1}[Y]{1}[_]{1}[M]{1}[A]{1}[I]{1}[N]{1}[_]{1}[M]{1}[A]{1}[C]{1}){1}([[:print:]]+)+$/\1${MY_MAIN_MAC}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[M]{1}[Y]{1}[_]{1}[A]{1}[U]{1}[X]{1}[_]{1}[M]{1}[A]{1}[C]{1}){1}([[:print:]]+)+$/\1${MY_AUX_MAC}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[E]{1}[S]{1}[T]{1}[A]{1}[B]{1}[L]{1}[I]{1}[S]{1}[H]{1}[E]{1}[D]{1}[_]{1}[M]{1}[A]{1}[R]{1}[K]{1}){1}([[:print:]]+)+$/\1${ESTABLISHED_MARK}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[A]{1}[C]{1}[T]{1}[I]{1}[V]{1}[E]{1}[_]{1}[M]{1}[A]{1}[R]{1}[K]{1}){1}([[:print:]]+)+$/\1${ACTIVE_MARK}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[C]{1}[O]{1}[N]{2}[E]{1}[C]{1}[T]{1}[E]{1}[D]{1}[_]{1}[M]{1}[A]{1}[R]{1}[K]{1}){1}([[:print:]]+)+$/\1${CONNECTED_MARK}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[N]{1}[E]{1}[W]{1}[_]{1}[M]{1}[A]{1}[R]{1}[K]{1}){1}([[:print:]]+)+$/\1${NEW_MARK}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[L]{1}[A]{1}[N]{1}[_]{1}[S]{1}[U]{1}[B]{1}[N]{1}[E]{1}[T]{1}){1}([[:print:]]+)+$/\1${LAN_SUBNET}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[L]{1}[A]{1}[N]{1}[_]{1}[S]{1}[U]{1}[B]{1}[N]{1}[E]{1}[T]{1}){1}([[:print:]]+)+$/\1${LAN_SUBNET}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[G]{1}[W]{1}[_]{1}[B]{1}[C]{1}[A]{1}[S]{1}[T]{1}){1}([[:print:]]+)+$/\1${GW_BCAST}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[M]{1}[Y]{1}[_]{1}[M]{1}[A]{1}[I]{1}[N]{1}[_]{1}[I]{1}[F]{1}[A]{1}[C]{1}[E]{1}){1}([[:print:]]+)+$/\1${MY_MAIN_IFACE}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[M]{1}[Y]{1}[_]{1}[A]{1}[U]{1}[X]{1}[_]{1}[I]{1}[F]{1}[A]{1}[C]{1}[E]{1}){1}([[:print:]]+)+$/\1${MY_AUX_IFACE}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[M]{1}[Y]{1}[_]{1}[M]{1}[A]{1}[I]{1}[N]{1}[_]{1}[I]{1}[P]{1}){1}([[:print:]]+)+$/\1${MY_MAIN_IP}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[M]{1}[Y]{1}[_]{1}[A]{1}[U]{1}[X]{1}[_]{1}[I]{1}[P]{1}){1}([[:print:]]+)+$/\1${MY_AUX_IP}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[X]{1}[M]{1}[A]{1}[S]{1}[_]{1}[S]{1}[C]{1}[A]{1}[N]{1}){1}([[:print:]]+)+$/\1${XMAS_SCAN}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[N]{1}[I]{1}[N]{1}[E]{1}[_]{1}[S]{1}[C]{1}[A]{1}[N]{1}){1}([[:print:]]+)+$/\1${NINE_SCAN}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[N]{1}[U]{1}[L]{2}[_]{1}[S]{1}[C]{1}[A]{1}[N]{1}){1}([[:print:]]+)+$/\1${NULL_SCAN}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[C]{1}[O]{1}[N]{1}[_]{1}[S]{1}[C]{1}[A]{1}[N]{1}){1}([[:print:]]+)+$/\1${CON_SCAN}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[G]{1}[R]{1}[A]{1}[B]{1}[_]{1}[S]{1}[C]{1}[A]{1}[N]{1}){1}([[:print:]]+)+$/\1${GRAB_SCAN}\3/g" | sed -E -e "s/^([[:print:]]+)+([$]{1}[S]{1}[Y]{1}[N]{1}[_]{1}[S]{1}[C]{1}[A]{1}[N]{1}){1}([[:print:]]+)+$/\1${SYN_SCAN}\3/g" ;
wait ;
rm -f ./half_baked.rules 2>/dev/null ;

#| sed -E -e "s/^([[:print:]]+)+(){1}([[:print:]]+)+$/\1${}\3/g"
#[$]{1}[G]{1}[W]{1}[_]{1}[B]{1}[C]{1}[A]{1}[S]{1}[T]{1}

exit 0;
