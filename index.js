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

app.ports.startLoggingIn.subscribe(login => {
  firebase.auth()
    .signInWithEmailAndPassword(login.email, login.password)
    .then(({ user }) => {
      console.log(user)
      app.ports.logInSucceeded.send({
        uid: user.uid,
        email: user.email,
        displayName: user.displayName
      })
    })
    .catch(err => {
      console.warn(err)
      app.ports.logInFailed.send(err)
    })
})