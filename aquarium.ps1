function Draw-Fish {
    param (
        [int]$x,
        [int]$y
    )

    $fish = "><(((('>"
    $Host.UI.RawUI.CursorPosition = New-Object Management.Automation.Host.Coordinates($x, $y)
    Write-Host $fish -NoNewline
}

function Clear-Screen {
    cls
}

$maxx = $Host.UI.RawUI.WindowSize.Width
$maxy = $Host.UI.RawUI.WindowSize.Height - 1
$random = New-Object Random

# Initialize positions for multiple fish
$fishPositions = @()
for ($i = 0; $i -lt 6; $i++) {
    $fishPositions += @{
        x = $random.Next(0, $maxx - 8)
        y = $random.Next(0, $maxy - 1)
    }
}

while ($true) {
    Clear-Screen

    # Update positions and draw each fish
    for ($i = 0; $i -lt $fishPositions.Count; $i++) {
        $fishPositions[$i].x = ($fishPositions[$i].x + 1) % ($maxx - 8)
        if ($fishPositions[$i].x -eq 0) {
            $fishPositions[$i].y = $random.Next(0, $maxy - 1)
        }
        Draw-Fish -x $fishPositions[$i].x -y $fishPositions[$i].y
    }

    Start-Sleep -Milliseconds 200
}
