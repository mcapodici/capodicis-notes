module ExtensionStorage exposing (getItem, getAll, setItem)

import Json.Decode exposing (Decoder, decodeValue)
import Json.Encode exposing (Value)
import Native.ExtensionStorage
import Task exposing (Task, succeed, fail, andThen)

getItem : String -> Decoder value -> Task String value
getItem key decoder =
  let decode value = case decodeValue decoder value of
    Ok v    -> succeed v
    Err err -> fail <| "Failed decode: " ++ err
  in
    getItemAsJson key `andThen` decode

setItem : String -> Value -> Task String ()
setItem = Native.ExtensionStorage.setItem

getAll : Decoder value -> Task String (List (String, value))
getAll decoder =
  let decode value = case decodeValue (Json.Decode.keyValuePairs decoder) value of
    Ok v    -> succeed v
    Err err -> fail "Failed"
  in
    getAllAsJson `andThen` decode

getItemAsJson : String -> Task String Value
getItemAsJson = Native.ExtensionStorage.getItemAsJson

getAllAsJson : Task String Value
getAllAsJson = Native.ExtensionStorage.getAllAsJson
