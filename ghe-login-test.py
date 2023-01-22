from github import Github
import sys

def GithubLogin(Host,Token):
    GitHubLoginObj = Github(base_url="https://{}/api/v3".format(Host), login_or_token=Token)
    try:
        print ("Logged-in User: {}".format(GitHubLoginObj.get_user().login))
        return True
    except:
        return False
    # return GitHubLoginObj

X = GithubLogin(sys.argv[1],sys.argv[2])
if X == False:
    print("Login failed!")