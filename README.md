## Introduction
Quickly ingest Papertrail tab-separated archive files into a ELK stack for fast analysis.

## Requirements

* Docker
* [Direnv](https://direnv.net/) (or some other way to load settings from `.env.local`)
* Ruby
* Curiosity

## Getting Started
Find your Papertrail API token and set it in `.env.local`
```
# .env.local
PAPERTRAIL_API_TOKEN=<token>
```

Ruby setup
```bash
gem install bundler
bundle
```

Get the ELK stack running
```
docker-compose up -d
```

Kick it off
```
bundle exec rake
```

Browse your results via [Kibana](http://localhost:5601).

## ELK
Read more at https://elk-docker.readthedocs.io/.
