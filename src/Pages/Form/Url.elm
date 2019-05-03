module Pages.Form.Url exposing (Url, new, unwrap)

import Url


type Url
    = Valid Url.Url
    | Invalid


new : Maybe String -> Url
new value =
    value
        |> Maybe.withDefault ""
        |> Url.fromString
        |> Maybe.map Valid
        |> Maybe.withDefault Invalid


unwrap : Url -> String
unwrap url =
    case url of
        Valid url_ ->
            url_ |> Url.toString

        Invalid ->
            ""
