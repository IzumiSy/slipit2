module Pages.SignIn.FB.AuthError exposing
    ( Error
    , decoder
    , fold
    , init
    , new
    , toMessage
    )

import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline


type alias Payload =
    { code : String
    , message : String
    }


type Error
    = None
    | Some Payload


init : Error
init =
    None


new : Payload -> Error
new payload =
    Some payload


fold : a -> (Payload -> a) -> Error -> a
fold defaultValue cb error =
    case error of
        None ->
            defaultValue

        Some payload ->
            cb payload


toMessage : Error -> Maybe String
toMessage error =
    case error of
        None ->
            Nothing

        Some { message } ->
            Just message


decoder : Decode.Decoder Error
decoder =
    Decode.succeed
        (\code message -> new { code = code, message = message } |> Decode.succeed)
        |> Pipeline.required "code" Decode.string
        |> Pipeline.required "message" Decode.string
        |> Pipeline.resolve
