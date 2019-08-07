#! /usr/bin/bash

export KINESIS_STREAM_NAME="hds_ncs"
### Uncomment to create Kinesis Stream from scratch
#aws kinesis create-stream --stream-name $KINESIS_STREAM_NAME --shard-count 10

echo "Existing AWS Kinesis streams are..."
aws kinesis list-streams

echo "Working on AWS Kinesis stream: $KINESIS_STREAM_NAME"

aws kinesis describe-stream --stream-name $KINESIS_STREAM_NAME

SHARDS_COUNT=$(aws kinesis list-shards --stream-name $KINESIS_STREAM_NAME --query 'Shards[].[ShardId]' --output text | wc -l)
echo "Total shards: $SHARDS_COUNT"

# Array of shards...Need outer round-brackets
declare SHARDS=($(aws kinesis list-shards --stream-name $KINESIS_STREAM_NAME --query 'Shards[].[ShardId]' --output text))

declare MAX_INDEX=$((SHARDS_COUNT-1))
#echo "MAX_INDEX=$MAX_INDEX"
declare SHARD_ITERATOR_ID="-"
declare SHARD_ID="-"
for i in `seq 0 $MAX_INDEX`
do
   echo

   # Trim the white spaces in Shard Id
   SHARD_ID=`echo "${SHARDS[$i]}" | sed -e 's/^[[:space:]]*//'`
   echo "Shard # $(($i+1)): ${SHARD_ID}"

   SHARD_ITERATOR_ID=$(aws kinesis get-shard-iterator --stream-name $KINESIS_STREAM_NAME --shard-id $SHARD_ID --shard-iterator-type TRIM_HORIZON --query 'ShardIterator')
   # Trim the white spaces in Shard Iterator Id
   ###SHARD_ITERATOR_ID=`echo "$SHARD_ITERATOR_ID=" | sed -e 's/^[[:space:]]*//'`
   echo "Retrieving records using Shard Iterator: $SHARD_ITERATOR_ID"
   aws kinesis get-records --shard-iterator $SHARD_ITERATOR_ID --limit 5
done