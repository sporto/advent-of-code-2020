import gleam/otp/supervisor.{ApplicationStartMode, ErlangStartResult}
import gleam/dynamic.{Dynamic}

fn init(children) {{
  children
}}

pub fn start(
  _mode: ApplicationStartMode,
  _args: List(Dynamic),
) -> ErlangStartResult {{
  init
  |> supervisor.start
  |> supervisor.to_erlang_start_result
}}

pub fn stop(_state: Dynamic) {{
  supervisor.application_stopped()
}}
