# s3sync

This step app is based on [wercker/step-s3sync](https://github.com/wercker/step-s3sync) and [schickling/step-s3-website](https://github.com/schickling/step-s3-website)

Main difference to [wercker/step-s3sync](https://github.com/wercker/step-s3sync) are:

* It will invalidate CloudFront cache by using [s3_website](https://github.com/laurilehmijoki/s3_website) gem
* Set `bucket_name` instead of `bucket_url` in `wercker.yml`
* Set `BUCKET` instead of `URL` in deploy variable
* Set `CF_DISTRIBUTION_ID` in deploy variable, `cf_distribution_id` in `wercker.yml`
* `region` should match with your S3 endpoint
* Include `gem "s3_website"` in your Gemfile

# Example

```
deploy:
    steps:
        - rvm-use:
            version: ruby-2.1.5
        - bundle-install
        - ascendbruce/s3sync:
            key_id: $KEY
            key_secret: $SECRET
            bucket_name: $BUCKET
            cf_distribution_id: $CF_DISTRIBUTION_ID
            region: ap-northeast-1
            source_dir: _site/
```

# License

The MIT License (MIT)
