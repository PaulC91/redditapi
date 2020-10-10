
#' Retrieve reddit API access token
#'
#' @param agent name of your reddit api application
#' @param client_id client_id of your reddit api application
#' @param secret secret of your reddit api application
#' @param username your reddit username
#' @param password your reddit password
#'
#' @return oauth token string
#' @export
get_reddit_token <- function(agent, client_id, secret, username, password) {
  body <- list(
    grant_type = "password",
    username = username,
    password = password
  )

  resp <- httr::POST(
    url = "https://www.reddit.com/api/v1/access_token",
    httr::authenticate(user = client_id, password = secret),
    httr::content_type("application/x-www-form-urlencoded"),
    httr::add_headers("User-Agent" = paste(agent, "by", username)),
    body = body,
    encode = "form"
  )

  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  parsed <- httr::content(resp)

  if (!is.null(parsed$error)) {
    stop(
      sprintf(
        "Reddit token request failed: %s",
        parsed$error
      ),
      call. = FALSE
    )
  }

  token <- parsed$access_token

  return(token)
}
