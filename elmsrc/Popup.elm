module Popup exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, type', value, checked, href, target, id, class, title)
import Html.Events exposing (..)
import ExtensionStorage
import Task exposing (Task)
import Shared exposing (NoteModel, encode, decode, trim)
import Html.App
import Basics exposing (..)

app : String -> Program Never
app url = Html.App.program {
  init = ({ done = False, notes = "", url = url }, retrieve url),
  update = update,
  view = view Regular,
  subscriptions = always Sub.none
  }

type Msg =
    UpdateNote String
  | UpdateDone Bool
  | Saved
  | DoNothing
  | Load NoteModel
  | Close

type Mode = Regular | SummaryEdit

store : NoteModel -> Cmd Msg
store m =
  ExtensionStorage.setItem m.url (encode m) |>
  Task.perform (always Saved) (always Saved)
-- Todo: ^^ Handle the case where the item cannot be saved

retrieve : String -> Cmd Msg
retrieve url =
  ExtensionStorage.getItem url decode |>
  Task.perform (always DoNothing) (\m -> Load {m | url = url})

update : Msg -> NoteModel -> (NoteModel, Cmd Msg)
update action m =
  case action of
    UpdateNote s -> let newModel = { m | notes = s } in (newModel, store newModel)
    UpdateDone d -> let newModel = { m | done = d } in (newModel, store newModel)
    Saved -> ( m, Cmd.none)
    DoNothing -> ( m, Cmd.none)
    Load newModel -> ( newModel , Cmd.none )
    Close -> (m, Cmd.none)

view : Mode -> NoteModel -> Html Msg
view mode model =
  div [ class "popupContainer" ] [
    h2 [] [text "General Notes"],
    textarea [
      value model.notes,
      onInput UpdateNote,
      style [("width","100%"),("height","100px"),("resize","none")]] [],
    h2 [] [text "Completed?"],
    input [
      checked model.done,
      type' "checkbox",
      onCheck UpdateDone
      ] [],
    text "click here to mark this page as one you have dealt with.",
    div [ id "summaryLink"] [
      case mode of
        Regular -> a [ href "extension.html?mode=summary", target "_blank"] [text "Your notes..."]
        SummaryEdit -> button [ onClick Close ] [ text "Close" ]]
  ]
