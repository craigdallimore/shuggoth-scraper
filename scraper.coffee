# Shuggoth scraper
# Uses casperJS
# -----------------------------------------------------------------------------

login     = 'http://witchhousemedia.hppodcraft.com/login/'
contents  = 'http://witchhousemedia.hppodcraft.com/membership-contents'
archives  = 'http://witchhousemedia.hppodcraft.com/archives/'
target    = ''
username  = ''
password  = ''

casper = require('casper').create()
fs     = require('fs')

casper.start login, ->

  @echo '=== SHUGGOTH SCRAPER 2 ===', 'INFO'
  @echo 'Page: ' + @getTitle()

  # Check casper arrived at the right page,
  # and log in.

  if /Login/.test @getTitle()
    @echo 'Filling login form...'
    @fill '#loginform'
      log: username
      pwd: password,
        true
    @loadInProgress = true

casper.thenOpen contents, ->

  @echo 'Page: ' + @getTitle()

  # Get the episode titles
  episodes = @evaluate getEpisodes

  # Remove links that are not episodes and links that have
  # been downloaded
  episodes = episodes.reverse().filter (episode) ->

    exists    = fs.exists target + episode.title + '.mp3'
    isEpisode = /^Episode/.test episode.title
    isEpisode and not exists

  titles = episodes.map (episode) ->
    episode.title

  @echo titles.length + ' titles found.'

  unless episodes.length is 0

    @echo 'Remaining titles:'
    @echo titles.join '\n'
    @echo 'Finding the download page...'

    casper.thenOpen episodes[0].link, ->
      @echo 'Page: ' + @getTitle()

      link = @evaluate getDownloadHref

      @echo 'Downloading ' + link + '...'
      @download link, target + episodes[0].title + '.mp3'

    casper.then ->
      @echo 'File scraped.'
      @exit()

  else
    @echo 'No episodes to download.'
    @exit()

# Kick it all off
# -----------------------------------------------------------------------------
casper.run()

# DOM Queries
# -----------------------------------------------------------------------------
getEpisodes = () ->

  # Get the title and href from each episode link
  as = jQuery '[href^="http://witchhousemedia.hppodcraft.com/archives/"]'
  jQuery.map as, (a) ->
    title: jQuery(a).text(),
    link:  jQuery(a).attr('href')

getDownloadHref = () ->

  # Get the path to the file
  jQuery('[title="Download"]').attr 'href'

#KAIZEN
