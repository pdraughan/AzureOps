$fileContentBytes = get-content 'pfx path location' -Encoding Byte
[System.Convert]::ToBase64String($fileContentBytes) | Out-File 'pfx-bytes.txt'

[System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("pfx path location"))