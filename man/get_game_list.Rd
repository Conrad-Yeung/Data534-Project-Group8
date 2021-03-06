% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_game_list.R
\name{get_game_list}
\alias{get_game_list}
\title{GET request to RAWG}
\usage{
get_game_list(
  n = 40,
  page = 1,
  api_key = "",
  start_date = "",
  end_date = "",
  metacritic = "",
  platform = "",
  platform_count = "",
  genre = "",
  ordering = ""
)
}
\arguments{
\item{n}{(int): number of games/entries (default = 40). Max 40. If you want to look at entries beyond the 40th index, use the \code{page} parameter.}

\item{page}{(int): page number queried (default = 1)}

\item{api_key}{(str): your api key (recommended - not required, default = none)}

\item{start_date}{(str): start release date in the form YYYY-MM-DD (default = none). Ex: "2020-01-30"}

\item{end_date}{(str): end release date in the form YYYY-MM-DD (default = none). Ex: "2021-30-30"}

\item{metacritic}{(str): metacritic rating range (default = none). Ex: "80,100" will give you ratings between 80 and 100.}

\item{platform}{(str):  ID of platform (1=XboxOne, 2=Playstation, 3=Xbox, 4=PC etc.) Ex: "1" or "1,2,3" for a range of platforms.}

\item{platform_count}{(int): number of platforms games are available on.}

\item{genre}{(str): the genre of games in the form of string or using the ID tag. Ex: "action,indie" or "4,51"}

\item{ordering}{(str): how to order data, use "-" to reverse order. Ex: "name", "released", "created", "added", "updated", "rating", "-metacritic."}
}
\value{
Return Data.Frame with list of games
}
\description{
Submit RAWG query and receive RAWG response formatted as a data frame
}
\examples{
get_game_list(start_date="2000-01-01",end_date="2020-12-31",genre="1,2,3",ordering ="-added")
test<-get_game_list()
}
