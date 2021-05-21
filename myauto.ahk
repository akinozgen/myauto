;;
;; Preparations
;;
DesktopCount = 9
CurrentDesktop = 1

mapDesktopsFromRegistry() {
	global CurrentDesktop, DesktopCount

	IdLength := 32
	SessionId := getSessionId()
	if (SessionId) {
		RegRead, CurrentDesktopId, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\%SessionId%\VirtualDesktops, CurrentVirtualDesktop
		if (CurrentDesktopId) {
			IdLength := StrLen(CurrentDesktopId)
		}
	}

	RegRead, DesktopList, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
	if (DesktopList) {
		DesktopListLength := StrLen(DesktopList)

		DesktopCount := DesktopListLength / IdLength
	}
	else {
		DesktopCount := 1
	}

	i := 0
	while (CurrentDesktopId and i < DesktopCount) {
		StartPos := (i * IdLength) + 1
		DesktopIter := SubStr(DesktopList, StartPos, IdLength)
		OutputDebug, The iterator is pointing at %DesktopIter% and count is %i%.

		if (DesktopIter = CurrentDesktopId) {
			CurrentDesktop := i + 1
			OutputDebug, Current desktop number is %CurrentDesktop% with an ID of %DesktopIter%.
			break
		}
		i++
	}
}

getSessionId()
{
	ProcessId := DllCall("GetCurrentProcessId", "UInt")
	if ErrorLevel {
		OutputDebug, Error getting current process id: %ErrorLevel%
		return
	}
	OutputDebug, Current Process Id: %ProcessId%
	DllCall("ProcessIdToSessionId", "UInt", ProcessId, "UInt*", SessionId)
	if ErrorLevel {
		OutputDebug, Error getting session id: %ErrorLevel%
		return
	}
	OutputDebug, Current Session Id: %SessionId%
	return SessionId
}

switchDesktopByNumber(targetDesktop)
{
	global CurrentDesktop, DesktopCount

	mapDesktopsFromRegistry()

	if (targetDesktop > DesktopCount || targetDesktop < 1) {
		OutputDebug, [invalid] target: %targetDesktop% current: %CurrentDesktop%
		return
	}

	while(CurrentDesktop < targetDesktop) {
		Send ^#{Right}
		CurrentDesktop++
		OutputDebug, [right] target: %targetDesktop% current: %CurrentDesktop%
	}

	while(CurrentDesktop > targetDesktop) {
		Send ^#{Left}
		CurrentDesktop--
		OutputDebug, [left] target: %targetDesktop% current: %CurrentDesktop%
	}
}

createVirtualDesktop()
{
	global CurrentDesktop, DesktopCount
	Send, #^d
	DesktopCount++
	CurrentDesktop = %DesktopCount%
	OutputDebug, [create] desktops: %DesktopCount% current: %CurrentDesktop%
}

deleteVirtualDesktop()
{
	global CurrentDesktop, DesktopCount
	Send, #^{F4}
	DesktopCount--
	CurrentDesktop--
	OutputDebug, [delete] desktops: %DesktopCount% current: %CurrentDesktop%
}

SetKeyDelay, 75
mapDesktopsFromRegistry()
OutputDebug, [loading] desktops: %DesktopCount% current: %CurrentDesktop%

;;
;; Definitons
;;
;; 1. Win + Number(Top bar number) -> Switch to virtual desktop 'n'
;; 2. Win + Enter -> Open terminal (alacritty)
;; 3. Win + Shift + Q -> Close Active Window
;; 4. Win + Shift + E -> Edit this script
;; 5. Win + Shift + R -> Compile and run this script
;;

;; 1.
LWin & 1::switchDesktopByNumber(1)
LWin & 2::switchDesktopByNumber(2)
LWin & 3::switchDesktopByNumber(3)
LWin & 4::switchDesktopByNumber(4)
LWin & 5::switchDesktopByNumber(5)
LWin & 6::switchDesktopByNumber(6)
LWin & 7::switchDesktopByNumber(7)
LWin & 8::switchDesktopByNumber(8)
LWin & 9::switchDesktopByNumber(9)

;; 2.
LWin & Enter::
    Run C:\Program Files\Alacritty\alacritty.exe
    Return
	
;; 3. 
+#q::
    PostMessage, 0x112, 0xF060,,, A
Return

;; 4.
LWin & E::
	MsgBox, Script will be opened
						; Change this your path 
	Run C:\Program Files\Notepad++\notepad++.exe "C:\Users\Akın Özgen\Documents\myauto\myauto.ahk"
Return
	
;; 5.
LWin & R::
	MsgBox, Will be compiled.
	    ; Change this your path 
	Run "C:\Users\Akın Özgen\Documents\myauto\build.cmd"
Return
	
