module Pages.FB.AuthError exposing (Error, Payload, fold, init, toMessage)


type alias Payload =
    { code : String, message : String }


type Error
    = None
    | Some Payload


init : Error
init =
    None


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

        Some { code, message } ->
            Just message
