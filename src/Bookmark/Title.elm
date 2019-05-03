module Bookmark.Title exposing (Title, empty, new, unwrap)


type Title
    = Title String


new : String -> Title
new value =
    Title value


unwrap : Title -> String
unwrap (Title value) =
    value


empty : Title
empty =
    Title ""
