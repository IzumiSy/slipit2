module Pages.SignIn.Error exposing
    ( Error
    , decoder
    , init
    , message
    )

import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline


type alias Payload =
    { code : String
    , message : String
    }


type Error
    = None
    | FBAuth Payload
    | Other String


init : Error
init =
    None


message : Error -> Maybe String
message error =
    case error of
        None ->
            Nothing

        Other msg ->
            Just msg

        FBAuth payload ->
            Just payload.message


decoder : Decode.Decoder Error
decoder =
    Decode.oneOf [ fbauthDecoder, otherDecoder ]



-- interals


fbauthDecoder : Decode.Decoder Error
fbauthDecoder =
    Decode.succeed Payload
        |> Pipeline.required "code" Decode.string
        |> Pipeline.required "message" Decode.string
        |> Decode.andThen (Decode.succeed << FBAuth)


otherDecoder : Decode.Decoder Error
otherDecoder =
    Decode.andThen (Decode.succeed << Other) Decode.string
