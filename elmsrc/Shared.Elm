module Shared exposing (..)

import Json.Encode
import Json.Decode exposing ((:=))
import String

type alias NoteModel =
  {
    url : String,
    done : Bool,
    notes : String
  }

encode : NoteModel -> Json.Encode.Value
encode m = Json.Encode.object [
  ("n", Json.Encode.string m.notes),
  ("d", Json.Encode.bool m.done)]

decode : Json.Decode.Decoder NoteModel
decode =
    Json.Decode.object2 (\n d -> { notes = n, done = d, url = ""})
      ("n" := Json.Decode.string)
      ("d" := Json.Decode.bool)


-- Utilities
trim : Int -> String -> String
trim maxLength s =
  if maxLength < 3 then "" else
  if String.length s <= maxLength then s else String.append (String.left (maxLength - 3) s) "..."
