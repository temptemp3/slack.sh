#!/bin/bash
## functions-for-each-channel
## - functions for slack/for-each-channel
## version 0.0.1 - initial
##################################################
# ! only retrieves top level user field
for-each-channel-convert-user-ids-get-unique-user-ids-prior() {
  {
    jq '.[]["user"]' ${cache}/temp-user-channel-history 
  }
}
#-------------------------------------------------
for-each-channel-convert-user-ids-get-unique-user-ids-using-grep() {
  {
    grep -e '\"U[^"]*.' --only-matching ${cache}/temp-user-channel-history
  }
}
#-------------------------------------------------
for-each-channel-convert-users-ids-get-unique-user-ids-experimental() {
 #    echo ${user_channel_history} \
 #    | jq '.[]["user"]' 
 #    echo ${user_channel_history} \
 #    | jq '.[]["replies"]["user"]' 
 #    echo ${user_channel_history} \
 #    | jq '.[]["reactions"]["users"]' 
 true
}
#-------------------------------------------------
for-each-channel-convert-user-ids-get-unique-user-ids() {
  {
    #${FUNCNAME}-prior 
    ${FUNCNAME}-using-grep
  } \
  | sort \
  | uniq \
  | sed -e 's/null//g'
}
## testing
#jq '.' temp-user-channel-history 
#echo --- prior
#for-each-channel-get-unique-user-ids-prior # < temp-user-channel-history
#echo --- using-grep
#for-each-channel-get-unique-user-ids-using-grep # < temp-user-channel-history
#echo --- prod
#for-each-channel-get-unique-user-ids # < temp-user-channel-history
#exit
#-------------------------------------------------
alias setup-user-real-name='
{
  user_real_name=$(
   slack-users-info ${user} real-name 
  )
}
'
#-------------------------------------------------
setup-ts-date-case-default() {
 echo "+%m/%d/%y %H:%M"
}
#-------------------------------------------------
setup-ts-date-case() {
 case ${date_output_format} in
  default|mmddyyhhmm) { 
   ${FUNCNAME}-default
  } ;;
  # other formats
  *) {
   ${FUNCNAME}-default
  } ;;
 esac
}
#-------------------------------------------------
# version 0.0.2 - setup-ts-date as function
setup-ts-date() {
  # debug
  cecho yellow ts: ${ts}
  cecho yellow ts_trim: $( trim ${ts} )
  ts_date=$( 
   escape-slash $( 
    date --date="@$( trim ${ts} )" "$( ${FUNCNAME}-case )" 
   )
  )
  cecho yellow ts_date: ${ts_date}
}
#-------------------------------------------------
for-each-channel-convert-tss-get-prior() { 
  cat ${cache}/temp-user-channel-history \
  | jq '.[]["ts"]' \
  | sort \
  | uniq \
  | sed -e 's/null//g'
}
#-------------------------------------------------
for-each-channel-convert-tss-get-using-grep() { 
  {
    cat ${cache}/temp-user-channel-history \
	    | grep -e '"ts":\s"[^"]*.' --only-matching || true
  } \
  | cut '-f2' '-d:'
}
#-------------------------------------------------
for-each-channel-convert-tss-get() { 
  {
    #${FUNCNAME}-prior
    ${FUNCNAME}-using-grep
  } \
  | sort \
  | uniq
}
## testing
#cat temp-user-channel-history
#for-each-channel-get-tss
#exit
#-------------------------------------------------
# version 0.0.2 - setup-ts-date documentation
for-each-channel-convert-tss() { 

 #------------------------------------------------
 ## get list of tss
 local tss
 tss=$(
  ${FUNCNAME}-get
 )
 #{ # debug tss
 #  echo tss: ${tss} 
 #} 
 #------------------------------------------------

 #------------------------------------------------
 ## replace ts w/ date
 local ts
 local ts_date
 for ts in ${tss}
 do

  setup-ts-date # ${ts_date} (= 02\/06\/18 02:27)

  #-----------------------------------------------
  ## debug ts to ts_date conversion
  #set -v -x 
  #{
    sed -i -e "s/${ts}/\"${ts_date}\"/g" ${cache}/temp-user-channel-history-copy
  #} 2>&1
  #set +v +x
  #-----------------------------------------------

 done
 #------------------------------------------------

 #------------------------------------------------
 #{ # debug post ts replacement
 #  cat temp-user-channel-history-copy | jq '.'
 #}
 #------------------------------------------------

}
#-------------------------------------------------
for-each-channel-convert-user-ids() {

 #------------------------------------------------
 # start replacing user ids
 #------------------------------------------------
 ## get list of unique users
 local unique_users
 unique_users=$(
  ${FUNCNAME}-get-unique-user-ids # < temp-user-channel-history
 )
 #{ # debug unique users 
 #  echo unique_users: ${unique_users} 
 #}
 #------------------------------------------------

 #------------------------------------------------
 ## replace user w/ user real_name in user channel history
 local user 
 local user_real_name
 for user in ${unique_users} 
 do

  setup-user-real-name

  #{ # debug user(id,real_naem)
  #  echo ${user} 
  #  echo ${user_real_name} 
  #} 

  sed -i -e "s/${user}/${user_real_name}/g" ${cache}/temp-user-channel-history-copy

  ##----------------------------------------------
  ## debug text user id to real name conversion
  #set -v -x
  #{
    sed -i -e "s/<@$( strip-double-quotes ${user} )>/$( strip-double-quotes ${user_real_name} )/g" ${cache}/temp-user-channel-history-copy
  #} 2>&1
  #set +v +x
  ##----------------------------------------------

 done
 #{ # debug post user id replacement
 #  cat temp-user-channel-history-copy | jq '.'
 #}
 #------------------------------------------------
 # end replacing user ids
 #------------------------------------------------

}
#-------------------------------------------------
for-each-channel-convert-channel-ids-get() { 
  { # get channel ids
    cat ${cache}/temp-user-channel-history \
    | jq '.channel' \
    | sort \
    | uniq
  }
}
## testing
#for-each-channel-convert-channel-ids-get
#exit
#-------------------------------------------------
for-each-channel-convert-channel-ids-debug() {
 cecho yellow channel_id: ${channel_id} 
 cecho yellow channel_name: ${channel_name} 
}
#-------------------------------------------------
for-each-channel-convert-channel-ids-sed() {
    
  sed -i -e "s/${channel_id}/$( trim ${channel_name} )/g" ${cache}/temp-user-channel-history-copy

}
#-------------------------------------------------
for-each-channel-convert-channel-ids-setup() {
 channel_name=$(
  get-channel-name ${channel_id}
 )
}
#-------------------------------------------------
for-each-channel-convert-channel-ids() {
 cecho yellow channels_ids: ${channel_ids}
 local channel_id
 local channel_name
 for channel_id in ${channel_ids} #$( ${FUNCNAME}-get )
 do
  ${FUNCNAME}-setup
  ${FUNCNAME}-debug
  ${FUNCNAME}-sed
 done
}
## testing
#set -v -x
#channel_ids=$( get-channel-ids )
#for-each-channel-convert-channel-ids
#exit
#-------------------------------------------------
for-each-channel-convert() { 
 ${FUNCNAME}-channel-ids
 ${FUNCNAME}-user-ids
 ${FUNCNAME}-tss
}
#-------------------------------------------------

#-------------------------------------------------
# version 0.0.2 - less json on parse error
for-each-channel-output-json() { 
 {
   cat ${cache}/temp-user-channel-history-copy \
   | jq '.[]' 
 } || {
  error "json parse error" "${FUNCNAME}" "${LINENO}"
  less ${cache}/temp-user-channel-history-copy
  false
 }
}
#-------------------------------------------------
for-each-channel-output-text() { 
 cat ${cache}/temp-user-channel-history-copy \
 | jq '
 .[]|[.["channel"],.["user"],.["ts"],.["text"]]|join(",")
'
}
#-------------------------------------------------
for-each-channel-output() { 
 commands
}
##################################################
## generated by create-stub2.sh v0.1.1
## on Sun, 06 May 2018 21:15:46 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
