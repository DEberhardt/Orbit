function ConvertToMp3([switch] $inputObject, [string] $vlc = 'C:\Program Files (x86)\VLC\vlc.exe') {
  process {
    Write-Host $_
    $codec = 'mp3'
    $newFile = $_.FullName.Replace("'", "\'").Replace($_.Extension, ".$codec")
    &"$vlc" -I dummy "$_" ":sout=#transcode{acodec=$codec,vcodec=dummy}:standard{access=file,mux=raw,dst=`'$newFile`'}" vlc://quit | Out-Null
    # Uncomment the next line when you're sure everything is working right
    #Remove-Item $_.FullName.Replace('[', '`[').Replace(']', '`]')
  }
}

function ConvertAllToMp3([string] $sourcePath) {
  Get-ChildItem "$sourcePath\*" -Recurse -Include *.wma, *.aac, *.ogg, *.m4a | ConvertToMp3
}


function ConvertToMp3 {
  param(
    [switch] $inputObject,
    [string] $vlc = 'C:\Program Files (x86)\VLC\vlc.exe'
  )
  process {
    Write-Host $_
    $codec = 'mp3'
    $newFile = $_.FullName.Replace("'", "\'").Replace($_.Extension, ".$codec")
    &"$vlc" -I dummy "$_" ":sout=#transcode{acodec=$codec,vcodec=dummy}:standard{access=file,mux=raw,dst=`'$newFile`'}" vlc://quit | Out-Null
    # Uncomment the next line when you're sure everything is working right
    #Remove-Item $_.FullName.Replace('[', '`[').Replace(']', '`]')
  }
}
