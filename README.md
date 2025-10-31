# Project Setup

## Docker Compose

```bash
# Start the development environment
docker-compose up -d
# Get a terminal in the Rails container
docker-compose exec web bash
# install Rails
gem install rails
```

## Start Backend

```bash
# Navigate to the app directory
cd help_desk_backend

# Install dependencies
bundle install
   
# Start the Rails server
rails server -b 0.0.0.0 -p 3000
```

## Rails Project Configure

### Create a New Rails Application

```bash
rails new help_desk_backend --api --skip-kamal --skip-thruster  --database=mysql

cd help_desk_backend
# Install dependencies
bundle install
```


### Configure Database

```bash
# Create the database
rails db:create
```

### Generate Models

```bash
# User
rails generate model User \
  username:string \
  password_digest:string \
  last_active_at:datetime

# Conversation
rails generate model Conversation \
  title:string \
  status:string \
  initiator:references \
  assigned_expert:references \
  last_message_at:datetime

# Message
rails generate model Message \
  conversation:references \
  sender:references \
  sender_role:string \
  content:text \
  is_read:boolean

# ExpertProfile
rails generate model ExpertProfile \
  user:references \
  bio:text \
  knowledge_base_links:json

# ExpertAssignment
rails generate model ExpertAssignment \
  conversation:references \
  expert:references \
  status:string \
  assigned_at:datetime \
  resolved_at:datetime


# Modify help_desk_backend/db/migrate

# Run the migration
rails db:migrate
# rails db:drop db:create db:migrate
```

### Generate Controllers

```bash
rails generate controller Health index

rails generate controller Auth register login logout refresh me

rails generate controller Conversations index show create

rails generate controller Messages index create read

rails generate controller Expert queue claim unclaim profile update_profile assignments_history

rails generate controller Api::Updates conversations messages expert_queue
```