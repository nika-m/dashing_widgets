require 'net/http'
require 'json'

class Reddit
  def initialize()
    # add your desired subreddits here
    @subreddits = {
      '/r/programming' => 'http://www.reddit.com/r/programming.json',
      '/r/ruby' => 'http://www.reddit.com/r/ruby.json',
      '/r/russia' => 'http://www.reddit.com/r/russia.json',
    }

    # the limit per subreddit to grab
    @maxcount = 5
  end

  def getTopPostsPerSubreddit()
    posts = [];

    @subreddits.each do |subreddit, url|
      response = JSON.parse(Net::HTTP.get(URI(url)))

      if !response
        puts "reddit communication error for #{@subreddit} (shrug)"
      else
        items = []

        for i in 0..@maxcount
          title = response['data']['children'][i]['data']['title']
         
          items.push({
            title: title,
            score: response['data']['children'][i]['data']['score'],
            comments: response['data']['children'][i]['data']['num_comments'],
            permalink: "http://www.reddit.com" + response['data']['children'][i]['data']['permalink'],
            url: response['data']['children'][i]['data']['url']
          })
        end

        posts.push({ label: 'Top Posts in "' + subreddit + '"', items: items })
      end
    end

    posts
  end
end

@Reddit = Reddit.new();

SCHEDULER.every '2m', :first_in => 0 do |job|
  posts = @Reddit.getTopPostsPerSubreddit
  send_event('reddit', { :posts => posts })
end