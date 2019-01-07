# Slip.it v2
The serverless replacement of [Slip.it](https://github.com/IzumiSy/slipit) aiming at deploying on Firebase suite

## Setup
```bash
$ npm install
```
After installing deps, you have to log into Firebase
```bash
$ npx firebase login
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
Install dependencies
```bash
$ cd function/functions
$ npm install
```
After installing deps, you have to choose your project to run
```bash
$ npx firebase use [YourOwnProjectId]
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
