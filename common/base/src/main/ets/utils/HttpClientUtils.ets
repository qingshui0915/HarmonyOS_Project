import { http } from '@kit.NetworkKit';
import { NetConstants } from '../constants/NetConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Response } from '../api/Response'; // 导入Response类



export async function requestSync<T>(path: string, method: http.RequestMethod, extraData?: Object): Promise<Response<T>> {
  return new Promise<Response<T>>((resolve, reject) => {
    let url = NetConstants.BASE_URL + path;
    let header: HeaderInterFace = {
      "Authorization":AppStorage.get("Token") || "",
      'Content-Type': 'application/json',
      timeout : NetConstants.TIMEOUT
    }
    if (method === http.RequestMethod.POST) {
      header = {
        "Authorization":AppStorage.get("Token") || "",
        'Content-Type': 'application/x-www-form-urlencoded',
        timeout : NetConstants.TIMEOUT
      }
    }
    let httpRequest = http.createHttp();
    hilog.info(0, NetConstants.NET_TAG, `start request, path: ${path}, method: ${method}, extraData: ` + JSON.stringify(extraData));
    httpRequest.request(
      url,
      {
        method: method,
        expectDataType: http.HttpDataType.OBJECT,
        header: header,
        extraData: extraData
      },
      (err, data) => {
        let res = new Response<T>()
        if (!err && data.responseCode === 200) {
          //Object.assign("", "");对象合并
          if (typeof data.result === 'string') {
            res.data = JSON.parse(data.result)
          } else {
            // Object.assign(res, data.result);
            res.data = data.result as T
          }
          hilog.info(0, NetConstants.NET_TAG, `request success, path: ${path}, result: ${JSON.stringify(res)}`)
        } else {
          hilog.error(0, NetConstants.NET_TAG, `request error, path: ${path}, error: ${JSON.stringify(err)}`)
          // // 检查是否是Token过期
          // if (data?.responseCode === 401 || err?.message?.includes('Unauthorized')) {
          //   await refreshTokenAndRetry(url, method, extraData, resolve, reject);
          // } else {
          //   res.statusCode = data?.responseCode ?? -1;
          //   res.message = err?.message ?? "";
          //   resolve(res);
          // }
          res.statusCode = data?.responseCode??-1
          res.message = err?.message??""
        }
        resolve(res);
      }
    )
  })
}

interface HeaderInterFace {
  // 'ApiVersion': string,
  "Authorization":string,
  'Content-Type': string,
  // 'platform': string,
  // 'encryption-mode': string,
  // 'auth': string,
  // 'channel': string,
  'timeout': number
}
