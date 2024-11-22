# Zabbix server vars: 
$ZBX_SERVER = "zab.alnikor.loc"
$ZBX_API = "http://$ZBX_SERVER/zabbix/api_jsonrpc.php"
$ZBX_TOKEN = "de82c7117ba911b83e7734d10aa895569c2f50eac0e0c4abfb6cf4b11f2b0adb"
$ZBX_TEMPLATE = "Windows by Zabbix agent"
$ZBX_HOSTGRP = "Computers"

# Host vars:
$HOSTIP = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet).IPAddress.toString()
$HOSTNAME = ([System.Net.Dns]::GetHostByName($env:computerName).HostName).tolower()
$AGENT_PORT = "10050"

function RegisterNewHost() {
    $REQ_PARAMS = @{
    body =  @{
        "jsonrpc"= "2.0"
        "method"= "host.create"
        "params"= @{
            "host"= $HOSTNAME
            "interfaces"= @(
                @{
                "type"= 1
                "main"= 1
                "useip"= 1
                "ip"= $HOSTIP
                "dns"= ""
                "port"= $AGENT_PORT
                }
            )
            "groups"= @(
                @{
                "groupid"= "26"
                }
            )
	        "templates"= @(
                @{
                "templateid"= "10081"
                }
            )
        }
        "id"= 1
        "auth"= $ZBX_TOKEN
    } | ConvertTo-Json -Depth 5
    uri = "$ZBX_API"
    headers = @{"Content-Type" = "application/json"}
    method = "Post"
    }

    Invoke-WebRequest @REQ_PARAMS
}

function InstallZbxAgent() {
    msiexec /l*v \\alnikor.loc\File\Setup\msi\$HOSTNAME.log /i \\alnikor.loc\File\Setup\msi\zabbix_agent2-6.4.13-windows-amd64-openssl.msi /qn SERVER=$ZBX_SERVER LISTENPORT=$AGENT_PORT HOSTNAME=$HOSTNAME      
}

if (!(Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Zabbix Agent") -and !(Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Zabbix Agent 2")) {
    InstallZbxAgent
    RegisterNewHost
}