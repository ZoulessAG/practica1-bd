FROM python:3.11-alpine

RUN apk add --no-cache postgresql-client bash

WORKDIR /app

COPY . /app

RUN chmod +x /app/runner/runner.sh

CMD ["/bin/bash", "/app/runner/runner.sh"]
