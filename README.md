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
# only serving (build required)
$ npm run serve

# serve and compile
$ npm start
```

## Build
```bash
$ npm run build
```
`watch` command is also available.
