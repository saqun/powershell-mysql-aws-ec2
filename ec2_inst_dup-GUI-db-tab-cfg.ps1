<#########################################################################################
 # This Powershell sript is a GUI for ec2_inst_dup 
 # (Amazon Elastic Compute Cloud Instance Creation)
 # 
 # Required: Powershell 3 and upper
 #           WPF (Windows Presentation Foundation) library installed. This is GUI package.
 #  
 #  This script is divided into 4 parts:
 #  - INIT: initialise global varaiables
 #  - XAML-GUI: build GUI
 #  - FUNCTION: define functions used by the GUI and for MySQL database
 #  - STATEMEMENT: Initialise GUI fields, associate actions to buttons and show-up the GUI
 #
 # Note: 
 #   - Button/field variables are prefixed by WPF
 #   - Functions are prefixed by HDW (HardWire)
 #   - Global variables are prefixed by $HDW
 #   - Local variables are in small letters
 #
 # Author: S YIM @ Hardwire, NZ
 # History: 
 #   - 13/02/2018: Initial version
 #   - 14/02/2018: Create block of codes
 #   - 15/02/2018: Added logfile managment
 #   - 20/02/2018: Added continuous status display
 #   - 22/02/2018: Added 2 fields AMI ID and Machine Type list
 #               : Added check region/keypair
 #   - 23/02/2018: Merged ec2_inst_dup.ps1 into ec2_inst_dup-GUI.ps1
 #  
 #   - 14/03/2018: Added Database (MySql) to store instances created. Need to install:
 #                 -- Wamp (Wampserver32 - http://www.wampserver.com) and,
 #                 -- MySQL.Net connector - http://dev.mysql.com/downloads/connector/net
 #   - 22/03/2018: Transferred AWS EC2 security info into a configfile
 #                 Added config file reader
 #>
 
############################ INIT PART ########################################
###############################################################################
# Get the part of the current script
#$MyInvocation.MyCommand.Path, (Get-Item -Path ".\" -Verbose).FullName
#

$HDW_ScriptPath     = Split-Path $MyInvocation.InvocationName
$HDW_LogPath        = (Resolve-Path .\).Path
$HDW_RunningFromGui = $true
$mydate             = (Get-Date).ToString('yyyyMMdd-HHmmss')
#$HDW_Logfile       = "$HDW_ScriptPath\ec2_inst_dup-$mydate.log"
$HDW_Logfile        = "$HDW_LogPath\ec2_inst_dup.log"

#### Read config file 

$HDW_ConfigFile     = "$HDW_ScriptPath\ec2_inst_dup.cfg"
if (Test-Path $HDW_ConfigFile) {
    Get-Content $HDW_ConfigFile | Foreach-Object -Process { 
         $k = [regex]::split($_,'='); 
         if (($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True) -and 
             ($k[0].StartsWith("#") -ne $True) -and ([string]::IsNullOrWhiteSpace($k[0]) -ne $True)) { 
             $varname = ($k[0]).Trim()
             $varval  = ($k[1]).Trim()
             # Write-Host "$varname=$varval"
             Set-Variable -Name $varname -value $varval -Scope Global
         } 
    } # -Process
} else {
   $HDW_SecurityGroupID = "sg-7813aa01"         
   $HDW_AccessKey       = "YOUR-AWS-ACCESS-KEY"
   $HDW_SecretKey       = "YOUR-AWS-SECRET-KEY"
   $HDW_KeyName         = "YOUR-AWS-KEYNAME"

   $HDW_EmailFrom       = "hardwireinfo@hardwire.co.nz"
   $PSEmailServer       = "YOUR-MAIL-SERVER"

   $MySQLHost          = 'localhost' ; #'MySQL-Host'
   $MySQLAdminUserName = 'root' ; # 'username'
   $MySQLAdminPassword = '';    ; #'password'
   $MySQLDatabase      = 'MySQL-DB'
   $MySQLTable         = 'MySQL-DB-TABLE'
}

$HDW_Verbose         = $true
$HDW_AWSRegion       = "ap-southeast-2" ; # default value, can be changed on GUI
$HDW_ValidKeyPairs   = @( @{Region=$HDW_AWSRegion; KeyPair=$HDW_KeyName})

$HDW_AmiId           = "ami-38708c5a"   ; # default value, can be changed on GUI
$HDW_InstanceType    = "t2.micro"       ; # default value, can be changed on GUI

# Initial Machine Instance List
# Table on Array of Hash Tables => to see table content 
# $MachineTypeList.ForEach({[PSCustomObject]$_}) | Format-Table -AutoSize 
# $MachineTypeList| % { new-object PSObject -Property $_} | Format-Table -AutoSize
$HDW_MachineTypeList = @( @{Family="General purpose"; Type="t2.nano"},
                          @{Family="General purpose"; Type="t2.micro"},
                          @{Family="General purpose"; Type="t2.small"},
                          @{Family="General purpose"; Type="t2.medium"},
                          @{Family="General purpose"; Type="t2.large"},
                          @{Family="General purpose"; Type="t2.xlarge"},
                          @{Family="General purpose"; Type="m5.large"},
                          @{Family="General purpose"; Type="m5.xlarge"},
                          @{Family="General purpose"; Type="m5.2xlarge"},
                          @{Family="General purpose"; Type="m5.4xlarge"},
                          @{Family="General purpose"; Type="m5.12xlarge"},
                          @{Family="General purpose"; Type="m5.24xlarge"},
                          @{Family="General purpose"; Type="m4.large"},
                          @{Family="General purpose"; Type="m4.xlarge"},
                          @{Family="General purpose"; Type="m4.2xlarge"},
                          @{Family="General purpose"; Type="m4.4xlarge"},
                          @{Family="General purpose"; Type="m4.10xlarge"},
                          @{Family="General purpose"; Type="m4.16xlarge"}
)

# Database : MySQL
$ConnectionString = "server=" + $MySQLHost + ";port=3306;uid=" + $MySQLAdminUserName + ";pwd=" + $MySQLAdminPassword + ";database="+$MySQLDatabase

################################# XAML-GUI PART ###################################
###################################################################################
#
# XAML to build graphical interface (excertped from Microsoft Visual Studio 2017)
#

$inputXML = @"
<Window x:Name="testbracket" x:Class="testbracket.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:testbracket"
        mc:Ignorable="d"
        Title="testbracket" Height="420" Width="764.356">
    <Grid Margin="0,0,-0.5,-27.5">
        <TabControl x:Name="tabControl">
            <TabItem Header="ComputerName">
                <Grid Background="#FF0B4A80">

                    <Label x:Name="LabelCandidateName1" Content="Candidate name" HorizontalAlignment="Left" Height="28" Margin="30,27,0,0" VerticalAlignment="Top" Width="150" FontWeight="Bold"/>
                    <Label x:Name="LabelCandidateEmail" Content="Candidate email" HorizontalAlignment="Left" Height="28" Margin="30,60,0,0" VerticalAlignment="Top" Width="150" FontWeight="Bold"/>
                    <Label x:Name="LabelCandidateRegion" Content="Candidate region" HorizontalAlignment="Left" Height="28" Margin="30,93,0,0" VerticalAlignment="Top" Width="150" FontWeight="Bold"/>
                    <TextBox x:Name="CandidateName" HorizontalAlignment="Left" Height="28" Margin="150,27,0,0" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="200"/>
                    <TextBox x:Name="CandidateEmail" HorizontalAlignment="Left" Height="28" Margin="150,65,0,0" TextWrapping="Wrap" Text="hardwireinfo@hardwire.co.nz" VerticalAlignment="Top" Width="200"/>
                    <ComboBox x:Name="CandidateRegion" HorizontalAlignment="Left" Height="28" Margin="150,101,0,0" VerticalAlignment="Top" Width="280"/>
                    <ComboBox HorizontalAlignment="Left" Margin="-257,263,0,0" VerticalAlignment="Top" Width="120"/>

                    <Label x:Name="LabelAMIID" Content="AMI ID" HorizontalAlignment="Left" Height="28" Margin="390,27,0,0" VerticalAlignment="Top" Width="94" FontWeight="Bold"/>
                    <Label x:Name="LabelMachineType" Content="Machine type" HorizontalAlignment="Left" Height="28" Margin="390,61,0,0" VerticalAlignment="Top" Width="94" FontWeight="Bold"/>
                    <TextBox x:Name="AMI_ID" HorizontalAlignment="Left" Height="28" Margin="489,27,0,0" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="200"/>
                    <ComboBox x:Name="MachineType" HorizontalAlignment="Left" Height="28" Margin="489,65,0,0" VerticalAlignment="Top" Width="200" />

                    <TextBlock x:Name="Database" HorizontalAlignment="Left" Height="23" Margin="30,149,0,0" TextWrapping="Wrap" TextAlignment="Center" Text="" VerticalAlignment="Top" Width="670"/>

                    <TextBox x:Name="Info" HorizontalAlignment="Left" Height="120" Margin="30,190,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="670" VerticalScrollBarVisibility="Auto"/>
                    <Button x:Name="ButtonCreateInstance" Content="Create Instance" HorizontalAlignment="Left" Height="28" Margin="465,320,0,0" VerticalAlignment="Top" Width="110" BorderThickness="3" FontWeight="Bold" FontFamily="Segoe UI Black"/>
                    <Button x:Name="ButtonCancel" Content="Cancel" HorizontalAlignment="Left" Height="28" Margin="186,320,0,0" VerticalAlignment="Top" Width="83" BorderThickness="3" FontWeight="Bold" FontFamily="Segoe UI Black"/>

                </Grid>
            </TabItem>
            <TabItem Header="Database" IsEnabled="True">
                <Grid Background="#FF0B4A80">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="13*"/>
                        <ColumnDefinition Width="27*"/>
                        <ColumnDefinition Width="710*"/>
                    </Grid.ColumnDefinitions>
                    <ListView x:Name="dblistView" HorizontalAlignment="Left" Height="266" Margin="10,86,0,0" VerticalAlignment="Top" Width="719" RenderTransformOrigin="0.498,0.169" Grid.ColumnSpan="3">
                        <ListView.View>
                            <GridView>
                                <GridViewColumn Header="Instance" DisplayMemberBinding ="{Binding 'Instance'}" Width="120"/>
                                <GridViewColumn Header="IP" DisplayMemberBinding ="{Binding 'IP'}" Width="100"/>
                                <GridViewColumn Header="DNS" DisplayMemberBinding ="{Binding 'DNS'}" Width="140"/>
                                <GridViewColumn Header="Date" DisplayMemberBinding ="{Binding 'Date'}" Width="80"/>
                                <GridViewColumn Header="Ami ID" DisplayMemberBinding ="{Binding 'AmiID'}" Width="100"/>
                                <GridViewColumn Header="Region" DisplayMemberBinding ="{Binding 'Region'}" Width="100"/>
                                <GridViewColumn Header="Created by" DisplayMemberBinding ="{Binding 'Created_by'}" Width="60"/>
                            </GridView>
                        </ListView.View>
                    </ListView>
                    <Button x:Name="btnDisplayDB" Content="Display database" HorizontalAlignment="Left" Height="25" Margin="10.134,5,0,0" VerticalAlignment="Top" Width="225" Grid.ColumnSpan="2" Grid.Column="1"/>
                    <Label x:Name="labelSQLServer" Grid.Column="2" HorizontalAlignment="Left" Height="29" Margin="227,10,0,0" VerticalAlignment="Top" Width="103" Content="MySQL Server" FontWeight="Bold"/>
                    <TextBlock x:Name="dbServer" Grid.Column="2" HorizontalAlignment="Left" Height="24" Margin="345,10,0,0" TextWrapping="Wrap" Background="White" VerticalAlignment="Top" Width="175"/>
                    <Label x:Name="labelUser" Grid.Column="2" HorizontalAlignment="Left" Height="29" Margin="531,10,0,0" VerticalAlignment="Top" Width="51" Content="User" FontWeight="Bold"/>
                    <TextBlock x:Name="dbUser" Grid.Column="2" HorizontalAlignment="Left" Height="24" Margin="582,10,0,0" TextWrapping="Wrap" Background="White" VerticalAlignment="Top" Width="107" Text="User"/>
                    <Label x:Name="labelDatabase" Grid.Column="1" HorizontalAlignment="Left" Height="29" Margin="10,35,0,0" VerticalAlignment="Top" Width="67" Content="Database" FontWeight="Bold" Grid.ColumnSpan="2"/>
                    <TextBlock x:Name="dbDatabase" Grid.Column="2" HorizontalAlignment="Right" Height="24" Margin="50,39,452,0" TextWrapping="Wrap" Background="White" VerticalAlignment="Top" Width="208"/>
                    <Label x:Name="labelTable" Grid.Column="2" HorizontalAlignment="Left" Height="29" Margin="263,34,0,0" VerticalAlignment="Top" Width="67" Content="Table" FontWeight="Bold"/>
                    <TextBlock x:Name="dbTable" Grid.Column="2" HorizontalAlignment="Right" Height="24" Margin="345,40,184,0" TextWrapping="Wrap" Background="White" VerticalAlignment="Top" Width="181"/>
                    <Label x:Name="labelNbElts" Grid.Column="2" HorizontalAlignment="Left" Height="29" Margin="531,44,0,0" VerticalAlignment="Top" Width="51" Content="Nb" FontWeight="Bold"/>
                    <TextBlock x:Name="dbNbElements" Grid.Column="2" HorizontalAlignment="Left" Height="24" Margin="582,44,0,0" TextWrapping="Wrap" Background="White" VerticalAlignment="Top" Width="107" Text="Nb of elements" RenderTransformOrigin="0.48,0.034"/>
                </Grid>
            </TabItem>
        </TabControl>

    </Grid>
</Window>

"@       
 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML

#Read XAML
 
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
try {
    $Form=[Windows.Markup.XamlReader]::Load( $reader )
} catch {
    $WarningMsg = "Unable to parse XML, with error: $($Error[0])`n"
    $WarningMsg = "$WarningMsg Ensure that there are NO SelectionChanged properties (PowerShell cannot process them)"
    Write-Warning "$WarningMsg"
    throw
}
 
#===========================================================================
# Load XAML Objects In PowerShell
#===========================================================================
  
$xaml.SelectNodes("//*[@Name]") | ForEach-Object { 
  # "trying item $($_.Name)";
  try {
    Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop
  } catch {
    throw
  }
}

#################################### FUNCTION PART #######################################
##########################################################################################

#---------- MySQL ---------------------------------------
<#
$Query = "select * from ec2_instance_table"
#$Query = "INSERT INTO  ec2_instance_table (INSTANCE_NAME, DESCRIPTION, CREATED_DATE, CREATED_TIME, CREATED_BY, AMI_ID, REGION, PUBLIC_IP, PUBLIC_DNS) VALUES ('i3', 'who is i1?', 'date1', 'time1', 'sakun','ami-id-1','nz', 'ip1','dns1')"


# PHP + WAMP (Windows)
# $bdd = new PDO('mysql:host=localhost;dbname=test;charset=utf8', 'root', '');
# $bdd = new PDO('mysql:host=sql.hebergeur.com;dbname=mabase;charset=utf8', 'pierre.durand', 's3cr3t');
# $reponse = $bdd->query('SELECT * FROM jeux_video');

$MySQLAdminUserName = 'root' ; # 'username'
$MySQLAdminPassword = '';    ; #'password'
$MySQLDatabase = 'ec2_instances_db' ; #'MySQL-DB'
$MySQLTable    = 'ec2_instance_table' ;# table name
$MySQLHost = 'localhost' ; #'MySQL-Host'
$ConnectionString = "server=" + $MySQLHost + ";port=3306;uid=" + $MySQLAdminUserName + ";pwd=" + $MySQLAdminPassword + ";database="+$MySQLDatabase
#>

function HDW_MySQLDatabaseInfo ($TextBlock) {
    $str = "MySQL server: $MySQLHost || "
    $str = $str + "User: $MySQLAdminUserName || "
    $str = $str + "Database: $MySQLDatabase || "
    $str = $str + "Table: $MySQLTable || "

    $Query = "select * from $MySQLTable"
    try {
        $DataSet = HDW_MySQL $Query 
        $nbelts  = $DataSet.Tables[0].Rows.count
        $str = $str + "Instances: $nbelts"
        $TextBlock.background = "Black"
    } catch {
        $str = $str + "MySQL is running?"
        $TextBlock.background = "Red"
   } finally {
        $TextBlock.Foreground = "White"
        $TextBlock.Text = $str
   }

   # return $str
 }

function HDW_MySQL([string]$Query)
{
   Try {
      [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
      $Connection = New-Object MySql.Data.MySqlClient.MySqlConnection
      $Connection.ConnectionString = $ConnectionString
      $Connection.Open()

      $Command = New-Object MySql.Data.MySqlClient.MySqlCommand($Query, $Connection)
      $DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command)
      $DataSet = New-Object System.Data.DataSet
      $RecordCount = $dataAdapter.Fill($dataSet, "data")
      # $DataSet.Tables[0]
   }
   Catch {
      # Write-Host "ERROR : Unable to run query : $query `n$Error[0]"
      throw $PSItem
  }
   Finally {
      $Connection.Close()
  }
  return $DataSet
}

function HDW_DisplayRow($DataSet) {
   $str = ""
   foreach ($Row in $DataSet.Tables[0].Rows) { 
      $id    = $Row.ID
      $iname = $Row.INSTANCE_NAME
      $desc  = $Row.DESCRIPTION
      $date  = "$($Row.CREATED_DATE)"; $date = $date.substring(0,10)
      $time  = $Row.CREATED_TIME
      $by    = $Row.CREATED_BY
      $amiid = $Row.AMI_ID
      $region= $Row.REGION
      $ip    = $Row.PUBLIC_IP
      $dns   = $Row.PUBLIC_DNS

	 $str = $str + "$iname | $desc | $date $time | $by | $amiid | $region | $ip | $dns`r"
  }
  return $str
}

function HDW_MySQL_Select 
{
  $Query = "select * from $MySQLTable;"
  $DataSet = HDW_MySQL $Query 
  $str = HDW_DisplayRow $DataSet
  return $str
  # write-host $str
}

function HDW_MySQL_Insert ($iname, $desc, $date, $time, $by, $amiid, $region, $ip, $dns)
{
   $Query = "INSERT INTO  $MySQLTable (INSTANCE_NAME, DESCRIPTION, CREATED_DATE, CREATED_TIME, CREATED_BY, AMI_ID, REGION, PUBLIC_IP, PUBLIC_DNS) VALUES (`'$iname`', `'$desc`', `'$date`', $time, `'$by`', `'$amiid`', `'$region`', `'$ip`', `'$dns`')"
   HDW_MySQL $Query 
}

#---------- End MySQL ---------------------------------------

## Debug purpose: display list of varaibles created 
Function HDW_Get-FormVariables {
   if ($global:ReadmeDisplay -ne $true) {
       Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;
       $global:ReadmeDisplay=$true
   }
   write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
   get-variable WPF*
}
 
#HDW_Get-FormVariables

<# This function returns false if $VarName doesnt exist or its value is ""
 # It returns true otherwise
 # NOTE:  this function is defined both in ec2_inst_dup.ps1 and ec2_inst_dup-GUI.ps1
 #  You need to change in both files if necessary
 #>

 function HDW_VarExistOrNotEmpty($VarName) {
    # Check if variable exist
    $Exist = Get-Variable -Name $VarName -Scope Global -ErrorAction SilentlyContinue
    if ($Exist -eq $null) {
       return $false
    }

    # Variable exists, check if value is empty
    $Exist = Get-Variable -Name $VarName -ValueOnly -ErrorAction SilentlyContinue
    if ($Exist -is [int]) {
      # for some reason when $Exist=0 => the expression "$Exist -eq " is true
      # So this test is to avoid having false error in the following if block
      return $true
    }
    if ($Exist -eq "") {
       return $false
    }
    return $true
 }

# Check if an email address is valid 
Function HDW_ValidEmailAddress($address) {
    try {
        $x = New-Object System.Net.Mail.MailAddress($address)
        return $true
    } catch {
        return $false
    }
}

#
# Fill "CandidateRegion" Combobox with AWSRegion
# $ListBoxName: name of combobox field on GUI
# $DefaultValue: default value to be selected 
function HDW_FillComboboxDropDownListWithAWSRegion ($ListBoxName, $DefaultValue) {

    Get-AWSRegion | ForEach-Object {
       $Region = $_.Region
       $Name = $_.Name
       $RName = "$Region`t$Name"
       $idx = $ListBoxName.Items.Add($RName)
       if ("$Region" -eq $DefaultValue) {
            $ListBoxName.SelectedIndex = $idx
       }
    }
}

# Fill Combobox list with machine Instance List
function HDW_FillComboboxDropDownListWithMachineType($MachineType, $DefaultValue) {

  $HDW_MachineTypeList | ForEach-Object {
        $Type = $_.Type
        $Family = $_.Family
        $DName = "$Type"
        $idx = $MachineType.Items.Add("$DName")
       if ("$Type" -eq $DefaultValue) {
            $MachineType.SelectedIndex = $idx
       }
  }
}

# Write progress status in gui
function HDW_GuiStatusUpdate ($msg, $TextField=$WPFInfo, $WPFForm=$Form) {

      # $Text = $TextField.Text + $msg
      # $TextField.Text = $Text 
 
      $TextField.AddText("$($msg)`r")

      # This is to show the text in the textbox (refresh)
      # Thanks to 6ratgus from 
      # http://powershell-scripting.com/index.php?option=com_joomlaboard&Itemid=76&func=view&id=23971&catid=5#23971
      $WPFForm.Dispatcher.Invoke([action]{$TextField.AddText("")},"render")

      # Autoscroll to the end of the text
      $TextField.Focus(); 
      $TextField.CaretIndex = $TextField.Text.Length; 
      $TextField.ScrollToEnd();
} 

# Call back trick (to called from batch script ec2_inst_dup.ps1
# if ($HDW_GuiUpdate) { (Get-Item "function:$HDW_GuiUpdate").ScriptBlock.invoke("my message") }
# $Global:HDW_GuiUpdate = HDW_GuiStatusUpdate


# Write logfile and update status on gui
##      [Parameter(Mandatory=$False)] [ValidateSet("INFO","WARNING","ERROR","FATAL")] [String] $Level = "INFO"
 function HDW_WriteLog {
   [CmdletBinding()] param(
         [Parameter(ValueFromPipeline=$True)] $Message,
         [Parameter(Mandatory=$False)] [string] $logfile,
         [Parameter(Mandatory=$False)] $TextBox,
         [Parameter(Mandatory=$False)] $WPFForm=$Form
      ) 
   process {
    
      $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
      $Line = "$Stamp $Message"
      if ($logfile) {
         Add-Content $logfile -Value $Line
      }
      if ($TextBox) {
         HDW_GuiStatusUpdate $Message $TextBox $WPFForm
      }
      if (($logfile -eq $null) -and ($TextBox -eq $null) -and $Global:HDW_Verbose) {
            Write-Output $Line
      }     
   } 
}

# Init textbox status
function HDW_GuiStatusInit ($msgcolor="White", $TextField=$WPFInfo) {
    #$TextField.Text = ""
    $TextField.Clear()
    $TextField.Foreground = $msgcolor
}

# Check if all fields are with correct values
function HDW_ValidFields {

   HDW_GuiStatusInit "Red";
   $Email = $WPFCandidateEmail.Text
   $ValidEmail = HDW_ValidEmailAddress $Email
   $Candidate = $WPFCandidateName.Text
   $AmiID = $WPFAMI_ID.Text
 
   if (-not $ValidEmail) {
        HDW_WriteLog "Invalid email $Email" $HDW_Logfile $WPFInfo
        return $false;
    } elseif (-not $Candidate) {
        # if ([string]::IsNullOrEmpty($Candidate))
        HDW_WriteLog "Candidate name cannot be empty" $HDW_Logfile $WPFInfo
        return $false;
    } elseif (-not $AmiID) {
        HDW_WriteLog "AMI ID cannot be empty" $HDW_Logfile $WPFInfo
        return $false;
    } else {
        $found = $false
        $AWSRegion = ($WPFCandidateRegion.SelectedItem).split()[0]
        foreach ($RegKeyP in $HDW_ValidKeyPairs) {
            $Region = $RegKeyP.Region
            if ($Region -eq $AWSRegion) {
                 $found = $true
                break
            }
        }
        if (-not $found) {
           HDW_WriteLog "No valid KeyPair for selected region $AWSRegion" $HDW_Logfile $WPFInfo
        }
        return $found
    }
}

# run the batch script to create ec2 inst 
function HDW_ExecScript ($script_path, $UName, $Email, $Region, $AmiID, $InstType, $Logfile, $TextBox, $MainForm) 
{
   try {
      # & $script_path  $UName $Email $Region $AmiID $InstType $Logfile $TextBox $MainForm
      HDW_CreateEC2Inst $UName $Email $Region $AmiID $InstType $Logfile $TextBox $MainForm
   } catch {
      $_
   }
   # Execute script in background
   # Use start-job instead? start-job <path-to-script> -argumentList @("arg1","arg2","etc")
   # start-job -FilePath "$HDW_ScriptPath\ec2_inst_dup.ps1" -argumentList @($UserName, $Email, $AWSRegion, $HDW_Logfile, $WPFInfo, $Form)
   # Get-Job | Wait-Job

}
 
### Create EC2 Inst (imported from ec2_inst_dup.ps1)

function HDW_CreateEC2Inst ($UName, $Email, $AWSRegion, $AmiID, $InstType, $Logfile, $TextBox, $WPFForm) {
    HDW_WriteLog "Setting region to $AWSRegion" $Logfile $TextBox $WPFForm

    set-defaultawsregion $AWSRegion

    # Set AWS credentail (Set profilename as Default to make it be used for all future commands as default)
    HDW_WriteLog "Setting AWS Credential with AccessKey $HDW_AccessKey and SecretKey $HDW_SecretKey" $Logfile $TextBox $WPFForm
    Set-AWSCredential -AccessKey $HDW_AccessKey -SecretKey $HDW_SecretKey -StoreAs Default

    # #Create new instance with a tag
    # #New instance comes from AWS base AMI and has no config
    $tag = @{Key="Name"; Value=$UName}
    $tagspec = new-object Amazon.EC2.Model.TagSpecification
    $tagspec.ResourceType = "Instance"
    $tagspec.Tags.Add($tag)

    HDW_WriteLog "Creating New EC2 Instance $AmiID $HDW_KeyName $HDW_SecurityGroupID $InstType $UName" $Logfile $TextBox $WPFForm
    # $NewInstance = New-EC2Instance -ImageId ami-50b65c32 -MinCount 1 -MaxCount 1 -KeyName SydneyKeyPair -SecurityGroupID sg-49dd9d2f -InstanceType m4.xlarge -TagSpecification $tagspec
    try {
       $NewInstance = New-EC2Instance -ImageId $AmiID -MinCount 1 -MaxCount 1 -KeyName $HDW_KeyName -SecurityGroupID $HDW_SecurityGroupID -InstanceType $InstType -TagSpecification $tagspec
     } catch {
       # $_
       $errormsg = $_
       # Write-Host "ERROR : New-EC2Instance execution error`n$Error[0]"
       $TextBox.Foreground = 'Red'
       HDW_WriteLog "[Error] $errormsg" $Logfile $TextBox $WPFForm
        throw $PSItem
    } 
    # ### Get created instance. Wait until IP and DNS info are available. Max wait time: 120 seconds
    HDW_WriteLog "Waiting for Public IP address and DNS name ..." $Logfile $TextBox $WPFForm

    <#### OLD CODE
    # $reservation = New-Object 'collections.generic.list[string]'
    # $reservation.add($ReservId)
    # $filter_reservation = New-Object Amazon.EC2.Model.Filter -Property @{Name = "reservation-id"; Values = $reservation}
    # $instance = Get-EC2Instance -Filter $filter_reservation
    #>
     
    # Wait for 2 minutes or until instance is running (state 16) 
    $ReservId = $NewInstance.ReservationId
    foreach ($s in 1..120) {
       $instance = Get-EC2Instance -Filter @{Name = "reservation-id"; Values = $ReservId}
       # Instace's state: 0 pending, 16 running, 32 shutting down, 48 terminated, 64 Stopping, 80 stopped
       # State=16 means IP and DNS are available
       if ($instance.RunningInstance.State.code -eq 16) {
           break
       }
       # wait for 5 second before doing next search   
       sleep 5
    }


    # #### Create email's body with the info of the created instance
    # #### Normally there is only one element in the list $instances
    $inst = $instance.RunningInstance
    $EmailBody = ""
    $EmailBody = $EmailBody + "`tUser name = $UName `n"
    $EmailBody = $EmailBody + "`tInstance ID = $($inst.InstanceID) `n"
    $EmailBody = $EmailBody + "`tPublic DNS Name = $($inst.PublicDnsName) `n"
    $EmailBody = $EmailBody + "`tPublic IP Address = $($inst.PublicIpAddress) `n"
    $EmailBody = $EmailBody + "`tPrivate IP Address = $($inst.PrivateIpAddress) `n"
    $EmailBody = $EmailBody + "`tPrivate DNS Name =  $($inst.PrivateDnsName)"

    # Get Instance ID
    # $irun = $NewInstance | Select-Object -ExpandProperty RunningInstance 
    $NewInstancdId = ($NewInstance | Select-Object -ExpandProperty RunningInstance | Select-Object InstanceId).InstanceId

    #### Store info in the database
    $mydate  = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $mytime  = (Get-Date).ToString('HHmmss')
    HDW_WriteLog "Inserting created instance $($inst.InstanceID) in database" $Logfile $TextBox $WPFForm

    $desc = "AWS Instances"
    try {
        HDW_MySQL_Insert $inst.InstanceID $desc $mydate $mytime $UName $AmiID $AWSRegion $inst.PublicIpAddress $inst.PublicDnsName
    } catch {
       # $_
       $errormsg = $_
       $TextBox.Foreground = 'Red'
       HDW_WriteLog $errormsg $Logfile $TextBox $WPFForm
       throw $PSItem
    }
    ##### Send email

    HDW_WriteLog "Sending email to $Email" $Logfile $TextBox $WPFForm
    HDW_WriteLog $EmailBody $Logfile $TextBox $WPFForm

    $EmailSubject = "New EC2 Instance $NewInstancdId"
    #Send-MailMessage -smtpserver smtp.smartcloud.co.nz -From $EmailFrom -To $EmailTo -Subject $EmailSubject -Body $EmailBody
    #$PSEmailServer = "smtp.smartcloud.co.nz"
    try {
        Send-MailMessage -From $HDW_EmailFrom -To $Email -Subject $EmailSubject -Body $EmailBody
        HDW_WriteLog "Sent email to $Email" $Logfile $TextBox $WPFForm
    } catch {
       # $_
       $errormsg = $_
       $TextBox.Foreground = 'Red'
       HDW_WriteLog $errormsg $Logfile $TextBox $WPFForm
       throw $PSItem
    }
    HDW_WriteLog "Instance creation done" $Logfile $TextBox $WPFForm
}

################################## STATEMENT PART ################################
##################################################################################

if (-not (HDW_VarExistOrNotEmpty PSEmailServer)) {
    # Write-Host "[Error] PSEmailServer not define. Please set the variable PSEmailServer and rerun again" -ForegroundColor red
    # exit
    $PSEmailServer = "smtp.smartcloud.co.nz"
}

HDW_WriteLog "Starting GUI session ..." $HDW_Logfile

# $Form.TopMost = $true
# Set field Info to empty
$WPFInfo.Text = ""
HDW_MySQLDatabaseInfo $WPFDatabase
$WPFInfo.IsEnabled=$True
# Init Candidate name to USERNAME
$WPFCandidateName.Text = $env:USERNAME
# Init AMI ID
$WPFAMI_ID.Text = $HDW_AmiId

# Fill combobox $WPFCandidateRegion with AWS region / selected value ap-southeast-2
HDW_FillComboboxDropDownListWithAWSRegion   $WPFCandidateRegion $HDW_AWSRegion
HDW_FillComboboxDropDownListWithMachineType $WPFMachineType  $HDW_InstanceType

## Action for "Create instance" button

$WPFButtonCreateInstance.Add_Click({
   $ret = HDW_ValidFields
   if ($ret -and $ret[-1]) {
      # All fields are valid
      HDW_GuiStatusInit "Green"
 
     # Extract Region from selected element
     $AWSRegion = ($WPFCandidateRegion.SelectedItem).split()[0]
     $UName = $WPFCandidateName.Text
     $AmiID = $WPFAMI_ID.Text
     $Email = $WPFCandidateEmail.Text
     $InstType = ($WPFMachineType.SelectedItem).split()[0]
     ############################################################
     # Execute  ec2_inst_dup.ps1 
     ###########################################################
  
     HDW_WriteLog "Running...`r$HDW_ScriptPath\ec2_inst_dup.ps1 $UName $Email $AWSRegion $AmiID $InstType" $HDW_Logfile $WPFInfo $Form
     # & "$HDW_ScriptPath\ec2_inst_dup.ps1" $UserName $Email $AWSRegion $HDW_Logfile $WPFInfo $Form
     HDW_ExecScript "$HDW_ScriptPath\ec2_inst_dup.ps1" $UName $Email $AWSRegion $AmiID $InstType $HDW_Logfile $WPFInfo $Form 
     HDW_WriteLog "Done`r" $HDW_Logfile $WPFInfo $Form
   }
})

# Action for Cancel button
$WPFButtonCancel.Add_Click({
    HDW_WriteLog "GUI close`r`r" $HDW_Logfile
    $form.Close()
})

# Action on Database
$WPFDatabase.add_MouseRightButtonDown({
    HDW_MySQLDatabaseInfo $WPFDatabase
    $Message = HDW_MySQL_Select
    HDW_GuiStatusUpdate $Message
})

# Action for WPFbtnDisplayDB
$WPFbtnDisplayDB.Add_Click({
    $WPFdbServer.Foreground = "Black"
    $WPFdbServer.Text   = $MySQLHost
    $WPFdbUser.Text     = $MySQLAdminUserName
    $WPFdbDatabase.Text = $MySQLDatabase
    $WPFdbTable.Text     = $MySQLTable  

    function Get-TableInfo ($MyTable) {
          $MyTable | Select-Object @{Name=‘Instance‘;Expression={$_.INSTANCE_NAME}},`
                                   @{Name=‘Date’;Expression={($_.CREATED_DATE).ToString("dd/MM/yyy")}}, ` 
                                   @{Name=‘AmiID’;Expression={$_.AMI_ID}}, ` 
                                   @{Name=‘Created_by’;Expression={$_.CREATED_BY}}, ` 
                                   @{Name=‘Region’;Expression={$_.REGION}}, ` 
                                   @{Name=‘IP’;Expression={$_.PUBLIC_IP}}, ` 
                                   @{Name=‘DNS’;Expression={$_.PUBLIC_DNS}}
    }
    $WPFdblistView.Items.Clear();
    $Query = "select * from $MySQLTable;"
    try {
        $DataSet = HDW_MySQL $Query
        $WPFdbNbElements.Text =  $DataSet.Tables[0].Rows.count
        Get-TableInfo $DataSet.Tables[0] | % {$WPFdblistView.AddChild($_)}
    } catch {
       # throw $PSItem ; # throw here will freeze the GUI
       $WPFdbServer.Foreground = "Red"
       $WPFdbServer.Text   = "$MySQLHost is running?"
    }
})

##### Display the GUI
$Form.ShowDialog() | out-null
