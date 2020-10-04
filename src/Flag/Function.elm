module Flag.Function exposing
    ( Error
    , Function
    , Result_
    , decode
    , empty
    , errorToString
    , run
    )

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Pages.NewBookmark.Description as Description exposing (Description)
import Pages.NewBookmark.Title as Title exposing (Title)
import Pages.NewBookmark.Url as Url exposing (Url)
import Task exposing (Task)


type Function
    = Available String
    | Unavailable


empty : Function
empty =
    Unavailable


type alias Result_ =
    { title : Title
    , description : Description
    }


run : Url -> Function -> Task Error Result_
run url function =
    case function of
        Available functionUrl ->
            Http.task
                { method = "get"
                , headers = []
                , body = Http.emptyBody
                , url = functionUrl ++ "?url=" ++ Url.unwrap url
                , resolver = runnerResolver
                , timeout = Nothing
                }

        Unavailable ->
            Task.fail UnavailableError


errorToString : Error -> String
errorToString err =
    case err of
        BadUrl ->
            "URL is invalid"

        Timeout ->
            "Request timeout"

        NetworkError ->
            "Network error"

        BadStatus code ->
            "HTTP error: " ++ String.fromInt code

        BadBody reason ->
            "Error: " ++ reason

        UnavailableError ->
            "URL fetching unavailable"



-- decoder


decode : Decode.Decoder Function
decode =
    Decode.andThen (Decode.succeed << Available) Decode.string



-- internals


type Error
    = BadUrl
    | Timeout
    | NetworkError
    | BadBody String
    | BadStatus Int
    | UnavailableError


runnerResolver : Http.Resolver Error Result_
runnerResolver =
    Http.stringResolver <|
        \response ->
            case response of
                Http.BadUrl_ _ ->
                    Err BadUrl

                Http.Timeout_ ->
                    Err Timeout

                Http.NetworkError_ ->
                    Err NetworkError

                Http.BadStatus_ metadata _ ->
                    Err <| BadStatus metadata.statusCode

                Http.GoodStatus_ _ body ->
                    body
                        |> Decode.decodeString
                            (Decode.succeed Result_
                                |> Pipeline.required "title" Title.decode
                                |> Pipeline.required "description" Description.decode
                            )
                        |> Result.mapError (BadBody << Decode.errorToString)
