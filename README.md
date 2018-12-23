# Slip.it v2
The serverless replacement of [Slip.it](https://github.com/IzumiSy/slipit)

## Setup
```bash
$ npm install
```
Also you need to set your own env in `.env` file
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
Install `firebase-tools` beforehand if you still haven't installed it, and do login after that.
```bash
$ npm install -g firebase-tools
$ firebase login
```
Install dependencies
```bash
$ cd function/functions
$ npm install
```

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