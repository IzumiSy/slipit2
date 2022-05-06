const HttpStatus = require("http-status-codes");
const UrlValidator = require("valid-url");
const HtmlParser = require("node-html-parser");
const request = require("request");
const functions = require("firebase-functions");

exports.fetchTitle = functions.https.onRequest((req, resp) => {
  const targetUrl = req.query.url;
  if (!targetUrl || !UrlValidator.isUri(targetUrl)) {
    resp.status(HttpStatus.BAD_REQUEST).send("Not a valid URL given")
    return;
  }

  request(targetUrl, (e, _, body) => {
    if (e) {
      resp.status(HttpStatus.INTERNAL_SERVER_ERROR).send("Internal server error")
      return;
    }

    const result = {
      title: "(no title)",
      description: "(no description)",
    };

    try {
      const dom = HtmlParser.parse(body);

      const $title = dom.querySelector("title");
      const $description = dom
        .querySelectorAll("meta")
        .map((x) => x.rawAttributes)
        .filter((x) => x.name == "description");

      if ($title) {
        result.title = $title.text;
      }

      if ($description.length) {
        result.description = $description[0].content;
      }

      resp.status(HttpStatus.OK).send(result)
    } catch (err) {
      resp.status(HttpStatus.INTERNAL_SERVER_ERROR).send("Internal server error")
    }
  });
});
