; vi: foldmethod=marker foldmarker={{{,}}}
;
; Prevent the message
;   »An older instance of this script is already running, replace it with this instance«.
;   
#singleInstance force

; Dragging Windows {{{
;
; Downloaded from
;    https://autohotkey.com/docs/scripts/EasyWindowDrag_(KDE).htm
;
; Needs ahk 1.1
;
;
; This script was inspired by and built on many like it
; in the forum. Thanks go out to ck, thinkstorm, Chris,
; and aurelian for a job well done.

; Change history:
; November 07, 2006: Optimized resizing code in !RButton, courtesy of bluedawn.
; February 05, 2006: Fixed double-alt (the ~Alt hotkey) to work with latest versions of AHK.

; The Double-Alt modifier is activated by pressing
; Alt twice, much like a double-click. Hold the second
; press down until you click.
;
; The shortcuts:
;  Alt + Left Button  : Drag to move a window.
;  Alt + Right Button : Drag to resize a window.
;  Double-Alt + Left Button   : Minimize a window.
;  Double-Alt + Right Button  : Maximize/Restore a window.
;  Double-Alt + Middle Button : Close a window.
;
; You can optionally release Alt after the first
; click rather than holding it down the whole time.

; tq84 If (A_AhkVersion < "1.0.39.00")
; tq84 {
; tq84     MsgBox,20,,This script may not work properly with your version of AutoHotkey. Continue?
; tq84     IfMsgBox,No
; tq84     ExitApp
; tq84 }


; -------------------------------------------------------------------------------------------------------------
;
; setWinDelay sets the delay in milli-seconds that will occur after each windowing command (such as winActivate)
;
; This is the setting that runs smoothest on my
; system. Depending on your video card and cpu
; power, you may want to raise or lower this value.
;
; tq84 setWinDelay, 2


; Set the coordinate mode for the mouse {{{
;   coordMode, mouse affects
;      - mouseGetPos
;      - click
;      - mouseMove/click/drag
;  
;   screen is the default.
;
coordMode, mouse, screen
return ; }}}

!LButton::     ; {{{  alt + left mouse button.
mouseGetPos, dragWindow_mouseStartX, dragWindow_mouseStartY, HWND_alt_LButton
if doubleAlt { ; {{{ Minimize window with double alt + left Button
; tq84  mouseGetPos,,,HWND_alt_LButton
  ; This message is mostly equivalent to winMinimize,
  ; but it avoids a bug with PSPad.
  ;   0x0112 = WM_SYSCOMMAND
  ;   0xf020 = SC_MINIMIZE
    postMessage, 0x0112, 0xf020,,,ahk_id %HWND_alt_LButton%
  ; tq84: winMinimize does not work, indeed:
  ;       winMinimize
    doubleAlt := false
    return
} ; }}}

; Check if Window is maximized {{{
winGet, isWinMaximized, minMax, ahk_id %HWND_alt_LButton%
if isWinMaximized {
 ;
 ; Window is maximized - it makes no sense to continue.
 ;
   return
} ; }}}

; Get the initial window position for dragging.
winGetPos, dragWindow_winStartX, dragWindow_winStartY,,, ahk_id %HWND_alt_LButton%
loop { ; {{{
    getKeyState, KDE_Button, LButton, P ; Break if button has been released.
    if KDE_Button = U
        break
    mouseGetPos, dragWindow_mouseCurX, dragWindow_mouseCurY ; Get the current mouse position.
;   dragWindow_mouseCurX -= dragWindow_mouseStartX ; Obtain an offset from the initial mouse position.
;   dragWindow_mouseCurY -= dragWindow_mouseStartY
    dragWindow_mouseDiffX := dragWindow_mouseCurX - dragWindow_mouseStartX  ; Obtain an offset from the initial mouse position.
    dragWindow_mouseDiffY := dragWindow_mouseCurY - dragWindow_mouseStartY
;   KDE_WinX2 := (dragWindow_winStartX + dragWindow_mouseCurX) ; Apply this offset to the window position.
;   KDE_WinY2 := (dragWindow_winStartY + dragWindow_mouseCurY)
    dragWindow_winNewX  := dragWindow_winStartX + dragWindow_mouseDiffX
    dragWindow_winNewY  := dragWindow_winStartY + dragWindow_mouseDiffY
;   winMove, ahk_id %HWND_alt_LButton%,, %KDE_WinX2%,%KDE_WinY2% ; Move the window to the new position.
    winMove, ahk_id %HWND_alt_LButton%,, %dragWindow_winNewX%, %dragWindow_winnewY% ; Move the window to the new position.
} ; }}}
return ; }}}

!RButton:: ; {{{ alt + right mouse button.
if doubleAlt { ; {{{
    mouseGetPos,,, HWND_alt_RButton

  ; Toggle between maximized and restored state.
    winGet, isMaximized, MinMax,ahk_id %HWND_alt_RButton%
    if isMaximized {
       winRestore, ahk_id %HWND_alt_RButton%
    }
    else {
       winMaximize,ahk_id %HWND_alt_RButton%
    }
    doubleAlt := false
    return
} ; }}}

; Get the initial mouse position and window id, and
; abort if the window is maximized.
mouseGetPos, KDE_X1, KDE_Y1,HWND_alt_RButton
WinGet,KDE_Win,MinMax,ahk_id %HWND_alt_RButton%
If KDE_Win
    return
; Get the initial window position and size.
winGetPos,KDE_WinX1,KDE_WinY1,KDE_WinW,KDE_WinH,ahk_id %HWND_alt_RButton%
; Define the window region the mouse is currently in.
; The four regions are Up and Left, Up and Right, Down and Left, Down and Right.
if (KDE_X1 < KDE_WinX1 + KDE_WinW / 2)
    KDE_WinLeft := 1
else
    KDE_WinLeft := -1
if (KDE_Y1 < KDE_WinY1 + KDE_WinH / 2)
    KDE_WinUp := 1
else
    KDE_WinUp := -1
loop { ; {{{
    GetKeyState,KDE_Button,RButton,P ; Break if button has been released.
    If KDE_Button = U
        break
    MouseGetPos,KDE_X2,KDE_Y2 ; Get the current mouse position.
  ; Get the current window position and size.
    WinGetPos,KDE_WinX1,KDE_WinY1,KDE_WinW,KDE_WinH,ahk_id %HWND_alt_RButton%
    KDE_X2 -= KDE_X1 ; Obtain an offset from the initial mouse position.
    KDE_Y2 -= KDE_Y1
  ; Then, act according to the defined region.
    WinMove,ahk_id %HWND_alt_RButton%,, KDE_WinX1 + (KDE_WinLeft+1)/2*KDE_X2  ; X of resized window
                            , KDE_WinY1 +   (KDE_WinUp+1)/2*KDE_Y2  ; Y of resized window
                            , KDE_WinW  -     KDE_WinLeft  *KDE_X2  ; W of resized window
                            , KDE_WinH  -       KDE_WinUp  *KDE_Y2  ; H of resized window
    KDE_X1 := (KDE_X2 + KDE_X1) ; Reset the initial position for the next iteration.
    KDE_Y1 := (KDE_Y2 + KDE_Y1)
} ; }}}
return ; }}}

!MButton:: ; {{{ alt + middle mouse button.
; "Alt + MButton" may be simpler, but I
; like an extra measure of security for
; an operation like this.
if doubleAlt { ; {{{ alt + middle mouse button
    mouseGetPos,,, HWND_alt_MButton
    WinClose, ahk_id %HWND_alt_MButton%
    doubleAlt := false
    return
} ; }}}
return

~Alt:: ; {{{ Detect «double hits» on the alt key
  doubleAlt := A_PriorHotkey = "~Alt" AND A_TimeSincePriorHotkey < 400
  sleep 0
  keyWait alt  ; This prevents the keyboard's auto-repeat feature from interfering.
return ; }}}

; Dragging windows. }}} 
