

$SnapshotRG = "Snapshots-RG"
$Date = Get-Date
$SnapshotDate = $Date.ToString("dd-MM-yyyy")
$SnapshotDate
 
$VMDiskS=@()
$VMDiskS+=,('erpcinadb08_OsDisk_1_fe776f8b9c8c4ce7ac11dd689fcca391') 
$VMDiskS+=,('erpcinadb08_DataDisk_0')
$VMDiskS+=,('erpcinadb09_OsDisk_1_b2798c1b11884450b117e329bce78860')
$VMDiskS+=,('erpcinadb09_DataDisk_0')
$VMDiskS+=,('erpcinadb10_OsDisk_1_298d590052d24b7dba0c41069e4ef5da')
$VMDiskS+=,('erpcinadb10_DataDisk_0')

 
$ErrorActionPreference = "SilentlyContinue"
 
Foreach ($Disks in $VMDiskS)
 
    {
$ds = Get-AzureRmDisk
 
Foreach ($d in $ds)
 
        {
$DName = $d.Name

If ($d.Name -eq $Disks)

                {
$SnapshotName = $Disks + "-" + $SnapshotDate
 
$SnapshotName
$disk = Get-AzureRmDisk -ResourceGroupName $D.ResourceGroupName -DiskName $d.Name
$snap = New-AzureRmSnapshotConfig -SourceUri $disk.Id -CreateOption Copy -Location $d.Location
                    New-AzureRmSnapshot -ResourceGroupName $SnapshotRG -SnapshotName $SnapshotName -Snapshot $snap
                } 
 
        }
 
    }

