#' GET request to RAWG
#'
#' Submit RAWG query and receive RAWG response formatted as a data frame
#' 
#' @import httr
#' @import jsonlite
#' @import dplyr
#' @import tibble
#'
#' @param n (int): number of games/entries (default = 40). Max 40. If you want to look at entries beyond the 40th index, use the `page` parameter.
#' @param page (int): page number queried (default = 1) 
#' @param api_key (str): your api key (recommended - not required, default = none)
#' @param start_date (str): start release date in the form YYYY-MM-DD (default = none). Ex: "2020-01-30"
#' @param end_date (str): end release date in the form YYYY-MM-DD (default = none). Ex: "2021-30-30"
#' @param metacritic (str): metacritic rating range (default = none). Ex: "80,100" will give you ratings between 80 and 100.
#' @param platform (str):  ID of platform (1=XboxOne, 2=Playstation, 3=Xbox, 4=PC etc.) Ex: "1" or "1,2,3" for a range of platforms.  
#' @param platform_count (int): number of platforms games are available on. 
#' @param genre (str): the genre of games in the form of string or using the ID tag. Ex: "action,indie" or "4,51"
#' @param ordering (str): how to order data, use "-" to reverse order. Ex: "name", "released", "created", "added", "updated", "rating", "-metacritic." 
#'
#' @return Return Data.Frame with list of games
#'
#' @export
#'
#' @examples 
#' get_game_list(start_date="2000-01-01",end_date="2020-12-31",genre="1,2,3",ordering ="-added")
#' test<-get_game_list()

#Check for insertion attacks

get_game_list <- function(n=40,page=1,api_key="",start_date="",end_date="",metacritic="",platform="",platform_count="",genre="",ordering=""){
  
  if (TRUE %in% grepl("&|%",c(n,page,api_key,start_date,end_date,metacritic,platform,platform_count,genre,ordering))){
    stop("Please do not try to mess with the GET request.")
  }
  
  #Check n <= 40
  if (n > 40){
    stop("Max query length is 40. If you want to get entries beyond the 40th game, please change the `page` number. For example, entry 41-80 use `page='2'.")
  } else if (n < 1){
    stop("Min query length is 1.")
  } else {
    cleaned_n <- paste("page_size=",n,sep="")
  }
  
  #Page number
  cleaned_page<-paste("&page=",page,sep="")
  
  #Check if API Key is given
  if (api_key == ""){
    cleaned_api_key <- ""
  } else {
    cleaned_api_key <- paste("&key=",api_key,sep="")
  }
  
  #Check if dates are given
  if ((start_date == "")&(end_date=="")){ #No Dates Given
    cleaned_date <- ""
  }else if ((start_date != "") & (end_date=="")){ #Only Start Date Given
    stop("You need to enter an end date")
  }else if ((start_date == "") & (end_date!="")){
    stop("You need to enter an start date") #Only Start Date Given
  }else { #Both Dates given
    if ((grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}",start_date) & grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}",end_date)) == TRUE){
      if (start_date >= end_date){
        stop("start_date must be before end_date")
      }else{
        cleaned_date <- paste("&dates=",start_date,",",end_date,sep="")
      }
    } else {
      stop("Please enter dates in the form YYYY-MM-DD.")
    }
  }
  
  #Metacritic range
  if (metacritic == ""){
    cleaned_metacritic<-""
  }else{
    cleaned_metacritic <- paste("&metacritic=",metacritic,sep="") 
  }
  
  #Platforms
  if (platform == ""){
    cleaned_plat<-""
  }else{
    cleaned_plat <- paste("&platforms=",platform,sep="")
  }
  
  #Platform count 
  if (platform_count == ""){
    cleaned_plat_count<-""
  }else{
    cleaned_plat_count <- paste("&platforms_count=",platform_count,sep="")
  }
  
  #Genre
  if (genre == ""){
    cleaned_genre<-""
  }else{
    cleaned_genre <- paste("&genre=",genre,sep="")
  }
  
  #Ordering
  if (ordering == ""){
    cleaned_order <- "" 
  }else if (ordering %in% c("name","released","added","created","updated","rating","metacritic","-name","-released","-added","-created","-updated","-rating","-metacritic")){
    cleaned_order <- paste("&ordering=",ordering,sep="")
  }else{
    stop('Field must be one of the following: "name","released","added","created","updated","rating","metacritic","-name","-released","-added","-created","-updated","-rating","-metacritic"')
  }
  
  link <- paste("https://api.rawg.io/api/games?",cleaned_n,cleaned_page,cleaned_api_key,cleaned_metacritic,cleaned_date,cleaned_metacritic,cleaned_plat,cleaned_plat_count,cleaned_genre,cleaned_order,sep="")
  get_link <- GET(link) #GET REQUEST
  
  #Check if it is a successful connection
  if (get_link$status_code != 200){
    stop("Please double check the inputted parameters (i.e. make sure your API is correct")
  }
  
  raw_content <- fromJSON(content(get_link,"text",encoding="UTF-8"),simplifyVector=FALSE) #Converting into JSON
  
  results <- (raw_content$results)
  
  #Cleaning and Formatting
  #Initial Run
  #Cleanup & Table values for A FIRST GAME 
  data_raw <- results[[1]]
  names <- enframe(unlist(data_raw))
  temp_df <- data.frame(names)
  temp_df <- temp_df[!grepl("tags|screenshots|store|image|requirements|clip", temp_df$name),]
  #Create Unique Labeling - prepping for merge
  uniquify_list <- c("ratings.id","platforms.platform.id","parent_platforms.platform.id","genres.id")
  stop_list <- c("ratings.percent","platforms.released_at","parent_platforms.platform.slug","genres.games_count")
  ids <- ""
  for (i in 1:length(temp_df$name)){
    if (temp_df$name[i] %in% uniquify_list){
      ids <- temp_df[i,"value"]
    }else if (temp_df$name[i] %in% stop_list){
      temp_df$name[i]<-paste(temp_df$name[i],ids,sep="")
      ids<-""
    }
    temp_df$name[i]<-paste(temp_df$name[i],ids,sep="")
  }
  final_df<-temp_df
  
  #For all other n-1 games
  for (entries in (2:length(results))){ #Do the same for all other N-1 games 
    #Cleanup & Table values for A SINGLE GAME 
    data_raw <- results[[entries]]
    names <- enframe(unlist(data_raw))
    temp_df <- data.frame(names)
    temp_df <- temp_df[!grepl("tags|screenshots|store|image|requirements|clip", temp_df$name),]
    
    #Create Unique Labeling - prepping for merge
    ids<-"" #RESET THE LABEL AFTER EACH GAME
    for (i in 1:length(temp_df$name)){
      if (temp_df$name[i] %in% uniquify_list){
        ids <- temp_df[i,"value"]
      }else if (temp_df$name[i] %in% stop_list){
        temp_df$name[i]<-paste(temp_df$name[i],ids,sep="")
        ids<-""
      }
      temp_df$name[i]<-paste(temp_df$name[i],ids,sep="")
    }
    final_df<-full_join(final_df, temp_df, by = "name") #Joining by 'name' column
  }
  
  #Cleaning up Data.frame
  final_df<-t(final_df)
  colnames(final_df) <- final_df[1,]
  final_df<-final_df[-1,]
  rownames(final_df)<-NULL
  final_df<-data.frame(final_df)
  
  #Return object
  return(final_df)
}
