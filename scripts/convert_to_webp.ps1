$targetDirs = @(
    "Admin_Web_Panel\src\assets",
    "Pequire_Website\frontend\src\assets",
    "Provider_App\assets",
    "User_app\assets"
)

$convertedFiles = @()

foreach ($dir in $targetDirs) {
    $fullDir = Join-Path "c:\Users\Admin\Desktop\Ecosystem" $dir
    if (Test-Path $fullDir) {
        Write-Host "Processing directory: $fullDir"
        $files = Get-ChildItem -Path $fullDir -Recurse -Include *.png, *.jpg, *.jpeg
        foreach ($file in $files) {
            $newName = [System.IO.Path]::ChangeExtension($file.FullName, ".webp")
            Write-Host "Converting $($file.Name) to $($file.Name -replace '\..*$', '.webp')"
            
            # Use ffmpeg for conversion
            & ffmpeg -i $file.FullName -y $newName 2>$null
            
            if (Test-Path $newName) {
                $convertedFiles += [PSCustomObject]@{
                    OldName = $file.Name
                    NewName = [System.IO.Path]::GetFileName($newName)
                    OldFullName = $file.FullName
                    NewFullName = $newName
                }
            }
        }
    }
}

$convertedFiles | Export-Csv -Path "c:\Users\Admin\Desktop\Ecosystem\scripts\converted_images.csv" -NoTypeInformation
Write-Host "Conversion complete. List saved to scripts\converted_images.csv"
