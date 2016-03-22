module Popup where

import Html exposing (..)
import Html.Attributes exposing (style, type', value, checked, href, target, id, class, title)
import Html.Events exposing (on, targetValue, targetChecked, onClick)
import Signal exposing (message)
import StartApp exposing (start)
import Effects exposing (..)
import ExtensionStorage
import Task exposing (Task)
import Shared exposing (NoteModel, encode, decode, trim)

app : String -> StartApp.App NoteModel
app url = start {
  init = ({ done = False, notes = "", url = url }, retrieve url),
  update = update,
  view = view Regular,
  inputs = []
  }

type Action =
    UpdateNote String
  | UpdateDone Bool
  | Saved
  | DoNothing
  | Load NoteModel
  | Close

type Mode = Regular | SummaryEdit

store : NoteModel -> Effects Action
store =
  (\m -> ExtensionStorage.setItem m.url (encode m)) >>
  Task.toMaybe >>
  Task.map (always Saved) >>
  Effects.task

retrieve : String -> Effects Action
retrieve url =
  (ExtensionStorage.getItem url decode) |>
  Task.toMaybe |>
  Task.map (\r -> case r of
    Nothing -> DoNothing
    Just m -> Load {m | url = url}) |>
  Effects.task

update : Action -> NoteModel -> (NoteModel, Effects Action)
update action m =
  case action of
    UpdateNote s -> let newModel = { m | notes = s } in (newModel, store newModel)
    UpdateDone d -> let newModel = { m | done = d } in (newModel, store newModel)
    Saved -> ( m, Effects.none)
    DoNothing -> ( m, Effects.none)
    Load newModel -> ( newModel , Effects.none )
    Close -> (m, Effects.none)
    
view : Mode -> Signal.Address Action -> NoteModel -> Html
view mode address model =
  div [ class "popupContainer" ] [
    h2 [] [text "General Notes"],
    textarea [
      value model.notes,
      on "input" targetValue (message address << UpdateNote),
      style [("width","100%"),("height","100px"),("resize","none")]] [],
    h2 [] [text "Completed?"],
    input [
      checked model.done,
      type' "checkbox",
      on "change" targetChecked (message address << UpdateDone)
      ] [],
    text "click here to mark this page as one you have dealt with.",
    div [ id "summaryLink"] [
      case mode of
        Regular -> a [ href "extension.html?mode=summary", target "_blank"] [text "Your notes..."]
        SummaryEdit -> button [ onClick address Close ] [ text "Close" ]]
  ]
