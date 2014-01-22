#!/usr/bin/env ruby
require 'yaml'
require 'octokit'

# Expected config file format
#  work:
#     access_token: ACCESS_TOKEN
#     endpoints:
#         api: API_ENDPOINT
#         web: WEB_ENDPOINT
#     repo: REPO_NAME

github_config = YAML.load(File.open("config/github.yml"))

Octokit.configure do |c|
  c.api_endpoint = github_config['work']['endpoints']['api']
  c.web_endpoint = github_config['work']['endpoints']['web']
end

SCHEDULER.every '15m', :first_in => 0 do |job|
  repo = github_config['work']['repo']
  pull_requests = Array.new

  client = Octokit::Client.new :access_token => github_config['work']['access_token']
  user = client.user

  # username
  username = user.login

  # pull requests for repo
  client.pulls(repo).each do |pr|
    pull_requests.push({name: pr.title, link: pr[:_links].html.href})
  end
   
  send_event('github', {data: {title: "Github", username: username, pull_requests: pull_requests}})
end