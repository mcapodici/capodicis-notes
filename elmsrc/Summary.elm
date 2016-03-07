module Summary where

import Html exposing (Html, th, td, tr, text, table, div, a, h2, input, button)
import Html.Attributes exposing (href, id, type')
import Html.Events exposing (on, targetValue, targetChecked, onClick)
import Signal exposing (message)
import StartApp exposing (start)
import Effects exposing (..)
import ExtensionStorage
import Task exposing (Task)
import Shared exposing (encode, decode, trim)

type alias Model = { list : List (String, Shared.Model), showDone : Bool }

app : StartApp.App Model
app = start {
  init = ({ list = [], showDone = False }, retrieve),
  update = update,
  view = view,
  inputs = []
  }

type Action = None | Show (List (String, Shared.Model)) | ShowDoneChanged Bool | Refresh

for : List a -> (a -> b) -> List b
for = flip List.map

mapT : Task a b -> (b -> c) -> Task a c
mapT = flip Task.map

retrieve : Effects Action
retrieve = ExtensionStorage.getAll decode
  |> Task.toMaybe
  |> Task.map (Show << Maybe.withDefault [])
  |> Effects.task

update : Action -> Model -> (Model, Effects Action)
update action m = case action of
  None -> (m, Effects.none)
  Show list -> ({m | list = list}, Effects.none)
  ShowDoneChanged showDone -> ({m | showDone = showDone}, Effects.none)
  Refresh -> (m, retrieve)

view : Signal.Address Action -> Model -> Html
view address model = div [] [
  h2 [] [text "Your notes"],
  input [type' "checkbox", on "change" targetChecked (message address << ShowDoneChanged )] [],
  text "show done tasks",
  summaryTable address model,
  button [id "refresh", onClick address Refresh] [text "Refresh"]]

summaryTable : Signal.Address Action -> Model -> Html
summaryTable address model =
  let quickHead s = th [] [text s] in
  let headers = tr [] [ quickHead "Url", quickHead "Notes", quickHead "Done" ] in
  let rows = for (filteredList model) (\ (url, noteModel) ->
    tr [] [
      td [] [ a [ href url ] [text (trim 150 url)] ],
      td [] [ text noteModel.notes ],
      td [] [ text <| if noteModel.done then "Done" else "" ]
    ]
  ) in
  table [ id "summary" ] <| headers :: rows

filteredList : Model -> List (String, Shared.Model)
filteredList m =
  m.list |>
  List.filter (\i -> m.showDone || not (snd i).done) |>
  List.sortBy (\i -> (if (snd i).done then 1 else 0, fst i))
