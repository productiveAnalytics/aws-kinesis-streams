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

for i in `seq 0 $MAX_INDEX`
do
   echo "Shard # $(($i+1)): ${SHARDS[$i]}"
done
