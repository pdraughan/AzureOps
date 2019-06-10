[CmdletBinding()]
param
(
[parameter(Mandatory=$true)]
[string]$TexttoDecrypt`
)

Invoke-ServiceFabricDecryptText -CipherText $TexttoDecrypt | clip
Write-Host "The above has been decrypted and copied to your clipboard. Please verify by pasting elsewhere as this window will self destruct in 15 seconds." -ForegroundColor Green
Start-Sleep 15
exit