const firebase = require("firebase/app");
const { Elm } = require("./App.elm");
const MD5 = require("blueimp-md5");
require("firebase/auth");
require("firebase/firestore");
require("siimple");
require("./index.scss");
require("./Toasty.css")
const logoImage = require("../logo_small.png");

firebase.initializeApp({
  apiKey: process.env.FB_API_KEY,
  authDomain: process.env.FB_AUTH_DOMAIN,
  databaseURL: process.env.FB_DB_URL,
  projectId: process.env.FB_PROJECT_ID,
});

const app = Elm.App.init({
  node: document.getElementById("main"),
  flags: {
    functionUrl: process.env.FUNCTION_URL,
    logoImagePath: logoImage,
    bookmarks: JSON.parse(localStorage.getItem("bookmarks"))
  }
});

const database = firebase.firestore();

const fetchAllBookmarks = userId =>
  database
    .collection("users")
    .doc(userId)
    .collection("bookmarks")
    .get();

firebase.auth().onAuthStateChanged(fbUser => {
  if (!fbUser) {
    app.ports.loggedOut.send(null);
    return;
  }

  fetchAllBookmarks(fbUser.uid)
    .then(({ docs }) => {
      const userData = {
        bookmarks: docs.map(doc =>
          Object.assign(doc.data(), {
            id: doc.id
          })
        ),
        currentUser: {
          uid: fbUser.uid,
          email: fbUser.email,
          displayName: fbUser.displayName
        }
      };
      app.ports.loggedIn.send(userData);
    })
    .catch(err => {
      console.error(err)
      app.ports.loggedOut.send(null);
    });
});

app.ports.logsOut.subscribe(() => {
  firebase
    .auth()
    .signOut()
    .catch(err => console.error(err));
});

app.ports.startsLoggingIn.subscribe(login => {
  firebase
    .auth()
    .signInWithEmailAndPassword(login.email, login.password)
    .catch(error => {
      app.ports.loggingInFailed.send(error);
    });
});

app.ports.createsNewBookmark.subscribe(([newBookmark, uid]) => {
  // 重複したURLを追加するのを許したくないのでMD5ハッシュに変換してIDとする
  // というのもスラッシュが含まれる文字列はdocのIDとして使えないらしいので
  const bookmarkId = MD5(newBookmark.url);

  database
    .collection("users")
    .doc(uid)
    .collection("bookmarks")
    .doc(bookmarkId)
    .set(newBookmark)
    .then(_ => 
      app.ports.creatingNewBookmarkSucceeded.send(
        Object.assign(newBookmark, { id: bookmarkId })
      )
    )
    .catch(fbError => {
      console.warn(fbError);
      app.ports.createNewBookmarkFailed.send({
        message: "Failed create new bookmark"
      });
    });
});

app.ports.fetchAllBookmarks.subscribe(() => {
  firebase.auth().onAuthStateChanged(user => {
    if (user) {
      fetchAllBookmarks(user.uid)
        .then(({ docs }) =>
          app.ports.allBookmarksFetched.send(
            docs.map(doc => Object.assign(doc.data(), { id: doc.id }))
          )
        )
        .catch(err => {
          // TODO: あとでつくる
        });
    }
  });
});

app.ports.persistToCacheInternal.subscribe(bookmarks => {
  localStorage.setItem("bookmarks", JSON.stringify(bookmarks))
})
