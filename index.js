const firebase = require('firebase/app')
const { Elm } = require("./src/App.elm")
require('firebase/auth')
require('firebase/firestore')

firebase.initializeApp({
  apiKey: "AIzaSyDsWuPgIHrBITz_0LzktL6otbzx3VFSfiI",
  authDomain: "slipit2-97e5c.firebaseapp.com",
  databaseURL: "https://slipit2-97e5c.firebaseio.com",
  projectId: "slipit2-97e5c",
  storageBucket: "slipit2-97e5c.appspot.com",
  messagingSenderId: "371872021553"
});

const firestore = firebase.firestore();
firestore.settings({
  timestampsInSnapshots: true
})

const app = Elm.App.init({
  node: document.getElementById('main')
});

firebase.auth().onAuthStateChanged(fbUser => {
  if (fbUser) {
    const user = {
      uid: fbUser.uid,
      email: fbUser.email,
      displayName: fbUser.displayName
    }
    console.info("currentUser:", user)
    app.ports.logInSucceeded.send(user)
  } else {
    app.ports.signedOut.send(null)
  }
})

app.ports.signsOut.subscribe(() => {
  firebase.auth().signOut().catch(err => console.error(err))
})

app.ports.startLoggingIn.subscribe(login => {
  firebase.auth()
    .signInWithEmailAndPassword(login.email, login.password)
    .catch(err => {
      console.warn(err)
      app.ports.logInFailed.send(err)
    })
})