module Popup where

import Html exposing (..)
import Html.Attributes exposing (style, type', value, checked, href, target, id)
import Html.Events exposing (on, targetValue, targetChecked)
import Signal exposing (message)
import StartApp exposing (start)
import Effects exposing (..)
import ExtensionStorage
import Task exposing (Task)
import Shared exposing (encode, decode, trim)

type alias Model = { entry : Shared.Model, url : String }

app : String -> StartApp.App Model
app url = start {
  init = ({ entry = { done = False, notes = "" }, url = url }, retrieve url),
  update = update,
  view = view,
  inputs = []
  }

type Action =
    UpdateNote String
  | UpdateDone Bool
  | Saved
  | DoNothing
  | Load Shared.Model

store : Model -> Effects Action
store =
  (\m -> ExtensionStorage.setItem m.url (encode m.entry)) >>
  Task.toMaybe >>
  Task.map (always Saved) >>
  Effects.task

retrieve : String -> Effects Action
retrieve url =
  (ExtensionStorage.getItem url decode) |>
  Task.toMaybe |>
  Task.map (\r -> case r of
    Nothing -> DoNothing
    Just m -> Load m) |>
  Effects.task

update : Action -> Model -> (Model, Effects Action)
update action m =
  let mentry = m.entry in
    case action of
      UpdateNote s -> let newModel = { m | entry = { mentry | notes = s }} in (newModel, store newModel)
      UpdateDone d -> let newModel = { m | entry = { mentry | done = d }} in (newModel, store newModel)
      Saved -> ( m, Effects.none)
      DoNothing -> ( m, Effects.none)
      Load e' -> ( { m | entry = e'} , Effects.none )

view : Signal.Address Action -> Model -> Html
view address model =
  let mentry = model.entry in
    div [] [
      text <| trim 150 model.url,
      h2 [] [text "General Notes"],
      textarea [
        value mentry.notes,
        on "input" targetValue (message address << UpdateNote),
        style [("width","100%"),("height","100px"),("resize","none")]] [],
      h2 [] [text "Completed?"],
      input [
        checked mentry.done,
        type' "checkbox",
        on "change" targetChecked (message address << UpdateDone)
        ] [],
      text "click here to mark this page as one you have dealt with.",
      div [ id "summaryLink"] [ a [ href "extension.html?mode=summary", target "_blank"] [text "See all of your notes"]]
    ]
