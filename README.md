
<!-- README.md is generated from README.Rmd. Please edit that file -->

# redditapi

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

Tools to interact with the reddit oauth API in R.

## Installation

You can install the development version of redditapi from github:

``` r
remotes::install_github("paulc91/redditapi")
```

## Setup reddit API application

To authenticate to use the oath API, you need your own application.

  - [Create a reddit user account](https://www.reddit.com/register/) (if
    you don’t already have one)
  - [Create API application](https://www.reddit.com/prefs/apps/)
      - give it a name
      - select ‘script’ (an application intended for a single developer)
      - add a description
      - provide a redirect URL (this won’t actually be used but is
        required so put something like <http://localhost:8080>)

Once created, note the application client\_id (below the app name) and
secret.

## Store credentials as R environment variables

You will need the client id, secret and name (agent) of your API
application, as well as your reddit username and password to
authenticate in R. It is a good idea to store these as environment
variables using a `.Renviron` file either in your home or project
directory.

You can generate or edit an `.Renviron` with the `usethis` package
function `usethis::edit_r_environ(scope = "user")`. Change the scope to
`"project"` to limit the environment variables to the current project
you are working in rather than all R sessions for your user.

Add the following to the `.Renviron` file, then save and restart the R
session.

    REDDIT_CLIENT_ID=your_client_id_here
    REDDIT_SECRET=your_secret_here
    REDDIT_AGENT=your_app_name_here
    REDDIT_USERNAME=your_username_here
    REDDIT_PASSWORD=your_password_here

## Example usage

### Load package and your API credentials

``` r
library(redditapi)
library(dplyr)

client_id <- Sys.getenv("REDDIT_CLIENT_ID") # the client id of your api application
secret <- Sys.getenv("REDDIT_SECRET") # the secret of your api application
agent <- Sys.getenv("REDDIT_AGENT") # the name of your api application
username <- Sys.getenv("REDDIT_USERNAME") # your personal reddit username
password <- Sys.getenv("REDDIT_PASSWORD") # your personal reddit password
```

### Retrieve a token

``` r
token <- get_reddit_token(
  agent = agent,
  client_id = client_id,
  secret = secret,
  username = username,
  password = password
)
```

### Retrieve post data from a subreddit

Because we have authenticated and are using the oauth api, you can
access private subreddits you are a member of.

  - `limit` is the number of posts to pull per request (max of 100)
  - `max_pages` is the max number of pages to attempt to pull per
    request

<!-- end list -->

``` r
# request the 200 most recent posts from the r/ambient music subreddit
posts <- get_reddit_posts(
  subreddit = "ambient", 
  token = token,
  agent = agent, 
  username = username, 
  limit = 100,
  max_pages = 2 
)
#> Page 1 returned
#> Page 2 returned
```

A data.frame for each page requested is returned inside a list. We can
then use `dplyr` to combine all pages together and extract the
information we are interested in:

``` r
posts_df <- 
  bind_rows(posts) %>% 
  as_tibble() %>% 
  select(created_utc, author, title, url, score, num_comments) %>% 
  mutate(created_utc = lubridate::as_datetime(created_utc))

posts_df
#> # A tibble: 200 x 6
#>    created_utc         author   title           url           score num_comments
#>    <dttm>              <chr>    <chr>           <chr>         <int>        <int>
#>  1 2020-10-10 15:17:57 thepart… "The Parttime … https://yout…     1            1
#>  2 2020-10-10 13:35:01 Illustr… "G’day, guys! … https://yout…     0            0
#>  3 2020-10-09 22:25:05 _perdom… "Nate Perdomo … https://yout…     6            1
#>  4 2020-10-09 21:16:57 dontsta… "dontstaylong … https://dont…     2            0
#>  5 2020-10-09 17:15:13 laikapr… "Logic Moon - … https://www.…     1            0
#>  6 2020-10-09 11:10:31 Aksetaka "Aksetaka - Th… https://akse…     1            1
#>  7 2020-10-09 09:26:32 BobChar… "Yarra | Ambie… https://yout…     2            1
#>  8 2020-10-08 21:01:13 Rolacruz "Rola Cruz - M… https://yout…     1            0
#>  9 2020-10-08 18:52:24 Hyloiri… "Anedonia Frag… https://hylo…     7            3
#> 10 2020-10-08 03:11:18 eternal… "\"For this pr… https://room…    12            0
#> # … with 190 more rows
```
