const HttpStatus = require("http-status-codes");
const urlValidator = require("valid-url");
const request = require("request");
const HtmlParser = require("node-html-parser");

withCorsAllowedOnDev = src => {
  // Allows CORS only for development environment

  const aca =
    process.env.NODE_ENV != "production"
      ? {
          headers: { "Access-Control-Allow-Origin": "*" }
        }
      : {};

  return Object.assign(src, aca);
};

exports.handler = (event, context, callback) => {
  const targetUrl = event.queryStringParameters.url;

  if (!targetUrl || !urlValidator.isUri(targetUrl)) {
    callback(
      null,
      withCorsAllowedOnDev({
        statusCode: HttpStatus.BAD_REQUEST,
        body: "Must be a valid URL"
      })
    );
    return;
  }

  request(targetUrl, (e, _, body) => {
    if (e) {
      callback(
        null,
        withCorsAllowedOnDev({
          statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
          body: "Internal error"
        })
      );
      return;
    }

    const result = { title: "", description: "" };

    try {
      const dom = HtmlParser.parse(body);

      const $title = dom.querySelector("title");
      const $description = dom
        .querySelectorAll("meta")
        .map(x => x.rawAttributes)
        .filter(x => x.name == "description");

      if ($title) result.title = $title.text;
      if ($description.length) result.description = $description[0].content;

      callback(
        null,
        withCorsAllowedOnDev({
          statusCode: HttpStatus.OK,
          body: JSON.stringify(result)
        })
      );
    } catch (err) {
      callback(
        null,
        withCorsAllowedOnDev({
          statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
          body: "Internal error"
        })
      );
    }
  });
};
