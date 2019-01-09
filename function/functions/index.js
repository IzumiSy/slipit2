const HttpStatus = require('http-status-codes')
const { JSDOM } = require('jsdom')
const functions = require('firebase-functions');
const urlValidator = require('valid-url')
const request = require('request')
const cors = require('cors')

// TODO: CORS設定はちゃんとやる
exports.fetchTitle = functions.https.onRequest((req, res) => {
  cors({ origin: true })(req, res, () => {
    const targetUrl = req.query.url

    console.info('Fetch:', req.query.url)

    if (!targetUrl || !urlValidator.isUri(targetUrl)) {
      res.status(HttpStatus.BAD_REQUEST).end()
    }

    request(targetUrl, (e, _, body) => {
      if (e) {
        console.error(e)
        res.status(HttpStatus.INTERNAL_SERVER_ERROR).end()
      }

      try {
        const dom = new JSDOM(body)
        const $title = dom.window.document.querySelector('title')
        const $description = dom.window.document.querySelector('meta[name="description"]')
        const result = { title: "", description: "" }

        if ($title) result.title = $title.textContent
        if ($description) result.description = $description.content

        res.send(result)
      } catch (err) {
        console.error(err)
        res.status(HttpStatus.INTERNAL_SERVER_ERROR).end()
      }
    })
  })
});
