port module Main exposing (..)

import Popup
import Summary
import Shared
import Html.App exposing (..)
import Html exposing (..)

port modeString : (String -> msg)-> Sub msg
port tabUrl : (String -> msg)-> Sub msg

type alias Flags =
  { tabUrl : String
  , modeString : String
  }

type Mode = ModePopup | ModeSummary

main : Program Flags
main = Html.App.programWithFlags {
  init = init,
  update = update,
  view = view,
  subscriptions = always Sub.none
  }

update : Msg -> Model -> (Model, Cmd Msg)
update action m =
  case (action, m) of
    (SummaryMsg msg, SummaryMode model) ->
      let (afterModel, cmd)  = Summary.update msg model in (SummaryMode afterModel, Cmd.map SummaryMsg cmd)
    (PopupMsg msg, PopupMode model) ->
      let (afterModel, cmd)  = Popup.update msg model in (PopupMode afterModel, Cmd.map PopupMsg cmd)
    _ -> (m, Cmd.none)


view : Model -> Html Msg
view m =
  case m of
    SummaryMode model -> Html.App.map SummaryMsg (Summary.view model)
    PopupMode model -> Html.App.map PopupMsg (Popup.view Popup.Regular model)

init : Flags -> (Model, Cmd Msg)
init flags =
  if flags.modeString == "summary" then
    (SummaryMode Summary.initModel, Cmd.none)
  else
    (PopupMode { done = False, notes = "", url = flags.tabUrl }, Cmd.map PopupMsg <| Popup.retrieve flags.tabUrl)

type Msg =
  SummaryMsg Summary.Msg |
  PopupMsg Popup.Msg

type Model =
  SummaryMode Summary.Model |
  PopupMode Shared.NoteModel
