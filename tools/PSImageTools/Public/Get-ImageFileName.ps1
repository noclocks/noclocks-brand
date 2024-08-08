using namespace System.Drawing
Enum ImgExt {
    jpg
    jpeg
    png
    gif
    bmp
    tiff
    ico
    svg
    webp
    heic
    heif
    avif
}

Enum ImgType {
    Logo
    Icon
    Image
    Background
    Symbol
    Wordmark
    Brandmark
}

Function Get-ImageDims {
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
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$ImagePath
    )

    Begin {
        Add-Type -AssemblyName System.Drawing

        # Adjust Path
        $ImagePath = Resolve-Path $ImagePath
    }

    Process {
        try {
            Write-Verbose "[Process]: Getting dimensions for image: $ImagePath"
            $image = [System.Drawing.Image]::FromFile($ImagePath)

            Write-Verbose "[Process]: Image dimensions: $($image.Width) x $($image.Height)"
            $dimensions = @{
                Width  = $image.Width
                Height = $image.Height
            }

            if ($dimensions) {
                Write-Host "Image dimensions: $($dimensions.Width) x $($dimensions.Height)" -ForegroundColor Green
            }

            $Out = [PSCustomObject]@{
                Width  = $dimensions.Width
                Height = $dimensions.Height
            }
        } catch {
            Write-Error "An error occurred while reading the image: $_"
        } finally {
            Write-Verbose "[Process]: Closing image object"
            $image.Dispose()
        }
    }

    End {

        # unload the System.Drawing assembly
        [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

        return $Out
    }
}

Function Get-ImageFileName {
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
    .EXAMPLE
        Rename-ImageFiles -ImagePath "C:\path\to\image.jpg" -Type "logo" -Color "blue" -Feature "circular"
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$ImagePath,

        [Parameter(Mandatory = $false)]
        [string]$Company = "noclocks",

        [Parameter(Mandatory = $false)]
        [string]$Type,

        [Parameter(Mandatory = $false)]
        [string]$Color,

        [Parameter(Mandatory = $false)]
        [string]$Feature
    )

    Begin {

        # . $PSScriptRoot\Get-ImageDims.ps1

        # see if the System.Drawing assembly is loaded
        if (-not ([System.Management.Automation.PSTypeName]'System.Drawing.Image').Type) {
            Write-Host "Loading System.Drawing Assembly" -ForegroundColor Yellow
            Add-Type -AssemblyName System.Drawing
        }

        # Resolve the full path
        $ImagePath = Resolve-Path $ImagePath

        # Validate file extension
        $extension = [System.IO.Path]::GetExtension($ImagePath).TrimStart('.')
        if (-not [Enum]::IsDefined([ImgExt], $extension)) {
            Write-Error "Invalid file extension: $extension"
            return
        }
    }

    Process {
        try {
            # Get the image dimensions (unless SVG)
            if ($extension -ne 'svg') {
                $dims = Get-ImageDims -ImagePath $ImagePath
                $width = $dims.Width
                $height = $dims.Height
                $dimsString = "${height}x${width}px"
            } else {
                $dimsString = ""
            }

            # Get the file extension
            $extension = [System.IO.Path]::GetExtension($ImagePath).TrimStart('.')

            # Extract the current file name without extension
            $currentFileName = [System.IO.Path]::GetFileNameWithoutExtension($ImagePath)

            # Initialize new name parts with current name
            $nameParts = @($currentFileName.Split('-'))

            # Add components if not already present in the file name
            if ($Company -and $nameParts -notcontains $Company) { $nameParts += $Company }
            if ($Type -and $nameParts -notcontains $Type) { $nameParts += $Type }
            if ($Color -and $nameParts -notcontains $Color) { $nameParts += $Color }
            if ($Feature -and $nameParts -notcontains $Feature) { $nameParts += $Feature }
            if ($nameParts -notcontains $dimsString) { $nameParts += $dimsString }

            # Create the new file name
            $newFileName = ($nameParts -join '-') + ".$extension"

            if ($extension -eq 'svg') {
                $newFileName = $newFileName.Replace("-.svg", ".svg")
            }

            # Get the directory of the original file
            $directory = [System.IO.Path]::GetDirectoryName($ImagePath)

            # Create the new file path
            $newFilePath = Join-Path -Path $directory -ChildPath $newFileName
        } catch {
            Write-Error "An error occurred while getting the new file name for the image: $_"
        }
    }

    End {
        # unload the System.Drawing assembly
        [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

        $fileOut = Split-Path $newFilePath -Leaf
        return $fileOut
    }
}
