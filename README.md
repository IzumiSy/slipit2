# Slip.it v2
The serverless replacement of [Slip.it](https://github.com/IzumiSy/slipit) aiming at deploying on Firebase suite

## Setup
```bash
$ npm install
```

Also you need to set your own env in `.env` file. This app uses Firestore as a database.
```bash
$ cp .env.sample .env
$ vi .env
```

## Run
```bash
$ npm start
```

## Build
```bash
$ npm run build
```

# Function

## Setup
Install dependencies
```bash
$ cd function/functions
$ npm install
```
After installing deps, you have to choose your project to run
```bash
$ npx firebase use [YourOwnProjectId]
```
Log into Firebase beforehand by `npx firebase login` to run function if you haven't.

## Run
```bash
$ cd function/functions
$ npm run serve
```

## Deploy
```bash
$ cd function/functions
$ npm run deploy
```
