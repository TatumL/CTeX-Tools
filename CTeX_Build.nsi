
!include "LogicLib.nsh"
!include "Sections.nsh"
!include "FileFunc.nsh"

Name "CTeX Build"
OutFile "CTeX_Build.exe"
RequestExecutionLevel user

ShowInstDetails show

!include "MUI2.nsh"

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL


!define PROGRAM "$EXEDIR\NSIS\makensis.exe"
!define OPTIONS "/INPUTCHARSET UTF8 /OUTPUTCHARSET UTF8"
!define Make '"${PROGRAM}" ${OPTIONS}'
!define INI_File "$EXEDIR\libs\CTeX_Build.ini"
!define INI_Sec "CTeX"
!define INI_Key "BuildNumber"

Var Debug

!macro _Build NAME
	${If} $Debug == "YES"
		nsExec::ExecToLog '${Make} /DDEBUG ${NAME}'
	${Else}
		nsExec::ExecToLog '${Make} ${NAME}'
	${EndIf}
	Pop $0
	${If} $0 != 0
;		Abort
	${EndIf}
!macroend
!define Build "!insertmacro _Build"

Var Build_Number
Var BUILD_ALL

Section
	Call ReadBuildNumber
	Call WriteBuildNumber
SectionEnd

Section "Build Repair" Sec_Repair
	${Build} '"$EXEDIR\CTeX_Repair.nsi"'
SectionEnd

Section "Build Update" Sec_Update
	${Build} '"$EXEDIR\CTeX_Update.nsi"'
SectionEnd

Section "Build Setup" Sec_Basic
	${Build} '"$EXEDIR\CTeX_Setup.nsi"'
SectionEnd

Section /o "Build Debug Version" Sec_Debug
SectionEnd

Section "Increment build number"
	${IfNot} ${Errors}
		Call ReadBuildNumber
		Call UpdateBuildNumber
		Call WriteBuildNumber
	${EndIf}
SectionEnd

Function .onInit
	${GetParameters} $R0
	${GetOptions} $R0 "/BUILD_ALL=" $BUILD_ALL
	
	${If} $BUILD_ALL != ""
		!insertmacro SelectSection ${Sec_Repair}
		!insertmacro SelectSection ${Sec_Update}
		!insertmacro SelectSection ${Sec_Basic}
	${EndIf}
FunctionEnd

Function .onSelChange
	${If} ${SectionIsSelected} ${Sec_Update}
	${OrIf} ${SectionIsSelected} ${Sec_Basic}
		!insertmacro SelectSection ${Sec_Repair}
	${EndIf}
	${If} ${SectionIsSelected} ${Sec_Debug}
		StrCpy $Debug "YES"
	${Else}
		StrCpy $Debug "NO"
	${EndIf}
	
FunctionEnd

Function ReadBuildNumber
	ReadINIStr $Build_Number "${INI_File}" "${INI_Sec}" "${INI_Key}"
	${If} $Build_Number == ""
		StrCpy $Build_Number "0"
	${EndIf}
FunctionEnd

Function UpdateBuildNumber
	IntOp $Build_Number $Build_Number + 1 
	WriteINIStr "${INI_File}" "${INI_Sec}" "${INI_Key}" $Build_Number
FunctionEnd

Function WriteBuildNumber
	FileOpen $0 "$EXEDIR\libs\CTeX_Build.nsh" "w"
	FileWrite $0 '!define BUILD_NUMBER "$Build_Number"$\r$\n'
	FileClose $0
FunctionEnd
