# webash

## Introduction
This small project provides ability to check result of any shell command in browser.
It was born after few requirements in a row, that immediately gives overview why to use this project:
* ELB health-check based on bash health-check script and exit code
* Ability to read specific file on filesystem without need of ssh-ing to machine

## Installation
Just simply run ```gem install webash```

## Usage
You can run webash against single config file or config directory with *.yaml files
```webash -c /path/to/config.yaml``` or ```webash -c /path/to/config/dir```

Example of YAML config file you can find in **_examples_** directory

## Configuration
Webash expects the following YAML structure coming from configuration:
```yaml
listeners:
  PORT_NUMBER:
    - url: URL
      command: COMMAND
```

### Passing variable to shell execution
Example of reading last N lines from /var/log/messages
```yaml
listeners:
  8080:
    - url: "/logs"
      command: "cat /var/log/messages | tail -n $last_lines"
```
Then just request http://ip:8080/logs?last_line=100

### Exit codes
By default, exit code ```0``` corresponds with HTTP Code ```200```. All rest exit codes correspond with HTTP Code ```503```
You can override default mapping with custom configuration
```yaml
listeners:
  8080:
    - url: "/random"
      command: "EXIT=$((RANDOM%4)); echo \"exit code is $EXIT on 8080 /random \"; exit $EXIT"
      exit_codes:
        200: [2] # return HTTP code 200 if exit code 2
        404: [0, 1] # return HTTP code 404 if exit code is 0 or 1
```
