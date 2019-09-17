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

## Run
```bash
$ npm run lambda:start
```

## Deploy
This repository can be built automatically on Netlify from Github.
