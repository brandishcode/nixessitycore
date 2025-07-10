local ansicolors = require 'ansicolors'
local log = require 'logging'

require 'logging.console'
require 'logging.file'

local log_dir = string.format('%s/.local/share/nixessitycore', os.getenv('HOME'))
os.execute(string.format('mkdir -p %s', log_dir))

local __appender
local __output_appender

return {
  get_log = function()
    assert(__appender, "call setup first: require 'appender'.setup()")
    return __appender
  end,
  ---@param name string the command name
  ---@param show_debug boolean whether to show debug logs or not
  ---@param file_log? boolean whether to log in a file
  setup = function(name, show_debug, file_log)
    local level = log.FATAL
    if show_debug then
      level = log.DEBUG
    end
    local timestampPattern = '%y-%m-%d %H:%M:%S.%3q'
    local appender
    if file_log then
      appender = log.file {
        filename = string.format('%s/%s-%s.log', log_dir, os.date('%Y%m%d_%H%M%S'), name),
        logPattern = '%date %level %message\n',
        logLevel = log.DEBUG,
        timestampPattern = timestampPattern,
      }
    else
      appender = log.console {
        logLevel = level,
        destination = 'stderr',
        timestampPattern = timestampPattern,
        logPatterns = {
          [log.DEBUG] = ansicolors('%date %{magenta}%level %{reset}%message\n'),
          [log.ERROR] = ansicolors('%date %{red}%level %{reset}%message\n'),
          [log.WARN] = ansicolors('%date %{yellow}%level %{reset}%message\n'),
          [log.INFO] = ansicolors('%date %{green}%level %{reset}%message\n'),
          [log.FATAL] = ansicolors('%{red}Error%{reset}: %message\n'),
        },
      }
    end
    __appender = appender
    __output_appender = log.console {
      logLevel = log.INFO,
      destination = 'stdout',
      logPatterns = {
        [log.INFO] = ansicolors('%{reset}%message'),
      },
    }
  end,
  get_output_log = function()
    return __output_appender
  end,
}
