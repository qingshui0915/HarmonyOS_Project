import { http } from '@kit.NetworkKit';
import { NetConstants } from '../constants/NetConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Response } from '../api/Response'; // Import Response class
import { MMKV } from "@tencent/mmkv/src/main/ets/utils/MMKV";
import { UserData } from '../viewmodel/UserData';
import { router } from '@kit.ArkUI';

// 刷新token请求方法调用
async function refreshToken(): Promise<string | null> {
  // 获取之前refresh_token
  const refreshToken = MMKV.defaultMMKV().decodeString("R_Token");
  console.log("打印refresh_token==="+JSON.stringify(refreshToken))
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
    if (newToken.statusCode == 200){
      console.log("打印新token==="+JSON.stringify(newToken.data.access_token))
      //重新存入新Token-->下面会调用新的token
      MMKV.defaultMMKV().encodeString("Token", `Bearer ${newToken.data.access_token}`)
      return `Bearer ${newToken.data.access_token}`
    }else{
      //这里跳转到重新登录页面
      //清楚存储信息
      MMKV.defaultMMKV().clearAll()
      //跳转到登录页面
      router.replaceUrl({
        url:"pages/Pages_Login"
      })
      //清空页面栈 只保留当前页面在栈顶
      router.clear()
    }
  }
  return null;
}

export async function requestSync<T>(path: string, method: http.RequestMethod, marker?: string, extraData?: Object): Promise<Response<T>> {
  return new Promise<Response<T>>((resolve, reject) => {
    let url = NetConstants.BASE_URL + path;
    let header: HeaderInterFace = {
      Authorization: MMKV.defaultMMKV().decodeString("Token") || "",
      'Content-Type': 'application/x-www-form-urlencoded',
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
    hilog.info(0, NetConstants.NET_TAG, `//=========HTTP====>, path: ${path}, method: ${method}, extraData: ` + JSON.stringify(extraData));
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
        hilog.info(0, NetConstants.NET_TAG, `//=========HTTP_request====>, path: ${path}, result: ${JSON.stringify(res)}`);
        resolve(res);  // 成功情况下直接返回
        return;  // 添加return避免继续执行
      }
      // 处理错误情况
      hilog.error(0, NetConstants.NET_TAG, `//=========HTTP_request_error====>, path: ${path}, error: ${JSON.stringify(err)}`);
      if (data?.responseCode === 401 || err?.message?.includes('Unauthorized')) {
        try {
          const newToken = await refreshToken();
          if (newToken) {
            header.Authorization = newToken;
            hilog.info(0, NetConstants.NET_TAG, `Token refreshed, retrying request...`);
            
            // 使用Promise包装重试请求
            const retryResult = await new Promise<Response<T>>((retryResolve, retryReject) => {
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
                  retryResolve(res);
                } else {
                  res.statusCode = dataRetry?.responseCode ?? -1;
                  res.message = errRetry?.message ?? "Retry request failed";
                  retryReject(res);
                }
              });
            });
            
            resolve(retryResult);
          } else {
            res.statusCode = data?.responseCode ?? -1;
            res.message = "Token refresh failed. Please log in again.";
            resolve(res);
          }
        } catch (error) {
          res.statusCode = -1;
          res.message = "Error during token refresh process";
          resolve(res);
        }
      } else {
        res.statusCode = data?.responseCode ?? -1;
        res.message = err?.message ?? "";
        resolve(res);
      }
    });
  });
}




interface HeaderInterFace {
  Authorization: string;
  'Content-Type': string;
  'timeout': number;
}