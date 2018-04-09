
<pre>

  / ____| |  | |  ____|  __ \ 
 | (___ | |__| | |__  | |  | |
  \___ \|  __  |  __| | |  | |
  ____) | |  | | |____| |__| |
 |_____/|_|  |_|______|_____/ 
 slack.history.exporter.daily
</pre>

SHED(1)

## NAME

shed - export daily slack channel history

## SYNOPSIS

**shed** subcommand args 

## DESCRIPTION

**shed** exports daily slack channel history using slack.sh

## SUBCOMMANDS

date-oldest yyyy-mm-dd

- export channel histories between yyyy-mm-dd and now

help

- show command help

## EXAMPLES

Export channel history since 8 Apr 2018

`shed date-oldest 2018-04-08` 

Get help

`shed help`

## INSTALLATION

Add alias `shed` such as `alias shed='bash /path/to/shed.sh/shed.sh'`  *optional*

Settup environment in `slack-config.sh` such as

```
{   
  local slack_api_token  
  local channel  
  local member_ids  
  slack_api_token="SLACK_API_LEGACY_TOKEN_FOR_TARGET_WORSPACE"  
  channel=  
  member_ids="\"DUMMYID1\" \"DUMMYID2\" \"DUMMYID3\""  
}  
```

## AUTHOR

Nicholas M Shellabarger &lt;<https://github.com/temptemp3>&gt;

SHED(1)



