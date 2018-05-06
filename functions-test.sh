#!/bin/bash
## functions-test
## - functions for testing
## version 0.0.1 - initial
##################################################
slack-test-get-channel-names() {
 get-channel-names
}
#-------------------------------------------------
slack-test-get-channel-ids() {
 get-channel-ids
}
#-------------------------------------------------
slack-test-for-each-channel() {
 for-each-channel
}
#-------------------------------------------------
slack-test-get-member-id() { { local candidate_name ; candidate_name=${@} ; }
 get-member-id "${candidate_name}"
}
#-------------------------------------------------
slack-test-get-member-id-by-profile-display-name() { { local candidate_name ; candidate_name=${@} ; }
 get-member-id-by-profile-display-name "${candidate_name}"
}
#-------------------------------------------------
slack-test-get-member-id-by-real-name() { { local candidate_name ; candidate_name=${@} ; }
 get-member-id-by-real-name "${candidate_name}"
}
#-------------------------------------------------
slack-test-get-member-info-by-id() { { local candidate_id ; candidate_id=${1} ; }
 get-member-info-by-id ${candidate_id}
}
#-------------------------------------------------
slack-test-get-user-channels-history() { { local candidate_name ; candidate_name=${@} ; }
 get-user-channels-history $( get-member-id ${candidate_name} )
}
#-------------------------------------------------
slack-test() {
 commands
}
##################################################
## generated by create-stub2.sh v0.1.1
## on Sun, 06 May 2018 21:18:22 +0900
## see <https://github.com/temptemp3/sh2>
##################################################
