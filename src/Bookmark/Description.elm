module Bookmark.Description exposing (Description, empty, new, unwrap)


type Description
    = Description String


new : String -> Description
new value =
    Description value


unwrap : Description -> String
unwrap (Description value) =
    value


empty : Description
empty =
    Description ""
