#! /usr/bin/bash

echo "Existing AWS Kinesis streams are..."
aws kinesis list-streams

export KINESIS_STREAM_NAME="hds_ncs"
echo "Working on AWS Kinesis stream: $KINESIS_STREAM_NAME"

declare DATA_COUNT=1111
declare PATITION_KEY=""
declare DATA_VALUE=""
declare OUTPUT="-"
for i in `seq 1 $DATA_COUNT`
do
   PATITION_KEY=`echo "Key-"$i`
   DATA_VALUE=`echo "MyData-"$i`
   aws kinesis put-record --stream-name $KINESIS_STREAM_NAME --partition-key $PATITION_KEY --data $DATA_VALUE
done