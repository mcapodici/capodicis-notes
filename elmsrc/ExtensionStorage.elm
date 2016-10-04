module ExtensionStorage exposing (..)

import Json.Encode exposing (Value)
import Json.Decode exposing (Decoder, decodeValue)
import Task exposing (Task, succeed, fail, andThen)
import Native.ExtensionStorage

getItemAsJson : String -> Task String Value
getItemAsJson = Native.ExtensionStorage.get

-- Do better error detection
getItem : String -> Decoder value -> Task String value
getItem key decoder =
  let decode value = case decodeValue decoder value of
    Ok v    -> succeed v
    Err err -> fail "Failed"
  in
    getItemAsJson key `andThen` decode

setItem : String -> Value -> Task String ()
setItem = Native.ExtensionStorage.setItem

getAllAsJson : Task String Value
getAllAsJson = Native.ExtensionStorage.getAll

getAll : Decoder value -> Task String (List (String, value))
getAll decoder =
  let decode value = case decodeValue (Json.Decode.keyValuePairs decoder) value of
    Ok v    -> succeed v
    Err err -> fail "Failed"
  in
    getAllAsJson `andThen` decode
