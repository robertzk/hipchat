context('match_method')

test_that('it correctly matches each uniquely determinable method', {
  ambiguous_routes <- unique(local({
    x <- rapply(http_methods, identity); x[duplicated(x)]
  }))

  for (method in names(http_methods)) {
    lapply(setdiff(http_methods[[method]], ambiguous_routes), function(route) {
      expect_identical(match_method(route), method, info =
        gettextf("The HTTP method chosen for %s must be %s",
                 sQuote(route), dQuote(method))
      )
    })
  }
})

