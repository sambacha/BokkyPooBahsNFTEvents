
CREATE TEMP FUNCTION
  PARSE_LOG(data STRING, topics ARRAY<STRING>)
  RETURNS STRUCT<`operator` STRING, `from` STRING, `to` STRING, `ids` STRING, `values` STRING>
  LANGUAGE js AS """
    var parsedEvent = {"anonymous": false, "inputs": [{"indexed": true, "internalType": "address", "name": "operator", "type": "address"}, {"indexed": true, "internalType": "address", "name": "from", "type": "address"}, {"indexed": true, "internalType": "address", "name": "to", "type": "address"}, {"indexed": false, "internalType": "uint256[]", "name": "ids", "type": "uint256[]"}, {"indexed": false, "internalType": "uint256[]", "name": "values", "type": "uint256[]"}], "name": "TransferBatch", "type": "event"}
    return abi.decodeEvent(parsedEvent, data, topics, false);
"""
OPTIONS
  ( library="https://storage.googleapis.com/ethlab-183014.appspot.com/ethjs-abi.js" );

WITH parsed_logs AS
(SELECT
    logs.block_timestamp AS block_timestamp
    ,logs.block_number AS block_number
    ,logs.transaction_hash AS transaction_hash
    ,logs.log_index AS log_index
    ,PARSE_LOG(logs.data, logs.topics) AS parsed
FROM `bigquery-public-data.crypto_ethereum.logs` AS logs
WHERE address = '0xfe9231f0e6753a8412a00ec1f0028a24d5220ba9'
  AND topics[SAFE_OFFSET(0)] = '0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb'
)
SELECT
     block_timestamp
     ,block_number
     ,transaction_hash
     ,log_index
    ,parsed.operator AS `operator`
    ,parsed.from AS `from`
    ,parsed.to AS `to`
    ,parsed.ids AS `ids`
    ,parsed.values AS `values`
FROM parsed_logs