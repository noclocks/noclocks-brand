using namespace System.Drawing

# Import enums from a separate file
. $PSScriptRoot\ImageEnums.ps1

function Get-ImageProperties {
    param(
        [string[]]$NameParts,
        [string]$Type,
        [string]$Color,
        [string]$Feature,
        [string]$Extension
    )

    $TypeMatchString = [ImgType]::GetNames([ImgType]) -join '|'
    $ColorMatchString = [ImgColor]::GetNames([ImgColor]) -join '|'
    $FeatureMatchString = [ImgFeature]::GetNames([ImgFeature]) -join '|'

    if (-not $Type) { $Type = $NameParts | Where-Object { $_ -match $TypeMatchString } }
    if (-not $Color) { $Color = $NameParts | Where-Object { $_ -match $ColorMatchString } }
    if (-not $Feature) { $Feature = $NameParts | Where-Object { $_ -match $FeatureMatchString } }

    if ($Extension -eq 'ico') {
        $Type = 'favicon'
        $Feature = 'favicon'
    }

    $Type = $Type[0]
    $Color = $Color[0]
    $Feature = $Feature[0]

    return $Type, $Color, $Feature
}

function Get-ImageDims {
    <#
    .SYNOPSIS
        Get the dimensions of an image file.
    .DESCRIPTION
        This function reads the dimensions of an image file and returns them as a custom object.
    .PARAMETER ImagePath
        The path to the image file.
    .EXAMPLE
        $imagePath = "C:\path\to\your\image.jpg"
        $dimensions = Get-ImageDims -ImagePath $imagePath
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$ImagePath
    )

    begin {
        Add-Type -AssemblyName System.Drawing
        $ImagePath = Resolve-Path $ImagePath
    }

    process {
        try {
            Write-Verbose "[Process]: Getting dimensions for image: $ImagePath"
            $image = [System.Drawing.Image]::FromFile($ImagePath)
            try {
                $dimensions = @{
                    Width  = $image.Width
                    Height = $image.Height
                }
                Write-Verbose "[Process]: Image dimensions: $($dimensions.Width) x $($dimensions.Height)"
                Write-Host "Image dimensions: $($dimensions.Width) x $($dimensions.Height)" -ForegroundColor Green

                [PSCustomObject]@{
                    Width  = $dimensions.Width
                    Height = $dimensions.Height
                }
            } finally {
                $image.Dispose()
            }
        } catch {
            Write-Error "An error occurred while reading the image: $_"
        }
    }
}

function Get-ImageFileName {
    <#
    .SYNOPSIS
        Renames image files based on specified format.
    .DESCRIPTION
        This function renames image files in the format:
        "{company}-{type}-{color}-{feature}-{dims}.{extension}"
    .PARAMETER ImagePath
        The path to the image file to be renamed.
    .PARAMETER Company
        The company name to be used in the new file name. Defaults to "noclocks".
    .PARAMETER Type
        The type of the image, such as logo, symbol, wordmark, brandmark, icon, etc.
    .PARAMETER Color
        The primary content color of the image.
    .PARAMETER Feature
        Features of the image such as circular, texturized, resized, enhanced, etc.
    .PARAMETER Rename
        If specified, the function will rename the files instead of just returning the new file name.
    .PARAMETER Backup
        If specified, the function will create a backup of the original file before renaming.
    .EXAMPLE
        Get-ImageFileName -ImagePath "C:\path\to\image.jpg" -Type "logo" -Color "blue" -Feature "circular"
    .EXAMPLE
        Get-ImageFileName -ImagePath "C:\path\to\image1.jpg","C:\path\to\image2.jpg" -Type "icon" -Color "red" -Feature "enhanced" -Rename
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string[]]$ImagePath,

        [Parameter(Mandatory = $false)]
        [string]$Company = "noclocks",

        [Parameter(Mandatory = $false)]
        [ValidateSet([ImgType])]
        [string]$Type,

        [Parameter(Mandatory = $false)]
        [ValidateSet([ImgColor])]
        [string]$Color,

        [Parameter(Mandatory = $false)]
        [ValidateSet([ImgFeature])]
        [string]$Feature,

        [Parameter(Mandatory = $false)]
        [switch]$Rename,

        [Parameter(Mandatory = $false)]
        [switch]$Backup
    )

    begin {
        if (-not ([System.Management.Automation.PSTypeName]'System.Drawing.Image').Type) {
            Write-Verbose "Loading System.Drawing Assembly"
            Add-Type -AssemblyName System.Drawing
        }
    }

    process {
        foreach ($path in $ImagePath) {
            try {
                $resolvedPath = Resolve-Path $path
                $extension = [System.IO.Path]::GetExtension($resolvedPath).TrimStart('.')

                if (-not [Enum]::IsDefined([ImgExt], $extension)) {
                    Write-Error "Invalid file extension: $extension"
                    continue
                }

                $dimsString = if ($extension -ne 'svg') {
                    $dims = Get-ImageDims -ImagePath $resolvedPath
                    "{0}x{1}" -f $dims.Height, $dims.Width
                } else { "" }

                $currentFileName = [System.IO.Path]::GetFileNameWithoutExtension($resolvedPath)
                $nameParts = $currentFileName -split '-' | Where-Object { $_ -notmatch '^\d+x\d+$' }

                $Type, $Color, $Feature = Get-ImageProperties -NameParts $nameParts -Type $Type -Color $Color -Feature $Feature -Extension $extension

                $newNameParts = @($Company, $Type, $Color, $Feature, $dimsString) | Where-Object { $_ }
                $newFileName = ($newNameParts -join '-') + ".$extension"
                $newFileName = $newFileName -replace "-\.$extension", ".$extension"

                $directory = [System.IO.Path]::GetDirectoryName($resolvedPath)
                $newFilePath = Join-Path -Path $directory -ChildPath $newFileName

                if ($Rename) {
                    if ($Backup) {
                        $backupPath = Join-Path -Path $directory -ChildPath ("backup-" + [System.IO.Path]::GetFileName($resolvedPath))
                        Copy-Item -Path $resolvedPath -Destination $backupPath
                        Write-Verbose "Backup created: '$backupPath'"
                    }

                    Rename-Item -Path $resolvedPath -NewName $newFilePath
                    Write-Verbose "Renamed '$resolvedPath' to '$newFilePath'"
                } else {
                    Write-Verbose "New file name: '$newFilePath'"
                }

                [PSCustomObject]@{
                    OriginalFilePath = $resolvedPath
                    NewFilePath      = $newFilePath
                }
            } catch {
                Write-Error "An error occurred while processing the image '$path': $_"
            }
        }
    }
}

Export-ModuleMember -Function Get-ImageDims, Get-ImageProperties, Get-ImageFileName
