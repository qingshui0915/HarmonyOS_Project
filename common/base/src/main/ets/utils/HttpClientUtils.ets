import { http } from '@kit.NetworkKit';
import { NetConstants } from '../constants/NetConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Response } from '../api/Response'; // Import Response class
import { MMKV } from "@tencent/mmkv/src/main/ets/utils/MMKV";
import { UserData } from '../viewmodel/UserData';
// 刷新token请求方法调用
async function refreshToken(): Promise<string | null> {
  // 获取之前refresh_token
  const refreshToken = MMKV.defaultMMKV().decodeString("R_Token");
  //判空
  if (!refreshToken) {
    return null;
  }
  // 重新调用登录请求
  let refreshUrl = `${NetConstants.BASE_URL}api/auth/custom-driver/connect/token`;
  let refreshResponse = await http.createHttp().request(refreshUrl, {
    method: http.RequestMethod.POST,
    expectDataType: http.HttpDataType.OBJECT,
    extraData: `client_id=app&grant_type=refresh_token&refresh_token=${refreshToken}`
  });
  if (refreshResponse.responseCode === 200 && refreshResponse.result) {
    // 返回model
    let newToken = refreshResponse.result as UserData
    console.log("打印新token==="+JSON.stringify(newToken))
    //重新存入新Token-->下面会调用新的token
    MMKV.defaultMMKV().encodeString("Token", `Bearer ${newToken.data.access_token}`)
    return `Bearer ${newToken.data.access_token}`
  }
  return null;
}

export async function requestSync<T>(path: string, method: http.RequestMethod, marker?: string, extraData?: Object): Promise<Response<T>> {
  return new Promise<Response<T>>((resolve, reject) => {
    let url = NetConstants.BASE_URL + path;
    let header: HeaderInterFace = {
      Authorization: MMKV.defaultMMKV().decodeString("Token") || "",
      'Content-Type': 'application/json',
      timeout: NetConstants.TIMEOUT
    };
    if (marker == ""){
      header = {
        "Authorization":MMKV.defaultMMKV().decodeString("Token") || "",
        'Content-Type': 'application/x-www-form-urlencoded',
        timeout : NetConstants.TIMEOUT
      }
    }else{
      header = {
        "Authorization":MMKV.defaultMMKV().decodeString("Token") || "",
        'Content-Type': 'application/json',
        timeout : NetConstants.TIMEOUT
      }
    }

    let httpRequest = http.createHttp();
    hilog.info(0, NetConstants.NET_TAG, `start request, path: ${path}, method: ${method}, extraData: ` + JSON.stringify(extraData));
    httpRequest.request(url, {
      method: method,
      expectDataType: http.HttpDataType.OBJECT,
      header: header,
      extraData: extraData
    }, async (err, data) => {
      let res = new Response<T>();
      if (!err && data.responseCode === 200) {
        if (typeof data.result === 'string') {
          res.data = JSON.parse(data.result);
        } else {
          res.data = data.result as T;
        }
        hilog.info(0, NetConstants.NET_TAG, `request success, path: ${path}, result: ${JSON.stringify(res)}`);
      } else {
        hilog.error(0, NetConstants.NET_TAG, `request error, path: ${path}, error: ${JSON.stringify(err)}`);
        // token过期判断(HTTP-->401 || Unauthorized)
        if (data?.responseCode === 401 || err?.message?.includes('Unauthorized')) {
          // 获取刷新token
          let newToken = await refreshToken();
          if (newToken) {
            // 重新请求
            header.Authorization = newToken;
            hilog.info(0, NetConstants.NET_TAG, `Token refreshed, retrying request...`);
            console.log("重新请求了")
            // 重新请求当前接口
            httpRequest.request(url, {
              method: method,
              expectDataType: http.HttpDataType.OBJECT,
              header: header,
              extraData: extraData
            }, (errRetry, dataRetry) => {
              if (!errRetry && dataRetry.responseCode === 200) {
                if (typeof dataRetry.result === 'string') {
                  res.data = JSON.parse(dataRetry.result);
                } else {
                  res.data = dataRetry.result as T;
                }
                hilog.info(0, NetConstants.NET_TAG, `retry success, path: ${path}, result: ${JSON.stringify(res)}`);
              } else {
                //这里也是 获取刷新token失败-->这里直接全局弹框提醒重新登录
                res.statusCode = dataRetry?.responseCode ?? -1;
                res.message = errRetry?.message ?? "";
                resolve(res);
              }
            });
          } else {
            // 获取刷新token失败-->这里直接全局弹框提醒重新登录
            res.statusCode = data?.responseCode ?? -1;
            res.message = "Token refresh failed. Please log in again.";
            resolve(res);
          }
        } else {
          res.statusCode = data?.responseCode ?? -1;
          res.message = err?.message ?? "";
          resolve(res);
        }
      }
      resolve(res);
    });
  });
}

interface HeaderInterFace {
  Authorization: string;
  'Content-Type': string;
  'timeout': number;
}