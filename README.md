# Project Setup

## docker compose

```bash
# Start the development environment
docker-compose up -d
# Get a terminal in the Rails container
docker-compose exec web bash
# install Rails
gem install rails
```


## create rails project

```bash
rails new help_desk_backend --database=mysql --skip-system-test

cd help_desk_backend
# Install dependencies
bundle install
```