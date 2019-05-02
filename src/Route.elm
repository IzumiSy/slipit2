module Route exposing (Routes(..), fromUrl, parser, pushUrl)

import Browser.Navigation as Nav
import Url
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
        [ Parser.map NewBookmark (s "new_bookmark" <?> Query.string "url" <?> Query.string "title" <?> Query.string "description")
        , Parser.map Bookmarks (s "bookmarks")
        , Parser.map SignIn (s "sign_in")
        , Parser.map SignUp (s "sign_up")
        , Parser.map ResetPassword (s "reset_password")
        ]


fromUrl : Url.Url -> Maybe Routes
fromUrl url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing } |> Parser.parse parser


pushUrl : Nav.Key -> String -> Cmd msg
pushUrl navKey path =
    Nav.pushUrl navKey ("#/" ++ path)
