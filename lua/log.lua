local ansicolors = require 'ansicolors'
local log = require 'logging'

require 'logging.console'

log.defaultLogger(log.console {
  logLevel = log.DEBUG,
  destination = 'stdout',
  timestampPattern = '%y-%m-%d %H:%M:%S.%3q',
  logPatterns = {
    [log.DEBUG] = ansicolors('%date %{magenta}%level %{reset}%message\n'),
    [log.ERROR] = ansicolors('%date %{red}%level %{reset}%message\n'),
    [log.WARN] = ansicolors('%date %{yellow}%level %{reset}%message\n'),
    [log.INFO] = ansicolors('%date %{green}%level %{reset}%message\n'),
    [log.FATAL] = ansicolors('%{red}Error%{reset}: %message\n'),
  },
})

return { default =  log.defaultLogger() }
