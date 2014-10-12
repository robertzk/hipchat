context('match_method')

test_that('it correctly matches each route', {
  for (method in names(http_methods)) {
    lapply(http_methods[[method]], function(route) {
      expect_true(method %in% match_method(route),
        gettextf("The HTTP method chosen for %s must be %s",
                 sQuote(route), dQuote(method))
      )
    })
  }
})



