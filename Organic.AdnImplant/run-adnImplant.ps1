param(
    [Parameter(Position=0)]
    [string]$ClientId = " "  # Default value is "1" if not provided
)

# Define the path to the executable directory relative to the current location
$exePath = Join-Path -Path $PSScriptRoot -ChildPath "Organic.BusinessLogic\bin\App"
$exeFile = Join-Path -Path $exePath -ChildPath "ZooLogicSA.AdnImplant.exe"

# Execute the application with specified working directory
# This runs in the target directory but doesn't change your console's location
Start-Process -FilePath $exeFile -ArgumentList $ClientId -WorkingDirectory $exePath -NoNewWindow -Wait

#$exeBinPath = Join-Path -Path $PSScriptRoot -ChildPath "bin\Exe\bin"
#$genExeFile = Join-Path -Path $exeBinPath -ChildPath "genSeguridad.exe"

# Check if the file exists before attempting to execute it
#if (Test-Path -Path $genExeFile) {
#    Start-Process -FilePath $genExeFile -WorkingDirectory $exeBinPath -NoNewWindow -Wait
#} else {
#    Write-Error "The file 'genSeguridad.exe' was not found at path: $genExeFile"
#}