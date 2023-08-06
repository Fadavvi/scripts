. "$HOME/.cargo/env"
ulimit -n 8800
alias decolor='sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g"'
REPORTPATH=~/Documents/reports
#############################################################
#############################################################
nics(){
	ip -j -f inet address show | jq '.[]' | jq -r '(.ifname + ":\t" + .addr_info[].local)'
}
#############################################################
serve(){
	if [[ $# -eq 0 ]]; then
		echo "serve <NIC-Name>"
	else
		wwwtree.py -r . -i $1 -p 80 
		#python3 -m http.server $1
	fi
}
#############################################################
len(){
	echo ${#"$1"}
}
#############################################################
upper(){
	echo "$1" | tr a-z A-Z
}
#############################################################
lower(){
	echo "$1" | tr A-Z a-z 
}
#############################################################
fix-history(){
	mv ~/.zsh_history ~/.zsh_history_zzz
	strings -eS ~/.zsh_history_zzz > ~/.zsh_history
	fc -r ~/.zsh_history
	rm ~/.zsh_history_zzz
}
#############################################################
cls(){
	clear
}
#############################################################
exploits(){
	if [[ $# -eq 0 ]]; then
		echo "exploits <App/Dev/Etc.Name>"
	else
		searchsploit "$1" -j | jq '.RESULTS_EXPLOIT | .[]' | jq 'select(.Type | index("dos") | not)' \
		| jq -r '("Tile: " + .Title + " | Type: " + .Type + " | CVE: " + .Codes + " | Explit-Path: " + .Path + "\r\n")' \
		| tr -s '\n'
		#| jq -r 'def colors:{"red":"\033[1;31m","reset":"\u001b[0m"}; ("Tile: " + colors.red + .Title + colors.reset + " | Type: " + colors.red + .Type + colors.reset + " | CVE: " + colors.red + .Codes + colors.reset + " | Explit-Path: " + colors.red + .Path + colors.reset + "\r\n")' \
	fi
}
#############################################################
passwords(){
	if [[ $# -eq 0 ]]; then
		echo "passwords <App/Dev/Etc.Name>"
	else
		pass-station search "$1" --no-color --output JSON | jq -R 'fromjson?' | jq -c '.[] | select( . != null )' | jq -r '(.username + ":" + .password)'
	fi
}
#############################################################
alives(){
	if [[ $# -eq 0 ]]; then
		echo "alives <IP/IPRange>"
	else
        nmap -sn -T5 $1 | awk '/Nmap scan/{gsub(/[()]/,"",$NF); print $NF > "nmap_scanned_ips"}'
	fi
}
#############################################################
tcp-full(){
	if [[ $# -eq 0 ]]; then
		echo "tcp-full <IP/IPRange>"
	else
		mkdir -p $REPORTPATH/$1
		rustscan -a $1 --accessible --batch-size 8000 -- -sV -sS -sC -Pn -T5 > $REPORTPATH/$1/TcpFullScan.txt
	fi
}
#############################################################
web-full(){
	if [[ $# -eq 0 ]]; then
		echo "web-full <BaseURL>"
	else
		Host=$(echo $1 | awk -F "://" '{print $2}')
		mkdir -p $REPORTPATH/$Host
		nuclei -u $1 -exclude-tags takeover,iot,aws,token-spray,headers -ept dns,whois,headless -silent -nc -follow-host-redirects -system-resolvers -c 80 -rl 200 -o $REPORTPATH/$Host/Nuclei.txt >/dev/null 2>&1 &
		katana -nc -silent -d 3 -js-crawl -known-files all -automatic-form-fill -c 50 -parallelism 50 -u $Host > $REPORTPATH/$Host/katana.txt &
		# Nuclie fuzzing templates?
		wait
	fi
}
##############################################################
smb-checks(){
	if [[ $# -eq 0 ]]; then
		echo "smb-checks <IP>"
	else
		mkdir -p $REPORTPATH/$1
		smbmap -u "" -p "" -H $1 && smbmap -u "guest" -p "" -H $1  | tail -n +2 > $REPORTPATH/$1/smb-shares.txt
		$ReadAccess=$(cat $REPORTPATH/$1/smb-shares.txt | grep -o READ)
		if [[ -n $ReadAccess ]]; then
			echo '*** - Read Access to shared folder found:'
			cat $REPORTPATH/$1/smb-shares.txt | grep READ | sed 's/ //g' | sed 's/\t/ /g'
			SharedPath=$(cat $REPORTPATH/$1/smb-shares.txt | grep READ | awk -F ' ' '{print $1}')
			echo "*** - Use following command: smbclient //$1/$SharedPath"
			FileList=$(smbmap -R $SharedPath -H $1 | tail -n +2)
			echo "*** - List of shared files:"
			echo $FileList
			# impacket-samrdump $1 > $REPORTPATH/$1/smb-SAM.txt
			crackmapexec smb $1 --users > $REPORTPATH/$1/smb-users.txt
			crackmapexec smb $1 --pass-pol > $REPORTPATH/$1/smb-passwdpolicy.txt
		fi
		$WriteAccess=$(cat $REPORTPATH/$1/smb-shares.txt | grep -o WRITE)
		if [[ -n $WriteAccess ]]; then
			echo '*** - Write Access to shared folder found:'
			cat $REPORTPATH/$1/smb-shares.txt | grep WRITE | sed 's/ //g' | sed 's/\t/ /g'
		fi
		nmap -T5 -Pn --script smb-vuln* -p 139,445 $1 > $REPORTPATH/$1/smb-vulns.txt
		nmap -T5 -Pn --script=smb-enum* --script-args=unsafe=1 -p 445 $1 > $REPORTPATH/$1/smb-enum.txt
	fi
}
##############################################################
hashcat-search(){
	if [[ $# -eq 0 ]]; then
		echo "hashcat-search <HashType>"
	else
		hashcat -h | grep -i -A 478 "Hash modes" | grep -o $1
	fi
}
##############################################################
dc-ip(){
	if [[ $# -eq 0 ]]; then 
		echo "dc-ip <DomainName>"
	else
		nslookup -type=SRV _ldap._tcp.dc._msdcs.$1
	fi
}
##############################################################
zone-transfer(){
	if [[ $# -lt 2 ]]; then 
		echo "zone-transfer <DomainName> <NameServer>"
	else
		dig axfr $1 @$2
	fi
}
##############################################################
ldap-enum(){
	if [[ $# -eq 0 ]]; then 
		echo "ldap-enum <IP>"
	else
		nmap -sv -n --script "ldap* and not brute" -p 389 $1 > $REPORTPATH/$1/ldap-enum.txt
		echo -e "\n########################################################################\n" >> $REPORTPATH/$1/ldap-enum.txt
		ldapsearch -x -h $1 -s base >> $REPORTPATH/$1/ldap-enum.txt
	fi
}
##############################################################
