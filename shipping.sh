#!/bin/bash
echo "Starting package preparation for shipping"

echo "Prepare documentation"
MIX_ENV=prod mix compile && \
  ~/.mix/escripts/ex_doc "Racing" "0.1.0" \
  _build/prod/lib/racing/ebin \
  -m "Racing" \
  -u "https://github.com/habutre/racing" && \
  MIX_ENV=prod mix escript.build

echo "Building Racing App"
MIX_ENV=prod mix escript.build

echo "Build docker image"
docker build -t habutre/racing:0.1.0 .

echo "Publish image"
docker login habutre
docker push habutre/racing:0.1.0

