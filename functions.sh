#!/bin/bash
## functions
## - slack.sh function
## version 0.1.1 - export sources to header, etc.
## to do:
## + migrate to sh2
## ++ error
## ++ commands
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
# version 0.0.3 - case all cecho starting
setup-channel-ids() {
 cecho green in ${FUNCNAME}
 test ! "${channel_ids}" = "all" || {
  cecho green getting all channel ids..
  channel_ids=$( 
   get-channel-ids | sed-strip-double-quotes
  )
 }
 cecho yellow channel_ids: ${channel_ids}
}
#-------------------------------------------------
escape-slash() {
  {
    echo ${@} 
  } | sed-escape-slash
}
#-------------------------------------------------
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
get-user-channel-history-ts() {
 echo ${user_channel_history} \
 | jq '.["ts"]' 
}
#-------------------------------------------------
# version 0.0.2 - using channel_ids
for-each-channel-get-user-channel-history-payload() { 

 local channel
 for channel in ${channel_ids}
 do

  cecho yellow channel: ${channel} 1>&2 

  { # initialize channel history
    slack-channels-history ${date_oldest} # > temp-slack-channels-history
  } 1>/dev/null

  for-each-channel-get-user-channel-history-payload-on-empty-channel # continue on empty channel history

  ## test has more true case 

  cecho yellow member_ids: ${member_ids}
 
  local member_id
  for member_id in ${member_ids}
  do

   cecho yellow member_id: ${member_id} 1>&2

   setup-user-channel-history # ${user_channel_history} > temp-get-user-channels-history
   
   for-each-channel-get-user-channel-history-payload-on-empty-user-channel # continue on empty user channel history

   echo ${user_channel_history} | jq '.' 

  done

 done 

}
#-------------------------------------------------
# version 0.0.2 - caching
for-each-channel-get-user-channel-history() {
  cecho green [ begin ${FUNCNAME}
  {
    #cache \
    #"${cache}/${FUNCNAME}" \
    "${FUNCNAME}-payload"
  }

  cecho green end of ${FUNCNAME} ]
}
#-------------------------------------------------
# for-each-channel
# - do something on each channel
# + currently fectching user channel history
# version 0.0.5 - inherit channel ids
#-------------------------------------------------
method-slug() { { local candidate_method ; candidate_method="${1}" ; }
 echo ${candidate_method} | sed -e 's/[.]/-/g'
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
slack-query() { { local api_method ; api_method="${1}" ; local queary ; query="${2}" ; }
  test "${api_method}" 
  test "${query}" || {
   error "query not specified" "${FUNCNAME}" "${LINENO}"
   false
  }
  local input_json
  input_json="${cache}/temp-slack-$( method-slug ${api_method} )"
  test ! -f "${input_json}" || {
    {
      cat ${input_json} | jq "${query}" 
    }
  }
}
#-------------------------------------------------
slack-users() {
 commands
}
##################################################
## generated by create-stub2.sh v0.1.0
## on Tue, 17 Apr 2018 23:11:12 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
