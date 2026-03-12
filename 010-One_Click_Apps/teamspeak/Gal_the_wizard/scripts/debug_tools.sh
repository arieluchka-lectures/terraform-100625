#! /bin/sh

dnf update -y
dnf install -y nc #netcat for debugging disable post connectivity apporval
dnf install -y mtr #advanced traceroute for debugging
dnf install -y nmap #network mapper for debugging
