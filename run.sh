#!/bin/sh
set -e
cd "$WERCKER_ROOT"

# check environment variables

if [ ! -n "$WERCKER_S3SYNC_KEY_ID" ]
then
    fail 'missing or empty option key_id, please check wercker.yml'
fi

if [ ! -n "$WERCKER_S3SYNC_KEY_SECRET" ]
then
    fail 'missing or empty option key_secret, please check wercker.yml'
fi

if [ ! -n "$WERCKER_S3SYNC_BUCKET_NAME" ]
then
    fail 'missing or empty option bucket_name, please check wercker.yml'
fi

if [ ! -n "$WERCKER_S3SYNC_OPTS" ]
then
    export WERCKER_S3SYNC_OPTS="--acl-public"
fi

if [ -n "$WERCKER_S3SYNC_DELETE_REMOVED" ]; then
    if [ "$WERCKER_S3SYNC_DELETE_REMOVED" = "true" ]; then
        export WERCKER_S3SYNC_DELETE_REMOVED="--delete-removed"
    else
        unset WERCKER_S3SYNC_DELETE_REMOVED
    fi
else
    export WERCKER_S3SYNC_DELETE_REMOVED="--delete-removed"
fi

# install necessary packages and gems

sudo apt-get update;
sudo apt-get install -y default-jre;

if ! type s3_website &> /dev/null ;
then
    gem install s3_website;
else
    info 'skip s3_website install, command already available'
    debug "type s3_website: $(type s3_website)"
fi

# set up s3_website.yml

if [ -e 's3_website.yml' ]
then
    warn 's3_website.yml file already exists in home directory and will be overwritten'
fi

cat > s3_website.yml <<EOF
s3_id: $WERCKER_S3SYNC_KEY_ID
s3_secret: $WERCKER_S3SYNC_KEY_SECRET
s3_bucket: $WERCKER_S3SYNC_BUCKET_NAME
s3_endpoint: $WERCKER_S3SYNC_REGION
cloudfront_distribution_id: $WERCKER_S3SYNC_CF_DISTRIBUTION_ID
max_age: 300
gzip:
- .html
- .css
- .js
- .svg
- .ttf
- .eot
- .woff
exclude_from_upload:
- .DS_Store
EOF

info 'starting s3 synchronisation'

bundle exec s3_website cfg apply --headless
bundle exec s3_website push --site "$WERCKER_S3SYNC_SOURCE_DIR"

success 'finished s3 synchronisation';
