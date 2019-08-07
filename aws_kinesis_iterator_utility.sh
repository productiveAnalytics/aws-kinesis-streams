#! /usr/bin/bash

echo "Existing AWS Kinesis streams are..."
aws kinesis list-streams

export KINESIS_STREAM_NAME="hds_ncs"
echo "Working on AWS Kinesis stream: $KINESIS_STREAM_NAME"

SHARDS_COUNT=$(aws kinesis list-shards --stream-name $KINESIS_STREAM_NAME --query 'Shards[].[ShardId]' --output text | wc -l)
echo "Total shards: $SHARDS_COUNT"
# Array of shards
declare SHARDS=($(aws kinesis list-shards --stream-name $KINESIS_STREAM_NAME --query 'Shards[].[ShardId]' --output text))

declare MAX_INDEX=$((SHARDS_COUNT-1))
#echo "MAX_INDEX=$MAX_INDEX"
declare SHARD_ITERATOR_ID="-"
declare SHARD_ID="-"
for i in `seq 0 $MAX_INDEX`
do
   # Trim the white spaces
   SHARD_ID=`echo "${SHARDS[$i]}" | sed -e 's/^[[:space:]]*//'`
   echo "Shard # $(($i+1)): ${SHARD_ID}"
   SHARD_ITERATOR_ID=$(aws kinesis get-shard-iterator --stream-name $KINESIS_STREAM_NAME --shard-id "$SHARD_ID" --shard-iterator-type TRIM_HORIZON --query ShardIterator)
   echo "Shard Iterator: $SHARD_ITERATOR_ID"
done
