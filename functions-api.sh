#!/bin/bash
## functions-api
## - slack api functions
## version 0.1.1 - get-channel-name recovery from working
##################################################
## version 0.0.2 - temp in cache
shopt -s expand_aliases
alias slack-api-call='
{
  _() {
   cecho yellow curl --url "${method_url}?token=${slack_api_token}&${method_query}" --silent $( test ! "${allow_insecure}" = "true" || echo "--insecure" ) 
   curl --url "${method_url}?token=${slack_api_token}&${method_query}" --silent $( test ! "${allow_insecure}" = "true" || echo "--insecure" ) 
  }
  _ | tee ${cache}/temp-${FUNCNAME}
  ### WIP
  #test ! "${DEBUG}" = "true" || {
  # head ${cache}/temp-${FUNCNAME}
  #}
} 
'
## version 0.0.2 - temp in cache
alias slack-api-query='
{ 
  _() {
   slack-query "${api_method}" "${query}"
  }
  _ | tee ${cache}/temp-${FUNCNAME}
}
'
##################################################
slack-channels-list() {
  {
    local method_url
    method_url="https://slack.com/api/channels.list"
    local method_query
    method_query="pretty=1"
  }
  slack-api-call
}
#-------------------------------------------------
slack-channels-history() { { local arg_oldest_date ; arg_oldest_date="${1}" ; }
  {
    local method_url
    method_url="https://slack.com/api/channels.history"
    local method_query
    method_query="channel=${channel}$( ${FUNCNAME}-if-oldest )&pretty=1"
  }
  {
    slack-api-call
  } \
  | jq '. + {"channel","channel"}'
}
#-------------------------------------------------
slack-users-list() {
  {
    local method_url
    method_url="https://slack.com/api/users.list"
    local method_query
    method_query="pretty=1"
  }
  slack-api-call
}
#-------------------------------------------------
slack-users-info-case() { 
  case ${field} in 
   ts) {
    echo ${users_info} | jq '.["user"]["real_name"]'
   } ;;
   real-name) {
    echo ${users_info} | jq '.["user"]["real_name"]'
   } ;;
   *) {
    echo ${users_info}
   } ;;
  esac
}
#-------------------------------------------------
# version 0.0.2 - caching
slack-users-info() { { local user ; user="${1}" ; local field ; field="${2}" ; }

  test "${user}"

  {
    local method_url
    method_url="https://slack.com/api/users.info"
    local method_query
    method_query="user=$( trim ${user} )&pretty=1"
  }

  local users_info
  users_info=$(
   slack-api-call
  )

  {
    #cache \
    #"${cache}/${FUNCNAME}-${user}-${field}" \
    "${FUNCNAME}-case"
  }
}
##################################################
get-user-channels-history() { { local candidate_id ; candidate_id="${1}" ; }
  test "${candidate_id}" || {
   error "empty member id" "${FUNCNAME}" "${LINENO}"
   false
  }
  { 
    local api_method
    api_method="channels.history"
    local query
    query="
.messages[]|
if .user == ${candidate_id} 
then 
(
  . + {\"channel\":\"${channel}\"}
)
else 
empty
end
"
  }
  slack-api-query
}
#-------------------------------------------------
get-channels() {
  { 
    local api_method
    api_method="channels.list"
    local query
    query='.["channels"]'
  }
  slack-api-query
}
#-------------------------------------------------
get-channels-csv() {
  { 
    local api_method
    api_method="channels.list"
    local query
    query='.["channels"][]|[.["id"],.["name"]]|join(",")'
  }
  slack-api-query
}
#-------------------------------------------------
get-channel-name() { { local channel_id ; channel_id="${1}" ; }
  {
    local api_method
    api_method="channels.list"
    local query
    query="
.channels[]|
if .id == \"$( trim ${channel_id} )\"
then
.name
else
empty
end
"
  }
  slack-api-query
}
#-------------------------------------------------
get-channel-names() {
  { 
    local api_method
    api_method="channels.list"
    local query
    query='.["channels"][]["name"]'
  }
  slack-api-query
}
#-------------------------------------------------
get-channel-ids() {
  cecho green getting channel ids ...
  { 
    local api_method
    api_method="channels.list"
    local query
    query='.["channels"][]["id"]'
  }
  slack-api-query
}
#-------------------------------------------------
get-member-id-by-profile-display-name() { { local candidate_name ; candidate_name=${@} ; }
  { 
    local api_method
    api_method="users.list"
    local query
    query=".[\"members\"][]|if .[\"profile\"][\"display_name\"] == \"${candidate_name}\" then .[\"id\"] else empty end"
  }
  slack-api-query
}
#-------------------------------------------------
get-member-id-by-real-name() { { local candidate_name ; candidate_name=${@} ; }
  { 
    local api_method
    api_method="users.list"
    local query
    query=".[\"members\"][]|if .[\"real_name\"] == \"${candidate_name}\" then .[\"id\"] else empty end"
  }
  slack-api-query
}
#-------------------------------------------------
get-member-info-by-id() { { local candidate_id ; candidate_id=${1} ; }
  { 
    local api_method
    api_method="users.list"
    local query
    query=".[\"members\"][]|if .[\"id\"] == \"${candidate_id}\" then . else empty end"
  }
  slack-api-query
}
##################################################
#functions-api() {
# true
#}
##################################################
#if [ ${#} -eq 0 ] 
#then
# true
#else
# exit 1 # wrong args
#fi
##################################################
#functions-api
##################################################
## generated by create-stub2.sh v0.1.1
## on Mon, 23 Apr 2018 21:00:57 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
