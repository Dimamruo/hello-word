$script:exclude="TEMP*","admin*","muromtsev","pot*","all*","default*","ltask","minaev","operator","GOD"
$script:drive='E:\backup1\'	##��������� ���� ���� ����������
$script:dircomp="Y:"		##����� ������ ������� ������� ���� � �������� ��������� ����� ���������
$script:comp=read-host "������� ��� �����"
#$script:comp="powershell"
write-host "`n`n ����� ����� ���������?`n`n 1)Backup `n 2)Restore `n e)Exit`n`n"

$answer=read-host "Enter the key"



function copy-file ([string]$from, [string]$to){
if((Test-Path $from) -eq $true){
	Copy-Item -Path $from -Destination $to -Recurse
	write-host -ForegroundColor green "$from - complite!"}
else{write-host -ForegroundColor red "$from - �� ���������� �� �������� ��"}
}



function backup-dirs(){
$script:os=Get-WmiObject -ComputerName $comp -Class win32_operatingsystem
net use $dircomp \\$comp\c$

if ($os.name -like '*windows xp*'){
$users=(Get-ChildItem -path ($dircomp+'\Documents and Settings') -Exclude $exclude|where{$_.Mode -like 'd----'})
#$filecount=(Get-ChildItem -path ($dircomp+'\Documents and Settings') -recurse  -Exclude $exclude|where{$_.Mode -like 'd----'})


$FROMroaming="\Application Data"
$FROMlocal="\Local Settings\Application Data"
$FROMdocuments="\��� ���������"
$FROMdescktop="\������� ����"
}

if ($os.name -notlike '*windows xp*'){
$users=(Get-ChildItem -path ($dircomp+'\Users') -Exclude $exclude|where{$_.Mode -like 'd----'})
#$filecount=(Get-ChildItem -path ($dircomp+'\Users') -recurse -Exclude $exclude|where{$_.Mode -like 'd----'})

$FROMroaming="\AppData\Roaming"
$FROMlocal="\AppData\Local"
$FROMdocuments="\Documents"
$FROMdescktop="\desktop"
}

$TOroaming="\AppData\Roaming"
$TOlocal="\AppData\Local"
$TOdocuments="\Documents"
$TOdescktop="\desktop"

#����� �������
$FULLuser=(Get-ChildItem -path ($dircomp+'\Users') -Exclude "Application Data","Local Settings","AppData")
$Signature="\Microsoft\Signatures"
$Mozilla="\Mozilla\Firefox"
$Google="\Google\Chrome"
$Opera="\Opera"
$OutlookContacts="\Microsoft\Outlook"

#$filecount.count
$users.fullname|Format-Table

#����������� �������������
$users|foreach{

#�������� ���������� ������ �����
$backupdir=$drive+$os.csname+"\"+$_.name
$user=$_.name

#���� � �������� ������������ �������� ��� �����
$FULLuser=(Get-ChildItem -path ($_.FullName) -Exclude "Application Data","Local Settings","AppData")
$FULLuser|foreach{
copy-file ($_.FullName) ($backupdir)
}


copy-file ($_.FullName+$FROMroaming+$Signature) ($backupdir+$TOroaming+$Signature)
copy-file ($_.FullName+$FROMroaming+$Mozilla) ($backupdir+$TOroaming+$Mozilla)
copy-file ($_.FullName+$FROMlocal+$Mozilla) ($backupdir+$TOlocal+$Mozilla)
copy-file ($_.FullName+$FROMroaming+$Google) ($backupdir+$TOroaming+$Google)
copy-file ($_.FullName+$FROMlocal+$Google) ($backupdir+$TOlocal+$Google)
copy-file ($_.FullName+$FROMroaming+$Opera) ($backupdir+$TOroaming+$Opera)
copy-file ($_.FullName+$FROMlocal+$Opera) ($backupdir+$TOlocal+$Opera)
copy-file ($_.FullName+$FROMlocal+$OutlookContacts) ($backupdir+$TOlocal+$OutlookContacts)
}

net use $dircomp /delete
}

if($answer -eq "1"){backup-dirs}
elseif($answer -eq "e*"){exit}
