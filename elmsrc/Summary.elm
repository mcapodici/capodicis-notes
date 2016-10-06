module Summary exposing (..)

import ExtensionStorage
import Html exposing (Html, th, td, tr, text, table, div, a, h2, input, button)
import Html.App
import Html.Attributes exposing (href, id, type', checked, name, class)
import Html.Events exposing (onCheck, onClick)
import Popup
import Shared exposing (NoteModel, encode, decode, trim)
import Task exposing (Task)

type alias Model = {
  list : List NoteModel,
  showDone : Bool,
  popup : Maybe NoteModel }

initModel : Model
initModel = {
  list = [],
  showDone = True,
  popup = Nothing }

type Msg =
  None |
  Show (List NoteModel) |
  ShowDoneChanged Bool |
  Refresh |
  Edit String |
  PopupMsg Popup.Msg

for : List a -> (a -> b) -> List b
for = flip List.map

mapT : Task a b -> (b -> c) -> Task a c
mapT = flip Task.map

retrieve : Cmd Msg
retrieve = ExtensionStorage.getAll decode
  |> Task.perform (always <| Show []) (List.map (\(url, model) -> { model | url = url }) >> Show)

update : Msg -> Model -> (Model, Cmd Msg)
update action m = case action of
  None -> (m, Cmd.none)
  Show list -> ({m | list = list}, Cmd.none)
  ShowDoneChanged showDone -> ({m | showDone = showDone}, Cmd.none)
  Refresh -> (m, retrieve)
  Edit url -> ({m | popup = m.list |> List.filter (\m -> m.url == url) |> List.head }, Cmd.none)
  PopupMsg popupMsg ->
    case popupMsg of
      Popup.Close -> ({ m | popup = Nothing }, retrieve)
      _ ->
        case m.popup of
          Nothing -> (m, Cmd.none)
          Just popup -> let (newPopup, effects) = Popup.update popupMsg popup in
            ({m | popup = Just newPopup}, Cmd.map PopupMsg effects)

view : Model -> Html Msg
view model = div [] <| [
  h2 [] [text "Your notes"],
  input [type' "checkbox", checked model.showDone, onCheck ShowDoneChanged] [],
  text "show done tasks",
  summaryTable model,
  button [id "refresh", onClick Refresh] [text "Refresh"]]
  ++
  (case model.popup of
    Nothing -> []
    Just popup -> [div [id "summaryEdit"] [Html.App.map PopupMsg <| Popup.view Popup.SummaryEdit popup],
     div [class "black_overlay"] []])

summaryTable : Model -> Html Msg
summaryTable model =
  let quickHead s = th [] [text s] in
  let headers = tr [] <| List.map quickHead ["Url", "Notes", "Done", "Edit"] in
  let rows = for (filteredList model) (\ noteModel ->
    tr [] [
      td [] [ a [ href noteModel.url ] [text (trim 150 noteModel.url)] ],
      td [] [ text noteModel.notes ],
      td [] [ text <| if noteModel.done then "Done" else ""],
      td [] [ button [onClick (Edit noteModel.url)] [ text "Edit" ] ]
    ]
  )
  in
  table [ id "summary" ] <| headers :: rows

filteredList : Model -> List NoteModel
filteredList m =
  m.list |>
  List.filter (\n -> m.showDone || not n.done) |>
  List.sortBy (\n -> (if n.done then 1 else 0, n.url))
