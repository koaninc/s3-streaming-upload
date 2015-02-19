{EventEmitter} = require 'events'

async          = require 'async'
aws            = require 'aws-sdk'

class Uploader extends EventEmitter
  # Constructor
  constructor: ({accessKey, secretKey, region, stream, objectName, objectParams, bucket, partSize, maxBufferSize, waitForPartAttempts, waitTime}, @cb) ->
    super()
    aws.config.update
      accessKeyId:     accessKey
      secretAccessKey: secretKey
      region:          region if region

    @objectName           = objectName
    @objectParams         = objectParams or {}
    @objectParams.Bucket ?= bucket
    @objectParams.Key    ?= objectName
    @objectParams.Body   ?= stream
    @timeout              = 300000

    if not @objectParams.Bucket then throw new Error "Bucket must be given"

    # console.log @objectParams
    @upload = new aws.S3.ManagedUpload { partSize: 10 * 1024 * 1024, queueSize: 1, params: @objectParams }
    @upload.minPartSize = 1024 * 1024 * 5
    @upload.queueSize   = 4

    @upload.on 'httpUploadProgress', (progress) ->
      console.log "#{progress.loaded} / #{progress.total}"

  send: (callback) ->
    @upload.send (err, data) ->
      if err then console.log err, data
      callback err, data

module.exports =
  Uploader: Uploader
