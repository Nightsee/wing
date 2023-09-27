bring cloud;
bring ex;
bring http;
bring "./assertions.w" as t;

let api = new cloud.Api(
  cors: true,
  corsOptions: {
    allowOrigin: ["winglang.io"],
    allowMethods: [cloud.HttpMethod.GET, cloud.HttpMethod.POST, cloud.HttpMethod.OPTIONS],
    allowHeaders: ["Content-Type", "Authorization", "X-Custom-Header"],
    allowCredentials: true,
    exposeHeaders: ["Content-Type"]
  }
);

api.get("/users", inflight (req) => {
  return {
    body: "hello world",
    status: 200
  };
});

test "GET /users has cors headers" {
  let response = http.get(api.url + "/users");

  let headers = response.headers;
  t.Assert.equalNum(response.status, 200);

  // GET cors headers are set
  t.Assert.equalStr(headers.get("access-control-allow-origin"), "winglang.io");
  t.Assert.equalStr(headers.get("access-control-allow-credentials"), "true");
  t.Assert.equalStr(headers.get("access-control-expose-headers"), "Content-Type");

  // OPTIONS cors headers are not set
  let ALLOW_HEADERS_DOES_NOT_EXIST_ERROR = "Object does not contain the key \"access-control-allow-headers\"";
  t.Assert.assertThrows(ALLOW_HEADERS_DOES_NOT_EXIST_ERROR, () => {
    headers.get("access-control-allow-headers");
  });

  let ALLOW_METHODS_DOES_NOT_EXIST_ERROR = "Object does not contain the key \"access-control-allow-methods\"";
  t.Assert.assertThrows(ALLOW_METHODS_DOES_NOT_EXIST_ERROR, () => {
    headers.get("access-control-allow-methods");
  });
}

test "OPTIONS /users has cors headers" {
  let response = http.fetch(api.url + "/users", {
    method: http.HttpMethod.OPTIONS
  });

  let headers = response.headers;

  t.Assert.equalNum(response.status, 204);

  // OPTIONS cors headers are set
  t.Assert.equalStr(headers.get("access-control-allow-methods"), "GET,POST,OPTIONS");
  t.Assert.equalStr(headers.get("access-control-allow-headers"), "Content-Type,Authorization,X-Custom-Header");
  t.Assert.equalStr(headers.get("access-control-allow-origin"), "winglang.io");

  // Other cors headers are not set
  let ALLOW_CREDENTIALS_DOES_NOT_EXIST_ERROR = "Object does not contain the key \"access-control-allow-credentials\"";
  t.Assert.assertThrows(ALLOW_CREDENTIALS_DOES_NOT_EXIST_ERROR, () => {
    headers.get("access-control-allow-credentials");
  });

  let EXPOSE_HEADERS_DOES_NOT_EXIST_ERROR = "Object does not contain the key \"access-control-expose-headers\"";
  t.Assert.assertThrows(EXPOSE_HEADERS_DOES_NOT_EXIST_ERROR, () => {
    headers.get("access-control-expose-headers");
  });
}

test "OPTIONS /users responds with proper headers for requested" {
  let response = http.fetch(api.url + "/users", {
    method: http.HttpMethod.OPTIONS,
    headers: {
      "Access-Control-Request-Method": "PUT",
      "Access-Control-Request-Headers": "Content-Type,Authorization,X-Custom-Foo",
    }
  });

  let headers = response.headers;
  t.Assert.equalNum(response.status, 204);
  t.Assert.equalStr(headers.get("access-control-allow-methods"), "GET,POST,OPTIONS");
  t.Assert.equalStr(headers.get("access-control-allow-headers"), "Content-Type,Authorization,X-Custom-Header");
  t.Assert.equalStr(headers.get("access-control-allow-origin"), "winglang.io");
}