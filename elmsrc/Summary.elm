module Summary where

import Html exposing (Html, th, td, tr, text, table, div, a, h2, input, button)
import Html.Attributes exposing (href, id, type', checked, name)
import Html.Events exposing (on, targetValue, targetChecked, onClick)
import Signal exposing (message, forwardTo)
import StartApp exposing (start)
import Effects exposing (..)
import ExtensionStorage
import Task exposing (Task)
import Shared exposing (NoteModel, encode, decode, trim)
import Popup

type alias Model = {
  list : List NoteModel,
  showDone : Bool,
  popup : Maybe NoteModel }

app : StartApp.App Model
app = start {
  init = ({
    list = [],
    showDone = False,
    popup = Nothing }
    , retrieve),
  update = update,
  view = view,
  inputs = []
  }

type Action =
  None |
  Show (List NoteModel) |
  ShowDoneChanged Bool |
  Refresh |
  Edit String |
  PopupAction Popup.Action

for : List a -> (a -> b) -> List b
for = flip List.map

mapT : Task a b -> (b -> c) -> Task a c
mapT = flip Task.map

retrieve : Effects Action
retrieve = ExtensionStorage.getAll decode
  |> Task.toMaybe
  |> Task.map (
    Maybe.withDefault [] >>
    List.map (\(url, model) -> { model | url = url }) >>
    Show
  )
  |> Effects.task

update : Action -> Model -> (Model, Effects Action)
update action m = case action of
  None -> (m, Effects.none)
  Show list -> ({m | list = list}, Effects.none)
  ShowDoneChanged showDone -> ({m | showDone = showDone}, Effects.none)
  Refresh -> (m, retrieve)
  Edit url -> ({m | popup = m.list |> List.filter (\m -> m.url == url) |> List.head }, Effects.none)
  PopupAction popupAction ->
    case m.popup of
      Nothing -> (m, Effects.none)
      Just popup -> let (newPopup, effects) = Popup.update popupAction popup in
        ({m | popup = Just newPopup}, Effects.map PopupAction effects)

view : Signal.Address Action -> Model -> Html
view address model = div [] <| [
  h2 [] [text "Your notes"],
  input [type' "checkbox", checked model.showDone, on "change" targetChecked (message address << ShowDoneChanged )] [],
  text "show done tasks",
  summaryTable address model,
  button [id "refresh", onClick address Refresh] [text "Refresh"]] ++
  (case model.popup of
    Nothing -> []
    Just popup -> [Popup.view (forwardTo address PopupAction) popup])

summaryTable : Signal.Address Action -> Model -> Html
summaryTable address model =
  let quickHead s = th [] [text s] in
  let headers = tr [] [ quickHead "Url", quickHead "Notes", quickHead "Edit" ] in
  let rows = for (filteredList model) (\ noteModel ->
    tr [] [
      td [] [ a [ href noteModel.url ] [text (trim 150 noteModel.url)] ],
      td [] [ text noteModel.notes ],
      td [] [ button [onClick address (Edit noteModel.url)] [ text "Edit" ] ]
    ]
  )
  in
  table [ id "summary" ] <| headers :: rows

filteredList : Model -> List NoteModel
filteredList m =
  m.list |>
  List.filter (\n -> m.showDone || not n.done) |>
  List.sortBy (\n -> (if n.done then 1 else 0, n.url))
