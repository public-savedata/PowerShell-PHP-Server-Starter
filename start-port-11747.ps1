Write-Host "PHP SERVER" -ForegroundColor Magenta

function Exit-Application {
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    exit
}

function Test-Validation {

    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [bool] $cond ,
        [Parameter(Mandatory = $true, Position = 1)]
        $show ,
        [Parameter(Mandatory = $true, Position = 2)]
        $exit
    )

    if ($cond) {
        Write-Host @greenCheck;
        Write-Host $show  
    }
    else {
        Write-Host $exit -ForegroundColor Red
        Exit-Application
    }
}


$path = Get-Location
$paths = @("$path\server","$path\app","$path\application")
foreach ($path in $paths) {
    if (Test-Path $path) {
        $StartDirectory = $path
        break
    }
}

$greenCheck = @{
    Object          = "   " + [Char]8730 + " "
    ForegroundColor = 'Green'
    NoNewLine       = $true
}

$Condition = Test-Path $StartDirectory ;
Test-Validation -cond $Condition -show "Server: $StartDirectory" -exit "The folder does not exist." 

$Condition = Test-Path "$StartDirectory\index.php" ;
Test-Validation -cond  $Condition  -show "Start Link: index.php" -exit "The file ""index.php"" is missing from the server startup."  


$phpPath = "c:\xampp\php\php.exe";
$Condition = Test-Path $phpPath ;
Test-Validation -cond  $Condition  -show "Php: $phpPath"  -exit "Php Not Found."  


 
# Pick Ip
$hostname = "127.0.0.1";

# Look For other IP on Network
$data = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias (Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }).Name 
if (@($data).Count -gt 1) {  
    Start-Sleep -Seconds 1
    Write-Host @greenCheck;
    Write-Host "Multiple Address Found"  
    $counter = 1;
    ForEach ($Ip in $data) {
        Write-Host "      " $counter  $Ip -ForegroundColor Magenta 
        $counter++;
    }
    $choice = Read-Host "      Select an option (1,2,...)"
    $SelectedIp = $data[$choice - 1];
    $hostname = $SelectedIp.IPAddress 
} 
if (@($data).Count -eq 1) {
    $SelectedIp = $data[0];
    $hostname = $SelectedIp.IPAddress ;
    Write-Host @greenCheck;
    Write-Host "Address: $hostname" 
}

## Extract New Port
$port = 1771;
$filename = $MyInvocation.MyCommand.Name
$filenameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($filename)

$fileKeys = $filenameWithoutExtension.Split('-');

if ($fileKeys -contains "port" ) {
    $index = [array]::IndexOf($fileKeys, "port" )
    $port = $fileKeys[$index + 1];
    Write-Host @greenCheck;
    Write-Host "Port: $port" 
} 

#Clear Clipboard
$startText = $hostname + ":" + $port;
Set-Clipboard 
Set-Clipboard -value $startText -Append;
$startText = "Link: " + $startText + " Coppied to Clipboard.";


Write-Host  "Starting Server:" $hostname ":" $port -ForegroundColor Red; 
Write-Host  $startText -ForegroundColor DarkGreen; 

Start-Sleep -Seconds 1

# $port = 1160
$command = $phpPath + " -S " + $hostname + ":" + $port + " -t " + $StartDirectory 
Write-Output $command 
 
Invoke-Expression -Command $command