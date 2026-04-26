$csvPath = "c:\Users\Admin\Desktop\Ecosystem\scripts\converted_images.csv"
$convertedFiles = Import-Csv $csvPath

foreach ($item in $convertedFiles) {
    $oldPath = $item.OldFullName
    if (Test-Path $oldPath) {
        Write-Host "Deleting $oldPath"
        Remove-Item $oldPath
    }
}

Write-Host "Cleanup complete."
