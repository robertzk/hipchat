hipchat_api_url <- 'https://api.hipchat.com/v2'

# Based off https://www.hipchat.com/docs/apiv2/
http_methods <- list(
  GET = c('addon/*/installable/*', 'capabilities', 'emoticon/*',
          'emoticon', 'oauth/token/*', 'room', 'room/*', 'room/*/history',
          'room/*/history/*', 'room/*/history/latest', 'room/*/member',
          'room/*/participant', 'room/*/statistics', 'room/*/webhook',
          'room/*/webhook/*', 'user/*', 'user', 'user/*/history/*',
          'user/*/history/latest'),
  POST = c('oauth/token', 'room', 'room/*/invite/*', 'room/*/message',
           'room/*/notification', 'room/*/reply', 'room/*/share/file',
           'room/*/share/link', 'room/*/webhook', 'user', 'user/*/message',
           'user/*/share/file', 'user/*/share/link'),
  PUT = c('room/*', 'room/*/member/*', 'room/*/topic', 
          'user/*/photo', 'user/*'),
  DELETE = c('oauth/token/*', 'room/*', 'room/*/member/*', 'room/*/webhook/*',
             'user/*', 'user/*/photo')
)

