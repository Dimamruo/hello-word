function msgBox($x){
    [System.Windows.Forms.MessageBox]::Show($x, 'Information', 
	[Windows.Forms.MessageBoxButtons]::OK, 
	[Windows.Forms.MessageBoxIcon]::Information, [Windows.Forms.MessageBoxDefaultButton]::Button1,
	[Windows.Forms.MessageBoxOptions]::ServiceNotification
    )
}

function done($textradio){ 
    msgBox($textradio)
}

function hard-info(){
$HardInfo=(gwmi -Class win32_diskpartition|Select-Object name, BootPartition, @{n="Size"; e={$_.size/[math]::pow(2,20)}}|sort-object name)
$HardInfo|add-member -MemberType NoteProperty -Name Label -Value '' -Force
$HardInfo|add-member -MemberType NoteProperty -Name FreeSpace -Value '' -Force
$LogicalDisk=gwmi -Class Win32_LogicalDisk|where{$_.DriveType -like "3"}|select-object @{n="FreeSpace"; e={[int32]($_.FreeSpace/[math]::pow(2,20))}}, VolumeName, @{n="Size"; e={[int32]($_.size/[math]::pow(2,20))}}
for($i=0;$i -lt ($HardInfo|Measure-Object).count;$i++){
foreach($drive in $LogicalDisk){
if($HardInfo[$i].size -eq $drive.size){
$HardInfo[$i].Label=$drive.VolumeName
$HardInfo[$i].FreeSpace=$drive.FreeSpace
}}}
$HardInfo=$HardInfo|Sort-Object name|select-object Label, Size, FreeSpace, BootPartition
return $HardInfo
}

function get-size(){
$size=[int32]((gwmi win32_diskdrive|where{$_.DeviceID -like "*PHYSICALDRIVE0"}).size/[math]::pow(2,30))
if($size -lt 40){$sizeout=19500}
elseif($size -gt 40 -and $size -lt 100){$sizeout=51205}
elseif($size -gt 100){$sizeout=102405}
else{done("ERROR!! Not found PHYSICALDRIVE0")}
return $sizeout
}

function set-PartitionSize([int]$x){
Import-Module z:\Tools\Modules\ZTIUtility\ZTIUtility.psm1
$TSEnv:OSDDiskIndex=0
$TSEnv:OSDDiskPartitions1Type="Recovery"
$TSEnv:OSDPartitions0Type="Primary"
$TSEnv:OSDPartitions0FileSystem="NTFS"
$TSEnv:OSDPartitions0Bootable="True"
$TSEnv:OSDPartitions0QuickFormat="True"
$TSEnv:OSDPartitions0VolumeName="System Reserved"
$TSEnv:OSDPartitions0Size=500
$TSEnv:OSDPartitions0SizeUnits="MB"
$TSEnv:OSDPartitions1Type="Primary"
$TSEnv:OSDPartitions1FileSystem="NTFS"
$TSEnv:OSDPartitions1Bootable="False"
$TSEnv:OSDPartitions1QuickFormat="True"
$TSEnv:OSDPartitions1VolumeName="SYSTEM"
$TSEnv:OSDPartitions1Size=$x
$TSEnv:OSDPartitions1SizeUnits="MB"
$TSEnv:OSDPartitions1VolumeLetterVariable="OSDisk"
$TSEnv:OSDPartitions2Type="Primary"
$TSEnv:OSDPartitions2FileSystem="NTFS"
$TSEnv:OSDPartitions2Bootable="False"
$TSEnv:OSDPartitions2QuickFormat="True"
$TSEnv:OSDPartitions2VolumeName="DATA"
$TSEnv:OSDPartitions2Size=100
$TSEnv:OSDPartitions2SizeUnits="%"
$TSEnv:OSDPartitions=3
$TSEnv:OSDPartitionStyle="MBR"
$TSEnv:FormatOnlyC="False"
}

function set-PartitionSizeC(){
Import-Module z:\Tools\Modules\ZTIUtility\ZTIUtility.psm1
## Определяем объем первого раздела
$length=(gwmi -Class win32_diskpartition|measure).count
for($i=0;$i -lt $length; $i++)
{
$SystemPart=(gwmi -Class win32_diskpartition|where{$_.name -like "*0*$i*"}).size/[math]::pow(2,20)
#done($SystemPart)
$SystemPart
if ($SystemPart -gt 20000 -and $i -eq 0)
{
$TSEnv:OSDPartitions0VolumeLetterVariable="OSDisk"
break;
}
elseif ($SystemPart -gt 20000 -and $i -eq 1)
{
$TSEnv:OSDPartitions1VolumeLetterVariable="OSDisk"
break;
}
elseif ($SystemPart -gt 20000 -and $i -eq 2)
{
$TSEnv:OSDPartitions2VolumeLetterVariable="OSDisk"
break;
}
elseif ($SystemPart -gt 20000 -and $i -eq 3)
{
$TSEnv:OSDPartitions3VolumeLetterVariable="OSDisk"
break;
}
elseif ($SystemPart -gt 20000 -and $i -eq 4)
{
$TSEnv:OSDPartitions4VolumeLetterVariable="OSDisk"
break;
}
else{done("ERROR!!No found system partitions");break}
}
$TSEnv:FormatOnlyC="True"
}

function Format($info){

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
	
			$radioButton1 = new-object System.Windows.Forms.RadioButton
			$radioButton2 = new-object System.Windows.Forms.RadioButton
			$radioButton3 = new-object System.Windows.Forms.RadioButton
			$radioButton4 = new-object System.Windows.Forms.RadioButton
			$DataGridView1 = new-object System.Windows.Forms.DataGridView
			$OKButton = new-object System.Windows.Forms.Button
			$CancelButton = new-object System.Windows.Forms.Button
			$SuspendLayout

			
			$form = New-Object System.Windows.Forms.Form 
			## 
			## radioButton1
			## 
			$radioButton1.Location = new-object System.Drawing.Point(19, 14);
			$radioButton1.Name = "radioButton1";
			$radioButton1.Size = new-object System.Drawing.Size(104, 24);
			$radioButton1.TabIndex = 0;
			$radioButton1.TabStop = $True;
			#$radioButton1.Text = "Only part C";
			$radioButton4.Text = "Part C 16GB";
			$radioButton1.UseVisualStyleBackColor = $True;
			## 
			## radioButton2 old
			## 
			$radioButton2.Location = new-object System.Drawing.Point(312, 14);
			$radioButton2.Name = "radioButton2";
			$radioButton2.Size = new-object System.Drawing.Size(104, 24);
			$radioButton2.TabIndex = 2;
			$radioButton2.TabStop = $True;
			$radioButton2.Text = "Part C 50GB";
			$radioButton2.UseVisualStyleBackColor = $True;			## 
			#
            # radioButton2
			## 
			$radioButton2.Location = new-object System.Drawing.Point(312, 14);
			$radioButton2.Name = "radioButton2";
			$radioButton2.Size = new-object System.Drawing.Size(104, 24);
			$radioButton2.TabIndex = 2;
			$radioButton2.TabStop = $True;
			$radioButton2.Text = "Format all drive (удалить весь диск)";
			$radioButton2.UseVisualStyleBackColor = $True;
			## 
			## radioButton3
			<## 
			$radioButton3.Location = new-object System.Drawing.Point(161, 14);
			$radioButton3.Name = "radioButton3";
			$radioButton3.Size = new-object System.Drawing.Size(104, 24);
			$radioButton3.TabIndex = 1;
			$radioButton3.TabStop = $True;
			$radioButton3.Text = "Part C 100GB";
			$radioButton3.UseVisualStyleBackColor = $True;
#			$radioButton3.CheckedChanged += new-object System.EventHandler($RadioButton3CheckedChanged);
			##>
            ## 
			## radioButton3
			## 
			$radioButton3.Location = new-object System.Drawing.Point(161, 14);
			$radioButton3.Name = "radioButton3";
			$radioButton3.Size = new-object System.Drawing.Size(104, 24);
			$radioButton3.TabIndex = 1;
			$radioButton3.TabStop = $True;
			$radioButton3.Text = "Format all drive (Форматировать весь диск)";
			$radioButton3.UseVisualStyleBackColor = $True;
			## 
			## radioButton4
			##
			$radioButton4.Location = new-object System.Drawing.Point(160, 178);
			$radioButton4.Name = "radioButton4";
			$radioButton4.Size = new-object System.Drawing.Size(104, 24);
			$radioButton4.TabIndex = 3;
			$radioButton4.TabStop = $True;
			#$radioButton4.Text = "Part C 16GB";
			$radioButton1.Text = "Only part C";
			$radioButton4.UseVisualStyleBackColor = $True;
			## 
			## button1
			## 
			$OKButton.Location = new-object System.Drawing.Point(19, 178);
			$OKButton.Size = new-object System.Drawing.Size(75, 23);
			$OKButton.TabIndex = 4;
			$OKButton.Text = "Ok";
			$OKButton.UseVisualStyleBackColor = $True;
			$OKButton.DialogResult=[System.Windows.Forms.DialogResult]::OK
			## 
			## button2
			## 
			$CancelButton.Location = new-object System.Drawing.Point(320, 178);
			$CancelButton.Size = new-object System.Drawing.Size(75, 23);
			$CancelButton.TabIndex = 5;
			$CancelButton.Text = "Reboot";
			$CancelButton.UseVisualStyleBackColor = $True;
			$CancelButton.DialogResult=[System.Windows.Forms.DialogResult]::Cancel
			## 
			## DataGridView
			## 
			$DataGridView1.Location = new-object System.Drawing.Point(19, 45)
			$DataGridView1.Name = "DataGridView"
			$DataGridView1.Size = new-object System.Drawing.Size(376, 121)
			$DataGridView1.DataBindings.DefaultDataSourceUpdateMode = 0
			$DataGridView1.RowHeadersWidth=4;
			$DataGridView1.DataSource=[system.collections.arraylist]$info
			## 
			## MainForm
			## 
			$Form.ClientSize = new-object System.Drawing.Size(415, 221);
			#$Form.Controls.Add($radioButton4);
			$Form.Controls.Add($radioButton3);
			#$Form.Controls.Add($radioButton2);
			#$Form.Controls.Add($radioButton1);
			$Form.Controls.Add($OKButton);
			$Form.Controls.Add($CancelButton);
			$Form.Controls.Add($DataGridView1)
			$Form.Name = "MainForm";
			$Form.Text = "Format and partition disk for MBR";
			$Form.TopMost = $True;
			$Form.StartPosition = "CenterScreen"
	
	 # Assign the Accept and Cancel options in the form to the corresponding buttons
    $Form.AcceptButton = $OKButton
#    $Form.CancelButton = $CancelButton
	$CancelButton.Add_Click({$Form.Close()})
 
    # Activate the form
    $Form.Add_Shown({$Form.Activate()})    
    
    # Get the results from the button click
    $dialogResult = $Form.ShowDialog()
	# If the OK button is selected
    if ($dialogResult -eq "OK"){
	# Check the current state of each radio button and respond accordingly
        if ($RadioButton3.Checked){	
			set-PartitionSize(get-size)
			done($radioButton3.text)}
  <#      elseif ($RadioButton2.Checked){
        	set-PartitionSize(51205)
			done($radioButton2.text)}
        elseif ($RadioButton3.Checked){
			set-PartitionSize(102405)
			done($radioButton3.text)}
		elseif ($RadioButton4.Checked){
#			set-PartitionSizeC
			done($radioButton4.text)}#>
}
}
$info=hard-info
set-PartitionSize(get-size)
#Format $info
