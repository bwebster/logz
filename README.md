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

After importing a small amount of data using `bundle exec rake index`, you can import
a pre-configured dashboard to use.

1. Go to [Kibana](http://localhost:5601)
1. Click Management -> Saved Objects -> Import
1. Drag `kibana/export.json` into your browser
1. Enjoy!
