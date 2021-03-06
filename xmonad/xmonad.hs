import XMonad
import System.IO
import XMonad.Config.Desktop
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import Graphics.X11.ExtraTypes.XF86
import XMonad.Util.EZConfig
import XMonad.Util.Paste
import XMonad.Util.Run(spawnPipe)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Actions.CycleWS

baseConfig = desktopConfig

myKeysP =
  [
    ("<XF86MonBrightnessUp>",   spawn "xbacklight +10"),
    ("<XF86MonBrightnessDown>", spawn "xbacklight -10"),
    ("<XF86AudioMute>",        spawn "amixer set Master toggle"),
    ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5+"),
    ("<XF86AudioLowerVolume>", spawn "amixer set Master 5-"),
    ("<Insert>", pasteSelection),
    ("M-]", nextWS),
    ("M-[" , prevWS),
    ("M-s", spawn "scrot")
   ]

myLayoutHook = avoidStruts $ smartBorders (layoutHook baseConfig)

myManageHook = composeAll
  [ className =? "Steam"    --> doFloat
  , className =? "albert"   --> doFloat]

myWorkspaces :: [String]
myWorkspaces =
  [
    "1:general",
    "2:web",
    "3:code",
    "4:code",
    "5:irc",
    "6:data",
    "7:torrent",
    "8:dev",
    "9:music"
  ]

xmobarTitleColor :: String
xmobarTitleColor = "#F44336"

xmobarCurrentWorkspaceColor :: String
xmobarCurrentWorkspaceColor = "#4CAF50"

xmobarHiddenColor :: String
xmobarHiddenColor = "#EEEEEE"

main :: IO()
main = do
  xmbproc <- spawnPipe "xmobar ~/.xmobarrc-bottom"
  xmonad $ baseConfig {
    terminal = "urxvt"
  , modMask = mod1Mask
  , borderWidth = 3
  , normalBorderColor = "#313131"
  , focusedBorderColor = "#3F51B5"
  , workspaces = myWorkspaces
  , handleEventHook = docksEventHook <+> handleEventHook baseConfig
  , layoutHook = smartSpacing 10 $ myLayoutHook
  , manageHook = manageHook baseConfig <+> manageDocks
  , logHook = dynamicLogWithPP $ xmobarPP {
      ppOutput = hPutStrLn xmbproc
      , ppTitle = xmobarColor xmobarTitleColor "" . shorten 100
      , ppCurrent = xmobarColor xmobarCurrentWorkspaceColor ""
      , ppHidden = xmobarColor xmobarHiddenColor ""
      , ppHiddenNoWindows = xmobarColor xmobarHiddenColor ""
      , ppOrder = \(ws:_:t:_) -> [ws,t]
      , ppSep = "    "
      , ppWsSep = "  "
      }
  } `additionalKeysP` myKeysP
