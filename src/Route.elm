module Route exposing (Routes(..), fromUrl, load, parser, replaceUrl)

import Browser.Navigation as Nav
import Url
import Url.Builder as UrlBuilder
import Url.Parser as Parser exposing ((</>), (<?>), Parser, oneOf, s)
import Url.Parser.Query as Query


type Routes
    = Bookmarks
    | NewBookmark (Maybe String) (Maybe String) (Maybe String)
    | SignIn
    | SignUp
    | ResetPassword


parser : Parser (Routes -> a) a
parser =
    oneOf
        [ Parser.map Bookmarks Parser.top
        , Parser.map NewBookmark (s "new_bookmark" <?> Query.string "url" <?> Query.string "title" <?> Query.string "description")
        , Parser.map Bookmarks (s "bookmarks")
        , Parser.map SignIn (s "sign_in")
        , Parser.map SignUp (s "sign_up")
        , Parser.map ResetPassword (s "reset_password")
        ]


fromUrl : Url.Url -> Maybe Routes
fromUrl url =
    url |> Parser.parse parser


replaceUrl : Nav.Key -> Routes -> Cmd msg
replaceUrl navKey route =
    Nav.replaceUrl navKey (routeToString route)


load : Routes -> Cmd msg
load route =
    route |> routeToString |> Nav.load


routeToString : Routes -> String
routeToString page =
    let
        ( paths, queries ) =
            case page of
                Bookmarks ->
                    ( [ "bookmarks" ], [] )

                NewBookmark maybeUrl maybeTitle maybeDesc ->
                    ( [ "new_bookmark" ]
                    , let
                        url =
                            maybeUrl
                                |> Maybe.map (\url_ -> [ UrlBuilder.string "url" url_ ])
                                |> Maybe.withDefault []

                        title =
                            maybeTitle
                                |> Maybe.map (\title_ -> [ UrlBuilder.string "title" title_ ])
                                |> Maybe.withDefault []

                        description =
                            maybeDesc
                                |> Maybe.map (\desc_ -> [ UrlBuilder.string "description" desc_ ])
                                |> Maybe.withDefault []
                      in
                      url ++ title ++ description
                    )

                SignIn ->
                    ( [ "sign_in" ], [] )

                SignUp ->
                    ( [ "sign_up" ], [] )

                ResetPassword ->
                    ( [ "reset_password" ], [] )
    in
    UrlBuilder.absolute paths queries
