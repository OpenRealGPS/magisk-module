# OpenRealGPS API

## 调用 API

OpenRealGPS 会在本地的 9767 端口监听，调用 API 时需要向 http://127.0.0.1:9767/ 发送 HTTP POST 请求。

请求体需要包含一个特定格式的 JSON：`["methodName", [], [ parameters... ]]`，返回结果也是一个特定格式的 JSON：`[statusCode, returnValue]`。具体格式与调用的方法有关，详见下文。

## API 方法

### ping
该方法用于检测 OpenRealGPS 的工作状态。

#### Request (sample)
```
["ping", [], []]
```

#### Response (sample)
```
[0, 0]
```

### setDataSource
该方法用于设置 GNSS 数据来源，参数为 true 时使用模拟数据，参数为 false 时使用真实数据。每次系统重启时该设置都会被重置为 false。

#### Request (sample)
```
["setDataSource", [], [false]]
```

#### Response (sample)
```
[0, null]
```

### setHardwareEnabled
该方法用于设置是否启用 GNSS 硬件。若禁用硬件，将无法在使用模拟数据时获取真实数据。每次系统重启时该设置都会被重置为 true。

#### Request (sample)
```
["setHardwareEnabled", [], [true]]
```

#### Response (sample)
```
[0, null]
```

### updateLocation
该方法用于更新模拟的位置数据。每次被调用时，OpenRealGPS 驱动都会向系统上层报告最新位置。建议每 1s 调用一次该方法。

#### Request (sample)
```
["updateLocation", [], [{"latitude": 0.00, "longitude": 0.00, "altitude": 0.00, "speed": 0.0, "bearing": 0.0, "accuracy": 0.0, "timestamp": 0}]]
```

#### Response (sample)
```
[0, null]
```

### updateSatellites
该方法用于更新模拟的卫星数据。每次被调用时，OpenRealGPS 驱动都会向系统上层报告最新卫星数据。建议每 1s 调用一次该方法。最多包含 64 组卫星数据，超出部分将被忽略。

#### Request (sample)
```
["updateSatellites", [], [[{"prn": 1, "snr": 20.0, "elv": 0.0, "azm": 0.0}, {"prn": 2, "snr": 20.0, "elv": 0.0, "azm": 0.0}, ...]]]
```

#### Response (sample)
```
[0, null]
```

### getRealLocation
该方法用于获取真实位置数据。若禁用了 GNSS 硬件将返回无效数据。

#### Request (sample)
```
["getRealLocation", [], []]
```

#### Response (sample)
```
[0, {"latitude": 0.00, "longitude": 0.00, "altitude": 0.00, "speed": 0.0, "bearing": 0.0, "accuracy": 0.0, "timestamp": 0}]
```
