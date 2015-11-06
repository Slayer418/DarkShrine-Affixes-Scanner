#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile=PoE-DAS.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Misc.au3>
#include <File.au3>
#include <vkConstants.au3>

Global Const $DARKSHRINE_DATA_ULR = "http://exiletools.com/darkshrine-data.txt"
Global Const $Affixes = ObjCreate("Scripting.Dictionary")
Global $hAffixesFile = FileOpen("Affixes.txt")

Global $AffixesList = FileRead($hAffixesFile)
$EffectsData = BinaryToString((InetRead($DARKSHRINE_DATA_ULR, 1)))
$EffectsArray = StringSplit($EffectsData, @LF, 1)

For $I = 1 To _FileCountLines("Affixes.txt")
	$currentLine = FileReadLine($hAffixesFile, $I)

	If Not StringInStr($currentLine, "?") Then

		If StringInStr($currentLine, "|") Then ; If different affixes are tied to the same effect
			$multipleAffixes = StringSplit($currentLine, "|", 1)
			For $Y = 1 To $multipleAffixes[0]
				$Affixes.add($multipleAffixes[$Y], $EffectsArray[$I])
			Next
		Else
			$Affixes.add($currentLine, $EffectsArray[$I])
		EndIf

	EndIf
Next
FileClose($hAffixesFile)


While True
	If _IsPressed(1) Then
		ToolTip("")
	EndIf
	If _IsPressed("11") And _IsPressed("44") Then ; CTRL + D
		Send("^c")
		Local $Effects = ""
		$ItemData = ClipGet()
		$ItemAffixes = StringTrimLeft($ItemData, StringInStr($ItemData, "--------", 0, -1) + 9)

		$ItemAffixesArray = StringSplit($ItemAffixes, @LF, 1)
		For $I = 1 To $ItemAffixesArray[0] - 1
			$FilteredString = StringRegExpReplace($ItemAffixesArray[$I], "[^a-zA-Z_ ]", "") ; Removing all non-letter charecters (except space)
			$FilteredString = StringRegExpReplace($FilteredString, "^[ ]", "")
			$FilteredString = StringRegExpReplace($FilteredString, "  ", " ")

			If $Affixes.Exists($FilteredString) Then
				$EffectSplit = StringSplit($Affixes.Item($FilteredString), "|")
				$Effects = $Effects & $FilteredString & @CRLF & "----" & $EffectSplit[1] & @CRLF & "--------" & $EffectSplit[2] & @CRLF & @CRLF
			Else
				$Effects = $Effects & $FilteredString & @CRLF & "----" & "Unknown" & @CRLF & @CRLF
			EndIf
		Next
		ToolTip($Effects, MouseGetPos()[0], MouseGetPos()[1], "", 0, 3)
		Sleep(250)
	EndIf
	Sleep(50)
WEnd

