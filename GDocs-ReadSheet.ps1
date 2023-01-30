
function Refresh-GoogleConnect(){

$ClientID = "XXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com";
$Secret = "XXXXXXXX";
$RedirectURI = "urn:ietf:wg:oauth:2.0:oob";
$RefreshToken = "XXXXXXXX";

$RefreshTokenParams = @{
client_id=$ClientID;
client_secret=$secret;
refresh_token=$refreshToken;
grant_type='refresh_token';
}

$RefreshedToken = Invoke-WebRequest -Uri "https://accounts.google.com/o/oauth2/token" -UseBasicParsing -Method POST -Body $refreshTokenParams | ConvertFrom-Json
$AccessToken = $refreshedToken.access_token
Return $AccessToken
}

function To-GoogleSpreadsheet(){
    $accessToken=Refresh-GoogleConnect
    $SPREADSHEET_ID = '1M693l0xekUfFFkLLZuKcfY1wPxeCvJ00CpAgXEe5qLg'
    $RANGE_NAME = 'Client'
    $patchheaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $patchheaders.Add("accept", 'application/json')
    $patchheaders.Add("Authorization", "Bearer $accessToken")
    $updateUri = "https://sheets.googleapis.com/v4/spreadsheets/"+$SPREADSHEET_ID+"/"
    #$updateUri = "https://sheets.googleapis.com/v4/spreadsheets/"+$SPREADSHEET_ID+"?&fields=sheets.properties"
    $testreturn=Invoke-RestMethod -Headers $patchheaders -Uri $updateUri -Method GET 
    Write-Output $testreturn
}

$test = Refresh-GoogleConnect
Write-Output "Google Token:"
Write-Output $test

$test2 = To-GoogleSpreadsheet
Write-Output "Sheet info:"
Write-Output $test2 | ConvertTo-Json