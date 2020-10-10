#' Retrieve post data from a subreddit
#'
#' Uses the OAuth API URL https://oauth.reddit.com/r/subreddit/new.json
#'
#' @param subreddit name of subreddit
#' @param token oauth token obtained using [`get_reddit_token`]
#' @param agent name of your reddit api application
#' @param username your reddit username
#' @param limit the number of posts to return per page (100 maximum)
#' @param max_pages the maximum number of pages return
#'
#' @return dataframe containing data for posts in the subreddit
#' @export
get_reddit_posts <- function(subreddit, token, agent, username, limit = 100, max_pages = 10) {

  if (limit > 100 | limit < 1) {
    stop("Limit must be between 1 and 100", call. = FALSE)
  }

  base_url <- paste0("https://oauth.reddit.com/r/", subreddit, "/new.json?limit=", limit)
  headers <- httr::add_headers(
    "Authorization" = paste("bearer", token),
    "User-Agent" = paste(agent, "by", username)
  )

  resp <- httr::GET(url = base_url, headers)

  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  content <- jsonlite::fromJSON(httr::content(resp, as = "text"))

  if (!is.null(content$error)) {
    stop(
      sprintf(
        "Reddit GET request failed [%s]: %s",
        content$error,
        content$message
      ),
      call. = FALSE
    )
  }

  if (is.null(content$data$children$data)) {
    stop("No data found for that subreddit", call. = FALSE)
  }

  post_data <- list("page_1" = content$data$children$data)

  # request more pages ====================================
  page <- 1
  message(paste("Page", page, "returned"))

  before <- content$data$before
  if(!is.null(before)) before <- paste0("&before=", before)

  after <- content$data$after
  if(!is.null(after)) after <- paste0("&after=", after)

  page_url <- paste0(base_url, before, after)

  while(!is.null(after) & page < max_pages) {
    page <- page + 1
    page_lab <- paste0("page_", page)

    resp <- httr::GET(url = page_url, headers)
    content <- jsonlite::fromJSON(httr::content(resp, as = "text"))

    if (!is.null(content$data$children$data)) {
      post_data[[page_lab]] <- content$data$children$data
    }

    message(paste("Page", page, "returned"))

    before <- content$data$before
    if(!is.null(before)) before <- paste0("&before=", before)

    after <- content$data$after
    if(!is.null(after)) after <- paste0("&after=", after)

    page_url <- paste0(base_url, before, after)
  }

  return(post_data)
}
