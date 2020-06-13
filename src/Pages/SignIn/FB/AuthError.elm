module Pages.SignIn.FB.AuthError exposing
    ( Error
    , decoder
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
