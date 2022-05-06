import { Elm } from "./App.elm";
import MD5 from "blueimp-md5";
import firebase from "firebase/app";
import "firebase/auth";
import "firebase/firestore";
import "siimple";
import logoImage from "../logo_small.png";
import "./index.scss";
import "./Toasty.css";

fetch("/__/firebase/init.json").then(async (resp) => {
  firebase.initializeApp(await resp.json());

  const app = Elm.App.init({
    node: document.getElementById("main"),
    flags: {
      functionUrl: process.env.FUNCTION_URL,
      logoImagePath: logoImage,
      bookmarks: JSON.parse(localStorage.getItem("bookmarks")),
    },
  });
  const database = firebase.firestore();

  const fetchAllBookmarks = (userId) =>
    database.collection("users").doc(userId).collection("bookmarks").get();

  firebase.auth().onAuthStateChanged((fbUser) => {
    if (!fbUser) {
      app.ports.loggedOut.send(null);
      return;
    }

    fetchAllBookmarks(fbUser.uid)
      .then(({ docs }) => {
        const userData = {
          bookmarks: docs.map((doc) =>
            Object.assign(doc.data(), {
              id: doc.id,
            })
          ),
          currentUser: {
            uid: fbUser.uid,
            email: fbUser.email,
            displayName: fbUser.displayName,
          },
        };
        app.ports.loggedIn.send(userData);
      })
      .catch((err) => {
        console.error(err);
        app.ports.loggedOut.send(null);
      });
  });

  app.ports.logsOut.subscribe(() => {
    firebase
      .auth()
      .signOut()
      .catch((err) => console.error(err));
  });

  app.ports.startsLoggingIn.subscribe((login) => {
    firebase
      .auth()
      .signInWithEmailAndPassword(login.email, login.password)
      .catch((error) => {
        app.ports.loggingInFailed.send(error);
      });
  });

  app.ports.createsNewBookmark.subscribe(({ bookmark, uid }) => {
    // 重複したURLを追加するのを許したくないのでMD5ハッシュに変換してIDとする
    // というのもスラッシュが含まれる文字列はdocのIDとして使えないらしいので
    const bookmarkId = MD5(bookmark.url);

    database
      .collection("users")
      .doc(uid)
      .collection("bookmarks")
      .doc(bookmarkId)
      .set(bookmark)
      .then((_) =>
        app.ports.creatingNewBookmarkSucceeded.send(
          Object.assign(bookmark, { id: bookmarkId })
        )
      )
      .catch((fbError) => {
        console.warn(fbError);
        app.ports.createNewBookmarkFailed.send({
          message: "Failed create new bookmark",
        });
      });
  });

  app.ports.fetchAllBookmarks.subscribe(() => {
    firebase.auth().onAuthStateChanged((user) => {
      if (user) {
        fetchAllBookmarks(user.uid)
          .then(({ docs }) =>
            app.ports.allBookmarksFetched.send(
              docs.map((doc) => Object.assign(doc.data(), { id: doc.id }))
            )
          )
          .catch((err) => {
            // TODO: あとでつくる
          });
      }
    });
  });

  app.ports.persistToCacheInternal.subscribe((bookmarks) => {
    localStorage.setItem("bookmarks", JSON.stringify(bookmarks));
  });
});
