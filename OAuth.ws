code = var('request.query.code')
credentials = base64_encode(var('OAuth Client ID') + ':' + var('OAuth Client Secret'))
redirectURI = 'https://webhook.site/...'
state = var('request.query.state')

function completeOAuth(code, credentials, redirectURI){

    content = json_encode([
      'grant_type': 'authorization_code',
      'code': code, 
      'redirect_uri': redirectURI
    ])
    headers = ['Authorization: Basic ' + credentials, 'Content-Type: application/json']
    responseJSON = request('https://api.notion.com/v1/oauth/token', content, 'POST', headers, override = true)
    responseStatus = responseJSON['status']
    responseContent = json_decode(responseJSON['content'])
    
    if(responseStatus == 200){
      accessToken = responseContent['access_token']
      location = 'https://...?apikey=' + accessToken
      status = 'success'
      return ['status': status, 'location': location, 'access token': accessToken]
    } else {
      errorDescription = responseContent['error']
      error = url_encode('Error: ' + errorDescription)
      location = 'https://...?error=' + error
      status = 'error'
      return ['status': status, 'location': location]
    }
}

oAuthResult = completeOAuth(code, credentials, redirectURI)
locationHead = 'Location: ' + oAuthResult['location']
response = respond('', 200, [locationHead])
