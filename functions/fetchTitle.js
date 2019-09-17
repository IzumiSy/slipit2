const HttpStatus = require('http-status-codes')
const urlValidator = require('valid-url')
const request = require('request')
const HtmlParser = require('node-html-parser')

exports.handler = (event, context, callback) => {
  const targetUrl = event.queryStringParameters.url

  if (!targetUrl || !urlValidator.isUri(targetUrl)) {
    callback(null, { 
      statusCode: HttpStatus.BAD_REQUEST, 
      body: "Must be a valid URL" 
    })
    return
  }

  request(targetUrl, (e, _, body) => {
    if (e) {
      callback(null, { 
        statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
        body: "Internal error"
      })
      return
    }

    const result = { title: "", description: "" }

    try {
      const dom = HtmlParser.parse(body)

      const $title = dom.querySelector('title')
      const $description = dom
        .querySelectorAll('meta')
        .map(x => x.rawAttributes)
        .filter(x => x.name == "description")

      if ($title) result.title = $title.text
      if ($description.length) result.description = $description[0].content

      callback(null, { 
        statusCode: HttpStatus.OK, 
        body: JSON.stringify(result) 
      })
    } catch (err) {
      callback(null, { 
        statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
        body: "Internal error"
      })
    }
  })
}
