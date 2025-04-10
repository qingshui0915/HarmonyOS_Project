import { http } from '@kit.NetworkKit';
import fs from '@ohos.file.fs';
import { request } from './request';

/**
 * PutObject
 * @param fileUri 文件URI file://media/Photo/25/IMG_1741571214_024/1741571114455.jpeg
 * @param fileType ContentType image/jpeg
 * @param signUrl 签名url 接口获取
 * @param name 图片路径地址，上传成功后原路返回 ，拼接NetConstants.OSSPoint + "/" + name即是全路径地址
 */
const putObject = async (fileUri: string ,fileType:string ,signUrl:string ,name:string): Promise<string> => {
  const fileInfo = await fs.open(fileUri, fs.OpenMode.READ_ONLY);
  const fileStat = await fs.stat(fileInfo.fd);

  const data = new ArrayBuffer(fileStat.size);
  await fs.read(fileInfo.fd, data);
  await fs.close(fileInfo.fd);

  try {
    // 使用PutObject方法上传文件
    await request(signUrl, {
      method: http.RequestMethod.PUT,
      header: {
        'Content-Length': fileStat.size,
        'Content-Type': fileType,
      },
      extraData: data
    }, 200);

    return name
    console.info('success putObject');
  } catch (err) {
    console.info('putObject request error: ' + JSON.stringify(err));

    return "";
  }
};

export { putObject };
