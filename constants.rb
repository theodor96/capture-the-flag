# keeps track of every constant used by the server application
module Constants
  HOSTNAME = '192.168.1.135'
  PORT = 3000
  SLEEP_AFTER_CAPTURE_UPPER = 10
  SLEEP_AFTER_CAPTURE_LOWER = 1
  SLEEP_AFTER_FAIL_CAPTURE = 0.5
  ID = 'TSerbana.' + rand(36**9).to_s(36)
  DEBUGGING = true
  ASK_NEXT_SERVER = 'next_server'
  ASK_GET_ID = 'who_are_you?'
  ASK_HAVE_FLAG = 'have_flag?'
  ASK_CAPTURE_FLAG = 'capture_flag'
  ANSWER_HAVE_FLAG_NO = 'NO'
  ANSWER_HAVE_FLAG_YES = 'YES'
  ANSWER_CAPTURE_FLAG_YES = 'FLAG:'
  ANSWER_CAPTURE_FLAG_NO = 'ERR: You\'re trying to trick me'
end
