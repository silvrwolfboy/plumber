context("Paths")

test_that("paths are properly converted", {
  varRegex <- "([^/]+)"
  p <- createPathRegex("/car/")
  expect_equal(p$names, character())
  expect_equal(p$regex, "^/car/$")

  p <- createPathRegex("/car/<id>")
  expect_equal(p$names, "id")
  expect_equal(p$regex, paste0("^/car/", varRegex, "$"))

  p <- createPathRegex("/car/<id>/sell")
  expect_equal(p$names, "id")
  expect_equal(p$regex, paste0("^/car/", varRegex, "/sell$"))

  p <- createPathRegex("/car/<id>/sell/<price>")
  expect_equal(p$names, c("id", "price"))
  expect_equal(p$regex, paste0("^/car/", varRegex, "/sell/", varRegex, "$"))
})

test_that("variables are typed", {
  p <- createPathRegex("/car/<id:int>")
  expect_equal(p$names, "id")
  expect_equal(p$regex, paste0("^/car/", "(-?\\d+)", "$"))

  p <- createPathRegex("/car/<id:double>")
  expect_equal(p$names, "id")
  expect_equal(p$regex, paste0("^/car/", "(-?\\d*\\.?\\d+)", "$"))

  p <- createPathRegex("/car/<id:numeric>")
  expect_equal(p$names, "id")
  expect_equal(p$regex, paste0("^/car/", "(-?\\d*\\.?\\d+)", "$"))

  p <- createPathRegex("/car/<id:bool>")
  expect_equal(p$names, "id")
  expect_equal(p$regex, paste0("^/car/", "([01tfTF]|true|false|TRUE|FALSE)", "$"))

  p <- createPathRegex("/car/<id:logical>")
  expect_equal(p$names, "id")
  expect_equal(p$regex, paste0("^/car/", "([01tfTF]|true|false|TRUE|FALSE)", "$"))
  p <- createPathRegex("/car/<id:chr>")
  expect_equal(p$names, "id")
  expect_equal(p$regex, paste0("^/car/", "([^/]+)", "$"))



})

test_that("path regex's are created properly", {
  expect_equivalent(extractPathParams(createPathRegex("/car/"), "/car/"),  list())
  expect_equal(extractPathParams(createPathRegex("/car/<id>"), "/car/15"), list(id="15") )
  expect_equal(extractPathParams(createPathRegex("/car/<id>/sell"), "/car/12/sell"), list(id="12") )
  expect_equal(extractPathParams(createPathRegex("/car/<id>/sell/<price>"), "/car/15/sell/$15,000"), list(id="15", price="$15,000"))
})

test_that("integration of path parsing works", {
  r <- plumber$new(test_path("files/path-params.R"))

  expect_equal(r$route(make_req("GET", "/car/13"), PlumberResponse$new()), "13")
  expect_equal(r$route(make_req("GET", "/car/int/13"), PlumberResponse$new()), 13)
  expect_equal(r$route(make_req("GET", "/car/int/-13"), PlumberResponse$new()), -13)
  expect_equal(r$route(make_req("GET", "/car/15/sell/$15,000"), PlumberResponse$new()), list(id="15", price="$15,000"))
  expect_equal(r$route(make_req("POST", "/car/13"), PlumberResponse$new()), "13")
  expect_equal(r$route(make_req("GET", "/car/15/buy/$15,000"), PlumberResponse$new()),
               list(id=15, price="$15,000"))
  expect_equal(r$route(make_req("GET", "/car/15/buy/$15,000.99"), PlumberResponse$new()),
               list(id=15, price="$15,000.99"))
  expect_equal(r$route(make_req("GET", "/car/ratio/1.5"), PlumberResponse$new()), 1.5)
  expect_equal(r$route(make_req("GET", "/car/ratio/-1.5"), PlumberResponse$new()), -1.5)
  expect_equal(r$route(make_req("GET", "/car/ratio/-.5"), PlumberResponse$new()), -.5)
  expect_equal(r$route(make_req("GET", "/car/ratio/.5"), PlumberResponse$new()), .5)
  expect_equal(r$route(make_req("GET", "/car/ratio/a"), PlumberResponse$new()),
               list(error = "404 - Resource Not Found"))
  expect_equal(r$route(make_req("GET", "/car/ratio/"), PlumberResponse$new()),
               list(error = "404 - Resource Not Found"))
  expect_equal(r$route(make_req("GET", "/car/ratio/."), PlumberResponse$new()),
               list(error = "404 - Resource Not Found"))
  expect_equal(r$route(make_req("GET", "/car/sold/true"), PlumberResponse$new()), TRUE)
})
