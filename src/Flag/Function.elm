module Flag.Function exposing
    ( Function
    , Result_
    , decode
    , empty
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


run : Url -> Function -> Task Http.Error Result_
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
            -- TODO: Service Unavailable的なエラーにしたい
            Task.fail Http.NetworkError



-- decoder


decode : Decode.Decoder Function
decode =
    Decode.andThen (Decode.succeed << Available) Decode.string



-- internals


runnerResolver : Http.Resolver Http.Error Result_
runnerResolver =
    Http.stringResolver <|
        \response ->
            case response of
                Http.BadUrl_ url_ ->
                    Err (Http.BadUrl url_)

                Http.Timeout_ ->
                    Err Http.Timeout

                Http.NetworkError_ ->
                    Err Http.NetworkError

                Http.BadStatus_ metadata _ ->
                    Err (Http.BadStatus metadata.statusCode)

                Http.GoodStatus_ _ body ->
                    body
                        |> Decode.decodeString
                            (Decode.succeed Result_
                                |> Pipeline.required "title" Title.decode
                                |> Pipeline.required "description" Description.decode
                            )
                        |> Result.mapError
                            (\err -> Http.BadBody (Decode.errorToString err))
