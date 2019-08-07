#! /usr/bin/bash

# Confirm if AWS Kinesis CLI is working
aws kinesis describe-limits

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
#declare SHARDS_INFO=($(aws kinesis list-shards --stream-name $KINESIS_STREAM_NAME --query 'Shards[].[ShardId,  SequenceNumberRange.StartingSequenceNumber]' --output text))
declare SHARD_IDS=($(aws kinesis list-shards --stream-name $KINESIS_STREAM_NAME --query 'Shards[].[ShardId]' --output text))
declare SHARD_START_SEQS=($(aws kinesis list-shards --stream-name $KINESIS_STREAM_NAME --query 'Shards[].[SequenceNumberRange.StartingSequenceNumber]' --output text))

declare SHARD_ITERATOR_TYPE="AFTER_SEQUENCE_NUMBER" # Allowed values TRIM_HORIZON | LATEST -OR- AT_SEQUENCE_NUMBER | AFTER_SEQUENCE_NUMBER

declare MAX_INDEX=$((SHARDS_COUNT-1))
echo "MAX_INDEX=$MAX_INDEX"
declare SHARD_ITERATOR_ID="-"
declare SHARD_ID="-"
declare STARTING_SEQ=""
for i in `seq 0 $MAX_INDEX`
do
   echo

   # Trim the white spaces in Shard Id
   SHARD_ID=`echo "${SHARD_IDS[$i]}" | sed -e 's/^[[:space:]]*//'`
   STARTING_SEQ=`echo "${SHARD_START_SEQS[$i]}" | sed -e 's/^[[:space:]]*//'`
   echo "Shard # $(($i+1)): $SHARD_ID @ $STARTING_SEQ"

   if [$SHARD_ITERATOR_TYPE == "TRIM_HORIZON"]; then
      echo "Shard Iterator type: $SHARD_ITERATOR_TYPE"
      SHARD_ITERATOR_ID=$(aws kinesis get-shard-iterator --stream-name $KINESIS_STREAM_NAME --shard-id $SHARD_ID --shard-iterator-type TRIM_HORIZON --query 'ShardIterator')
   else
      echo "Shard Iterator type: $SHARD_ITERATOR_TYPE"
      SHARD_ITERATOR_ID=$(aws kinesis get-shard-iterator --stream-name $KINESIS_STREAM_NAME --shard-id $SHARD_ID --shard-iterator-type AT_SEQUENCE_NUMBER --starting-sequence-number $STARTING_SEQ --query 'ShardIterator')
   fi

   # Trim the white spaces in Shard Iterator Id
   ###SHARD_ITERATOR_ID=`echo "$SHARD_ITERATOR_ID=" | sed -e 's/^[[:space:]]*//'`
   echo "Retrieving records using Shard Iterator: $SHARD_ITERATOR_ID"
   aws kinesis get-records --shard-iterator $SHARD_ITERATOR_ID --limit 5
done