
import requests
def send_simple_message():
    return requests.post(
        "https://api.mailgun.net/v3/XXXXXXXXXXXXXXX/messages",
        auth=("api", "key-XXXXXXXXXXXXXXXXXXXX"),
        data={"from": "Excited User <postmaster@ZZZ.ie>",
              "to": ["U@test.com"],
              "subject": "Hi",
              "text": "PoC"}).text

print(send_simple_message())