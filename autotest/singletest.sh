#!/bin/bash
source utils/util.sh

# call engine/${engine}.sh
bash engine/${engine}/entrypoint_outer.sh "$@"

# wait until server is ready
check_server http://127.0.0.1:${port}/v1/models

# call benchmark/${benchmark}.sh
bash benchmark/${benchmark}/entrypoint_outer.sh "$@"

# exit engine
bash engine/${engine}/exit.sh

bash export/entrypoint_outer.sh --name "tmp" --start-date "19700101-000000" --end-date "99991231-235959"