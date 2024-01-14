lauxc watch $1 $2 &

transpiler_pid=$!

sleep 5

if kill -0 "$transpiler_pid" >/dev/null 2>&1; then
  kill "$transpiler_pid"
fi

exit 0