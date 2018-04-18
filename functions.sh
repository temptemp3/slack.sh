#!/bin/bash
## functions
## - slack.sh function
## version 0.0.2 - user channel history debug
##################################################
#!/bin/bash
## error
## =standalone=
## version: 2.0.6 - sh2 initial
## see <https://github.com/temptemp3/sh2>
##################################################
{ # error handling

 set -e # exit on error

 date_offset=0 # may depreciate later
 _date() {   _() { echo "date" ; } ;  __() { echo "--$( _ )=@$(( $( $( _ ) +%s ) + ${date_offset} ))" ; } ;  ___() { echo "+%y%m%d %H%M" ; } ;  "$( _ )" "$( __ )" "$( ___ )" ; }  
 _finally() { true ; }
 _cleanup() { true ; }
 _on_error() { true ; }
 _on_success() { true ; }
 error-show() {
  cat << EOF
error_message: ${error_message}
error_function_name: ${error_function_name}
error_line_number: ${error_line_number}
error_show: ${error_show}
EOF
 }
 error-help() {
  cat << EOF
error
- error handling interface

USAGE

# show|hide error errors
error true|false

# exit with error message
false || {
 error "manual break" "\${BASH_FUNC}" "\${LINE_NO}"
 false
}


EOF
 } 
 error() {
  case ${#} in
   3) {
    error_message="${1}"
    error_function_name="${2}"
    error_line_number="${3}" 
   } ;;
   1) {
    error_show=${1}
   } ;;
  esac
 }
 _exit() { set +v +x ; { local function_name ; local line_number ; function_name=${1} ; line_number=${2} ; }
 if-function-name() { _() { echo $( test "${1}" && { echo "${1}" ; true ; } || { echo "${2}" ; } ; ) ; } ; _ "${error_function_name}" "${function_name}" ; }
 if-line-number() { _() { echo $( test ! "${1}" -a ! ${2} -ne 1 || { echo "on line" ; test ! "${1}" && { test ! ${2} -ne 1 || { echo "${2}" ; } ; true ; } || { echo "${1}" ; } ; } ; ) ; } ; _ "${error_line_number}" "${line_number}" ; }
 if-message() { _() { test ! "${1}" || { echo "\"${1}\"" ; } ; } ; _ "${error_message}" ; }
 if-error-show() {
   test "${error_show}" = "false" || {
    cat >> error-log << EOF
$( _date ) ${0} $( if-message )
error in $( if-function-name ) $( if-line-number )
EOF
    echo $( tail -n 2 error-log ) 1>&2 # stdout to stderr
   }
  }
  test ! "${function_name}" = "" && {
   if-error-show 
   _on_error
  true
  } || { # on success
   _on_success
  }
  _finally ; _cleanup ;
 }
 error "true" # ! default
 trap '_exit "${FUNCNAME}" "${LINENO}"' EXIT ERR
}
##################################################
#!/bin/bash
## commands (alias)
## - function command cli adapter
## version 0.0.6** - filter-exclude-list
## see <https://github.com/temptemp3/sh2>
##################################################
list-available-commands-filter-exclude-list-default() { 
 cat << EOF
which
for-each
payload
initialize
test
EOF
}
list-available-commands-filter-exclude-list() { 
 ${FUNCNAME}-default
}
list-available-commands-filter-exclude() { 
 local filter_exclude
 filter_exclude=$( 
   local el
   for el in $( ${FUNCNAME}-list )
   do
    echo "-e ${el}"
   done
 )
 echo ${filter_exclude}
}
list-available-commands() { { local function_name ; function_name="${1}" ; local filter_include ; filter_include="${2}" ; }
  #echo "function_name: ${function_name}" 
  #echo "filter_include: ${filter_include}"
  #${FUNCNAME}-filter-exclude 
  echo available commands:
  {
    declare -f \
    | grep -e "^${function_name}[^(]*.)" \
    | cut "-f1" "-d " \
    | grep -v -e $( ${FUNCNAME}-filter-exclude ) \
    | sed -e "s/${function_name}[-]\?//" \
    | xargs -I {} echo "- {}" \
    | grep -e "${filter_include}" \
    | sort
  }
}
shopt -s expand_aliases
alias read-command-args='
 list-available-commands ${FUNCNAME}
 echo "enter new command (or q to quite)"
 read command_args
'
alias parse-command-args='
 _car() { echo ${1} ; }
 _cdr() { echo ${@:2} ; }
 _command=$( _car ${command_args} )
 _args=$( _cdr ${command_args} )
'
alias commands='
 #test "${_command}" || { local _command ; _command="${1}" ; }
 #test "${_args}" || { local _args ; _args=${@:2} ; }
 { local _command ; _command="${1}" ; }
 { local _args ; _args=${@:2} ; }
 test ! "$( declare -f ${FUNCNAME}-${_command} )" && {
  {    
    test ! "${_command}" || {
     echo "${FUNCNAME} command \"${_command}\" not yet implemented"
    }
    list-available-commands ${FUNCNAME} 
  } 1>&2
 true
 } || {
  ${FUNCNAME}-${_command} ${_args}
 }
'
alias run-command='
 {
   commands
 } || true
'
alias handle-command-args='
 case ${command_args} in
   q|quit) {
    break  
   } ;; 
   *) { 
    parse-command-args
   } ;;
 esac
'
alias command-loop='
 while [ ! ]
 do
  run-command
  read-command-args
  handle-command-args
 done
'
##################################################
shopt -s expand_aliases
alias slack-api-call='
{
  curl --silent --url "${method_url}?token=${slack_api_token}&${method_query}" 
} | tee temp-${FUNCNAME}
'
alias slack-api-query='
{
  slack-query "${api_method}" "${query}"
} | tee temp-${FUNCNAME}
'
##################################################
floor() {
 echo ${@} \
 | sed -e 's/[.]*$//'
}
#-------------------------------------------------
trim() {
 echo ${@} \
 | sed -e 's/"//g'
}
#-------------------------------------------------
ts-date() { { local candidate_date ; candidate_date="${1}" ; }
 date --date="${candidate_date}" +%s
}
#-------------------------------------------------
ts-today() {
 date --date="$( date +%F )" +%s
}
#-------------------------------------------------
ts-now() {
 date +%s
}
#-------------------------------------------------
ts-m24h() {
 echo $(( $( date +%s ) - 86400 ))
}
#-------------------------------------------------
ts-m1w() {
 echo $(( $( date +%s ) - 86400 * 7 ))
}
#-------------------------------------------------
ts-m30d() {
 echo $(( $( date +%s ) - ( 86400 * 30 ) ))
}
#-------------------------------------------------
ts-m1y() {
 echo $(( $( date +%s ) - ( 86400 * 365 ) ))
}
#-------------------------------------------------
slack-test-get-user-channels-history() { { local candidate_name ; candidate_name=${@} ; }
 get-user-channels-history $( get-member-id ${candidate_name} )
}
#-------------------------------------------------
get-user-channels-history() { { local candidate_id ; candidate_id="${1}" ; }
  test "${candidate_id}" || {
   error "empty member id" "${FUNCNAME}" "${LINENO}"
   false
  }
  { 
    local api_method
    api_method="channels.history"
    local query
    query=".[\"messages\"][]|if .[\"user\"] == ${candidate_id} then . else empty end"
  }
  slack-api-query
}
#-------------------------------------------------
slack-channels-history-if-oldest-ts() { 
 test ! "${oldest_ts}" || {
  echo "&oldest=$( ${oldest_ts} )"
 }
}
#-------------------------------------------------
slack-channels-history-if-oldest-date() { 
 test ! "${arg_oldest_date}" || {
  echo "&oldest=$( ts-date ${arg_oldest_date} )"
 }
}
#-------------------------------------------------
slack-channels-history-if-oldest() { 
 ${FUNCNAME}-ts
 ${FUNCNAME}-date
}
#-------------------------------------------------
slack-channels-history() { { local arg_oldest_date ; arg_oldest_date="${1}" ; }
  {
    local method_url
    method_url="https://slack.com/api/channels.history"
    local method_query
    method_query="channel=${channel}$( ${FUNCNAME}-if-oldest )&pretty=1"
  }
  slack-api-call
}
#-------------------------------------------------
slack-test-get-channel-names() {
 get-channel-names
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
slack-test-get-channel-ids() {
 get-channel-ids
}
#-------------------------------------------------
get-channel-ids() {
  { 
    local api_method
    api_method="channels.list"
    local query
    query='.["channels"][]["id"]'
  }
  slack-api-query
}
#-------------------------------------------------
slack-test-for-each-channel() {
 for-each-channel
}
#-------------------------------------------------
get-user-channel-history-ts() {
 echo ${user_channel_history} \
 | jq '.["ts"]' 
}
#-------------------------------------------------
shopt -s expand_aliases
alias setup-user-channel-history='
{
  local user_channel_history
  user_channel_history=$( 
    get-user-channels-history ${member_id} 
  )
}
'
#-------------------------------------------------
for-each-channel-get-user-channel-history() { 

 cat << EOF
[
EOF
 local channel
 for channel in $( get-channel-ids | sed -e 's/"//g' )
 do
  slack-channels-history ${date_oldest} 1>/dev/null
  local member_id
  for member_id in ${member_ids}
  do
   setup-user-channel-history
   test ! "${user_channel_history}" || {
    ## replace with user channel history function name later
    {
      echo ${user_channel_history} \
      | jq '
if .["type"] == "message" and .["subtype"]|not
then
.
else
 empty
end
'
    }
   }
  done
 done | sed -e 's/^[}]$/},/'
 cat << EOF
{}
]
EOF

 
}
#-------------------------------------------------
# for-each-channel
# - do something on each channel
# + currently fectching user channel history
# version 0.0.2 - user channel history debug
#-------------------------------------------------
for-each-channel() { { local date_oldest ; date_oldest="${1}" ; }

 ## depreciated may remove later
 #{ local function_name ; function_name="${1}" ; }
 
 local user_channel_history 
 user_channel_history=$( 
  ${FUNCNAME}-get-user-channel-history
 )
 echo ${user_channel_history} | tee temp-user-channel-history 1>&2

 ## get list of unique users
 local unique_users
 unique_users=$(
  echo ${user_channel_history} \
  | jq '.[]["user"]' \
  | sort \
  | uniq \
  | sed -e 's/null//g'
 )
 echo unique_users: ${unique_users} 1>&2

 ## replace user w/ user real_name in user channel history
 local user 
 for user in ${unique_users} 
 do
  echo ${user} 1>&2
  sed -i -e "s/${user}/$( slack-users-info ${user} real-name )/g" temp-user-channel-history
 done
 cat temp-user-channel-history | jq '.' 1>&2

 ## get list of tss
 local tss
 tss=$(
  echo ${user_channel_history} \
  | jq '.[]["ts"]' \
  | sort \
  | uniq \
  | sed -e 's/null//g'
 )
 echo tss: ${tss} 1>&2

 ## replace ts w/ date
 local ts
 local ts_date
 for ts in ${tss}
 do
  echo ${ts} 1>&2
  ts_date=$( date --date="@$( trim ${ts} )" )
  echo ${ts_date} 1>&2
  sed -i -e "s/${ts}/\"${ts_date}\"/g" temp-user-channel-history
 done
 cat temp-user-channel-history | jq '.'
}
#-------------------------------------------------
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
slack-channels() {
 commands
}
#-------------------------------------------------
method-slug() { { local candidate_method ; candidate_method="${1}" ; }
 echo ${candidate_method} | sed -e 's/[.]/-/g'
}
#-------------------------------------------------
slack-query() { { local api_method ; api_method="${1}" ; local queary ; query="${2}" ; }
  test "${api_method}" 
  test "${query}" || {
   error "query not specified" "${FUNCNAME}" "${LINENO}"
   false
  }
  local input_json
  input_json="temp-slack-$( method-slug ${api_method} )"
  test ! -f "${input_json}" || {
    {
      jq "${query}" ${input_json}
    }
  }
}
#-------------------------------------------------
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
slack-users() {
 commands
}
#-------------------------------------------------
slack-test-get-member-id() { { local candidate_name ; candidate_name=${@} ; }
 get-member-id "${candidate_name}"
}
#-------------------------------------------------
get-member-id() { { local candidate_name ; candidate_name=${@} ; }

 test ! "$( get-member-id-by-real-name ${candidate_name} )" || {
  get-member-id-by-real-name "${candidate_name}" 
  return
 }

 test ! "$( get-member-id-by-profile-display-name ${candidate_name} )" || {
  get-member-id-by-profile-display-name "${candidate_name}"
  return
 }

}
#-------------------------------------------------
slack-test-get-member-id-by-profile-display-name() { { local candidate_name ; candidate_name=${@} ; }
 get-member-id-by-profile-display-name "${candidate_name}"
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
slack-test-get-member-id-by-real-name() { { local candidate_name ; candidate_name=${@} ; }
 get-member-id-by-real-name "${candidate_name}"
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
slack-test-get-member-info-by-id() { { local candidate_id ; candidate_id=${1} ; }
 get-member-info-by-id ${candidate_id}
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
#-------------------------------------------------
slack-test() {
 commands
}
#-------------------------------------------------
slack_api_token=
channel=
member_ids=
slack-initialize() {
 . $( dirname ${0} )/slack-config.sh
}
#-------------------------------------------------
slack() {
 ${FUNCNAME}-initialize
 {
   ${FUNCNAME}-channels-history
   ${FUNCNAME}-channels-list
   ${FUNCNAME}-users-list
 } 1>/dev/null
 commands
}
#-------------------------------------------------
#functions() {
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
#functions
##################################################
## generated by create-stub2.sh v0.1.0
## on Tue, 17 Apr 2018 23:11:12 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
