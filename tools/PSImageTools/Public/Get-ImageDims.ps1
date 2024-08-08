using namespace System.Drawing

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
        return $Out
    }
}
