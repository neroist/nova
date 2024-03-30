import std/httpclient
import std/terminal
import std/json

import puppy

import ./ansi

template success*(args: varargs[untyped]) = styledEcho fgGreen, args, resetStyle
template warning*(args: varargs[untyped]) = styledEcho fgYellow, args, resetStyle
template error*(args: varargs[untyped]) = styledEcho fgRed, args, resetStyle

func getErrorMsg*(code: int): string =
  case code:
    of 401, 403:
      return "Invalid API key. Run `nova setup` to re-enter your API key."
    of 500..599:
      return "Govee internal error. Try running this command again another time."
    else:
      return $code & " error"

proc sendCompletionMsg*(response: puppy.Response) =
  if response.code == 200:
    success "Successfully executed command"
  else:
    error "Error executing command"
 
  echo "Message: ", parseJson(response.body)["message"]
  echo "Code: ", HttpCode(response.code)

export ansi
