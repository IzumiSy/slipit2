const firebase = require('firebase/app')
const { Elm } = require("./src/App.elm")
require('firebase/auth')
require('firebase/firestore')

firebase.initializeApp({
  apiKey: process.env.FB_API_KEY,
  authDomain: process.env.FB_AUTH_DOMAIN,
  databaseURL: process.env.FB_DB_URL,
  projectId: process.env.FB_PROJECT_ID,
  storageBucket: process.env.FB_STORAGE_BUCKET,
  messagingSenderId: process.env.FB_MSG_SENDER_ID
});

const firestore = firebase.firestore();
firestore.settings({
  timestampsInSnapshots: true
})

const app = Elm.App.init({
  node: document.getElementById('main'),
  flags: {
    functionUrl: process.env.FUNCTION_URL
  }
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

// TODO: あとでつくる
app.ports.createsNewBookmark.subscribe(newBookmark => {
  console.log(newBookmark)
})