$csvPath = "c:\Users\Admin\Desktop\Ecosystem\scripts\converted_images.csv"
$convertedFiles = Import-Csv $csvPath

$searchPaths = @(
    "c:\Users\Admin\Desktop\Ecosystem\Provider_App\lib",
    "c:\Users\Admin\Desktop\Ecosystem\Provider_App\pubspec.yaml",
    "c:\Users\Admin\Desktop\Ecosystem\User_app\lib",
    "c:\Users\Admin\Desktop\Ecosystem\User_app\pubspec.yaml",
    "c:\Users\Admin\Desktop\Ecosystem\Admin_Web_Panel\src",
    "c:\Users\Admin\Desktop\Ecosystem\Pequire_Website\frontend\src"
)

$extensions = @("*.dart", "*.yaml", "*.jsx", "*.js", "*.tsx", "*.ts", "*.css", "*.scss", "*.html")

foreach ($item in $convertedFiles) {
    $old = $item.OldName
    $new = $item.NewName
    
    if ($old -eq $new) { continue } # Should not happen with extension change

    Write-Host "Replacing $old with $new..."
    
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            $filesToSearch = if (Test-Path -Path $path -PathType Leaf) { @($path) } else { Get-ChildItem -Path $path -Recurse -Include $extensions }
            
            foreach ($file in $filesToSearch) {
                $filePath = if ($file -is [System.IO.FileInfo]) { $file.FullName } else { $file }
                $content = Get-Content -Raw $filePath
                if ($content -match [regex]::Escape($old)) {
                    Write-Host "  Found in $filePath"
                    $newContent = $content -replace [regex]::Escape($old), $new
                    Set-Content -Path $filePath -Value $newContent
                }
            }
        }
    }
}

Write-Host "Replacement complete."
