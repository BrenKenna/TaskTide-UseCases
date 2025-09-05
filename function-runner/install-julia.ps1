
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh -outfile 'install.ps1'
.\install.ps1 -RunAsAdmin

scoop bucket add extras
scoop bucket add versions
scoop install main/julia