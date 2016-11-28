#!/bin/bash

redis-server &

sleep 1

# Needed for connections to be accepted from within the docker network
redis-cli config set protected-mode no

# Some starting values
redis-cli hset '0756500769d10831618cfc727d399bfe'  'domain' '.tudespensa.com'
redis-cli hset '0756500769d10831618cfc727d399bfe'  'active' 'true'
redis-cli hset 'a3e701a546063a32f3e6638730f59ed9'  'domain' '.samplia.com'
redis-cli hset 'a3e701a546063a32f3e6638730f59ed9'  'active' 'false'

# Local testing only
#redis-cli hset 'e589f180d00df0bcac4bef7c7f282231'  'domain' 'clousr.com'
redis-cli hset 'e589f180d00df0bcac4bef7c7f282231'  'domain' '.clousr.net'
redis-cli hset 'e589f180d00df0bcac4bef7c7f282231'  'active' 'true'

wait
