#### 0.1.6-7

 * Fix a bug wherein the [`api_token` parameter is not respected](https://github.com/robertzk/hipchat/pull/15)
   during calls to `hipchat()`. (#15 @MarcinKosinski)
 * Fix a bug when calling `hipchat::hipchat` with multiple rooms or users.

#### 0.1.4

* Improves error handling around httr calls.
* Resolves issue #10.

#### 0.1.3

* The 401 error from an invalid HipChat token is now presented to the user.
