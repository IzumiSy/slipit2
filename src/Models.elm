module Models exposing
    ( BookmarkCreatingError
    , BookmarksFetchingError
    , NewBookmarkForm
    , UrlFetcherResult
    , UrlFetchingError(..)
    , UrlFetchingStatus(..)
    , emptyBookmark
    , setDescription
    , setTitle
    , setUrl
    , unwrapUrlFetchingError
    )

import Browser.Navigation as Nav
import Route
import Url



{-
   type alias InitialUserData =
       { bookmarks : List Bookmark
       , currentUser : User
       }


   fromInitialUserData : InitialUserData -> UserData
   fromInitialUserData initialUserData =
       { bookmarks = initialUserData.bookmarks
       , currentUser = initialUserData.currentUser
       , newBookmark = emptyBookmark
       , newBookmarkCreatingStatus = NewBookmarkNotCreated
       , urlFetchingStatus = UrlNotFetched
       }
-}


type alias BookmarksFetchingError =
    { message : String
    }


type alias UrlFetcherResult =
    { title : String
    , description : String
    }


type UrlFetchingStatus
    = UrlNotFetched
    | UrlFetching
    | UrlFetched (Result UrlFetchingError UrlFetcherResult)


type UrlFetchingError
    = UrlFetchingError String


unwrapUrlFetchingError : UrlFetchingError -> String
unwrapUrlFetchingError (UrlFetchingError msg) =
    msg


type alias NewBookmarkForm =
    { url : String
    , title : String
    , description : String
    }


emptyBookmark =
    { url = "", title = "", description = "" }


setUrl v bookmark =
    { bookmark | url = v }


setTitle v bookmark =
    { bookmark | title = v }


setDescription v bookmark =
    { bookmark | description = v }



{-
   type NewBookmarkCreatingStatus
       = NewBookmarkNotCreated
       | NewBookmarkCreating
       | NewBookmarkCreated (Result BookmarkCreatingError Bookmark)
-}


type alias BookmarkCreatingError =
    { message : String
    }
