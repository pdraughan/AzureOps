﻿#allowed characters can be further adjusted
$length = 32

$letters = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ".ToCharArray()
$uppers = "ABCDEFGHJKLMNPQRSTUVWXYZ".ToCharArray()
$lowers = "abcdefghijkmnpqrstuvwxyz".ToCharArray()
$digits = "23456789".ToCharArray()
$symbols = "_-+=@$%!".ToCharArray()

$chars = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789_-+=@$%".ToCharArray()

do {
	$pwdChars = "".ToCharArray()
	$goodPassword = $false
	$hasDigit = $false
	$hasSymbol = $false
	$pwdChars += (Get-Random -InputObject $uppers -Count 1)
	for ($i=1; $i -lt $length; $i++) {
		$char = Get-Random -InputObject $chars -Count 1
		if ($digits -contains $char) { $hasDigit = $true }
		if ($symbols -contains $char) { $hasSymbol = $true }
		$pwdChars += $char
	}
	$pwdChars += (Get-Random -InputObject $lowers -Count 1)
	$password = $pwdChars -join ""
	$goodPassword = $hasDigit -and $hasSymbol
} until ($goodPassword)

$Text = "$Password"
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($Text)
$EncodedText =[Convert]::ToBase64String($Bytes)
$EncodedText | clip