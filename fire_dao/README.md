## FireDao

### 主网
`0xD2fc5C2fcd7cae60F25c840Ec1a3A95E6012B82F`

### 本地开发测试
rpc endpoint: `http://192.168.3.20:8545`

fireToken address: `0xfB34c790fCEe4f74Af614CcE57eA8C12334ef2F5`

fireDao address: `0xAe1a329ce248aaC65A145ECF2Fc2DC2DA7295409`

fireToken的小数位: 8

测试的白名单钱包地址私钥
  - 0x8e14152686df8aba8ddcc19415787c8b958ec054e38998355074e6aeb612f7cc
  - 0x72de35e598e9d094b35237b48a6634af390f9823bb6636788aaf38172f883b92

### 获取一共有 多少 FIRE(total)
total()

### 获取已经提取了 多少 FIRE(withdrawn)
withdrawn()

### 获取当前周期的锁仓数量(vestedAmount)
vestedAmount()

### 获取剩余锁仓数量(remainingAmountToBeVested)
remainingAmountToBeVested()

### 获取当前可提取的最大数量
currentMaximum()

### 确认提取(withdraw)
withdraw(address,uint256,_time)
  - address: 用户的钱包地址
  - uint256: 确认提取的数量，需要乘小数位
  - _time: 操作确认提取的10位时间戳