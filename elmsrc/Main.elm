module Main where

import Html
import Popup
import Summary
import Effects exposing (..)
import Task
import StartApp

port modeString : String
port tabUrl : String

type Mode = ModePopup | ModeSummary

mode : Mode
mode =
  if modeString == "summary" then ModeSummary
  else ModePopup

popupApp : StartApp.App Popup.Model
popupApp = Popup.app tabUrl

summaryApp : StartApp.App Summary.Model
summaryApp = Summary.app

tasks' : Signal (Task.Task Never ())
tasks' = case mode of
  ModePopup -> popupApp.tasks
  ModeSummary -> summaryApp.tasks

main : Signal Html.Html
main = case mode of
  ModePopup -> popupApp.html
  ModeSummary -> summaryApp.html

-- todo make this DRYer
port tasks : Signal (Task.Task Never ())
port tasks = tasks'
