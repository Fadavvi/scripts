. "$HOME/.cargo/env"
ulimit -n 8800
REPORTPATH=~/Documents/reports
#############################################################
#############################################################
nics(){
	ip -j -f inet address show | jq '.[]' | jq -r '(.ifname + ":\t" + .addr_info[].local)'
}
#############################################################
serve(){
	wwwtree.py -r . -i $1 -p 80 
	#python3 -m http.server $1
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
fix_history(){
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
	searchsploit "$1" -j | jq '.RESULTS_EXPLOIT | .[]' | jq 'select(.Type | index("dos") | not)' \
	| jq -r '("Tile: " + .Title + " | Type: " + .Type + " | CVE: " + .Codes + " | Explit-Path: " + .Path + "\r\n")' \
	| tr -s '\n'
	#| jq -r 'def colors:{"red":"\033[1;31m","reset":"\u001b[0m"}; ("Tile: " + colors.red + .Title + colors.reset + " | Type: " + colors.red + .Type + colors.reset + " | CVE: " + colors.red + .Codes + colors.reset + " | Explit-Path: " + colors.red + .Path + colors.reset + "\r\n")' \

}
#############################################################
passwords(){
	pass-station search "$1" --no-color --output JSON | jq -R 'fromjson?' | jq -c '.[] | select( . != null )' | jq -r '(.username + ":" + .password)'
}
#############################################################
tcpfull(){
	mkdir -p $REPORTPATH/$1
	rustscan -a $1 --accessible --batch-size 8000 -- -sV -sS -sC -Pn -T5 > $REPORTPATH/$1/TcpFullScan.txt
}
#############################################################
webfull(){
	Host=$(echo $1 | awk -F "://" '{print $2}')
	mkdir -p $REPORTPATH/$Host
	nuclei -u $1 -exclude-tags takeover,iot,aws,token-spray,headers -ept dns,whois,headless -silent -nc -follow-host-redirects -system-resolvers -c 80 -rl 200 -o $REPORTPATH/$Host/Nuclei.txt >/dev/null 2>&1 &
	katana -nc -silent -d 3 -js-crawl -known-files all -automatic-form-fill -c 50 -parallelism 50 -u $Host > $REPORTPATH/$Host/katana.txt &
	wait
}
#############################################################
# hash-id(){
# 	hash-identifier $1 | tail -n +15
# 	sleep 0.8
# 	HASHIDPID=$(pgrep -f hash-identifier)
# 	kill -9 $HASHIDPID >/dev/null 2>&1 &
# 	pkill -9 -f hash-identifier >/dev/null 2>&1 &
# }
#############################################################
# crackhash(){
# 	Algo={"algo":["MD4","MD5","SHA1","SHA224","SHA256","SHA384","SHA512","RMD160","GOST","WHIRLPOOL","LM","NTLM","MYSQL","CISCO7","JUNIPER","LDAP_MD5","LDAP_SHA1"]}
# 	AlgoCheck=$(echo $Algo | jq -r '.algo[]' | grep $PROTOCOL)
# 	if [[ -n $AlgoCheck ]];then
# 		python2 findmyhash.py $1 -h $2 -g
# 	fi
# }
##############################################################
smbchecks(){
	mkdir -p $REPORTPATH/$1
    smbmap -H $1 | tail -n +2 > $REPORTPATH/$1/smb-shares.txt
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
    fi
    $WriteAccess=$(cat $REPORTPATH/$1/smb-shares.txt | grep -o WRITE)
    if [[ -n $WriteAccess ]]; then
        echo '*** - Write Access to shared folder found:'
        cat $REPORTPATH/$1/smb-shares.txt | grep WRITE | sed 's/ //g' | sed 's/\t/ /g'
    fi
    crackmapexec smb $1 --users > $REPORTPATH/$1/smb-users.txt
    crackmapexec smb $1 --pass-pol > $REPORTPATH/$1/smb-passwdpolicy.txt
    nmap -T5 -Pn --script smb-vuln* -p 445 $1 > $REPORTPATH/$1/smb-vulns.txt
    nmap -T5 -Pn --script=smb-enum* --script-args=unsafe=1 -p 445 $1 > $REPORTPATH/$1/smb-enum.txt
}
##############################################################
hashcat-search(){
	hashcat -h | grep -i -A 478 "Hash modes" | grep -o $1 
}
##############################################################
# ldap-users(){
	
# }
